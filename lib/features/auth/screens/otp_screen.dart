import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';
import 'login_screen.dart';

class AuthOtpScreen extends StatefulWidget {
  final String email;
  const AuthOtpScreen({super.key, required this.email});

  @override
  State<AuthOtpScreen> createState() => _AuthOtpScreenState();
}

class _AuthOtpScreenState extends State<AuthOtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  // OTP validity: 5 minutes countdown, always running
  int _otpSecondsLeft = 300;
  Timer? _otpTimer;

  // Resend cooldown: only starts after user taps Resend
  int _resendCooldown = 0; // 0 = can resend
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startOtpTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    _resendTimer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _startOtpTimer() {
    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_otpSecondsLeft > 0) _otpSecondsLeft--;
      });
    });
  }

  void _startResendCooldown() {
    _resendCooldown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_resendCooldown > 0) {
          _resendCooldown--;
        } else {
          t.cancel();
        }
      });
    });
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  String get _otp => _controllers.map((c) => c.text).join();
  bool get _otpExpired => _otpSecondsLeft == 0;
  bool get _canResend => _resendCooldown == 0;

  Future<void> _verify() async {
    if (_otpExpired) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('OTP has expired. Please request a new one.'),
        backgroundColor: AppTheme.error,
      ));
      return;
    }
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter the 6-digit code')));
      return;
    }
    final ok = await context.read<AuthProvider>().verifyOtp(widget.email, _otp);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Email verified! Please sign in.'),
        backgroundColor: AppTheme.success,
      ));
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const AuthLoginScreen()), (_) => false);
    }
  }

  Future<void> _resend() async {
    if (!_canResend) return;
    final ok = await context.read<AuthProvider>().resendOtp(widget.email);
    if (!mounted) return;
    if (ok) {
      // Reset OTP validity timer and start resend cooldown
      setState(() => _otpSecondsLeft = 300);
      _startOtpTimer();
      _startResendCooldown();
      for (final c in _controllers) c.clear();
      _focusNodes[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWarning = _otpSecondsLeft <= 60 && !_otpExpired;
    final timerColor = _otpExpired
        ? AppTheme.error
        : isWarning
            ? const Color(0xFFF59E0B)
            : const Color(0xFF10B981);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    color: AppTheme.textPrimary,
                    onPressed: () {
                      context.read<AuthProvider>().clearError();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              const AuthHeader(
                title: 'Verify Email',
                subtitle: 'Enter the code sent to your email',
                icon: Icons.mark_email_read_outlined,
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    const Text('Check your inbox',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 8),
                    Text(
                      'We sent a 6-digit code to\n${widget.email}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 20),

                    // ── OTP validity countdown ──────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: timerColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: timerColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _otpExpired
                                ? Icons.timer_off_rounded
                                : Icons.timer_outlined,
                            color: timerColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _otpExpired
                                ? 'OTP expired'
                                : 'Expires in ${_fmt(_otpSecondsLeft)}',
                            style: TextStyle(
                              color: timerColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Error banner
                    Consumer<AuthProvider>(
                      builder: (_, p, __) => p.errorMessage.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: AuthErrorBanner(message: p.errorMessage),
                            )
                          : const SizedBox.shrink(),
                    ),

                    // OTP boxes
                    OtpInput(
                        controllers: _controllers, focusNodes: _focusNodes),
                    const SizedBox(height: 32),

                    // Verify button
                    Consumer<AuthProvider>(
                      builder: (_, p, __) => AuthButton(
                        text: 'Verify',
                        isLoading: p.isLoading,
                        onPressed:
                            (p.isLoading || _otpExpired) ? null : _verify,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Resend section ──────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Didn't receive it? ",
                            style: TextStyle(color: AppTheme.textSecondary)),
                        GestureDetector(
                          onTap: _canResend ? _resend : null,
                          child: Text(
                            _canResend
                                ? 'Resend'
                                : 'Resend in ${_fmt(_resendCooldown)}',
                            style: TextStyle(
                              color: _canResend
                                  ? AppTheme.primaryBlue
                                  : AppTheme.textLight,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
