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

  int _countdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown == 0) {
        t.cancel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit code')),
      );
      return;
    }

    final provider = context.read<AuthProvider>();
    final ok = await provider.verifyOtp(widget.email, _otp);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified! Please sign in.'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthLoginScreen()),
        (_) => false,
      );
    }
  }

  Future<void> _resend() async {
    if (_countdown > 0) return;
    final ok = await context.read<AuthProvider>().resendOtp(widget.email);
    if (ok) _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                    const Text(
                      'Check your inbox',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We sent a 6-digit code to\n${widget.email}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 32),

                    // Error banner
                    Consumer<AuthProvider>(
                      builder: (_, p, __) => p.errorMessage.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: AuthErrorBanner(message: p.errorMessage),
                            )
                          : const SizedBox.shrink(),
                    ),

                    // OTP input
                    OtpInput(
                      controllers: _controllers,
                      focusNodes: _focusNodes,
                    ),
                    const SizedBox(height: 32),

                    // Verify button
                    Consumer<AuthProvider>(
                      builder: (_, p, __) => AuthButton(
                        text: 'Verify',
                        isLoading: p.isLoading,
                        onPressed: p.isLoading ? null : _verify,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Resend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Didn't receive it? ",
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                        _countdown > 0
                            ? Text(
                                'Resend in ${_countdown}s',
                                style: const TextStyle(
                                  color: AppTheme.textLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : GestureDetector(
                                onTap: _resend,
                                child: const Text(
                                  'Resend',
                                  style: TextStyle(
                                    color: AppTheme.primaryBlue,
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
