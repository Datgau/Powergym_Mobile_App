import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import 'package:powergym_mobile_app/core/network/api.dart';
import '../services/profile_api_service.dart';

/// 3-step email change flow:
/// Step 1 — Enter new email → OTP sent to current email
/// Step 2 — Verify OTP from current email → OTP sent to new email
/// Step 3 — Verify OTP from new email → email changed
class ChangeEmailScreen extends StatefulWidget {
  final String currentEmail;
  final VoidCallback onChanged;

  const ChangeEmailScreen({
    super.key,
    required this.currentEmail,
    required this.onChanged,
  });

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final _api = ProfileApiService();
  int _step = 1; // 1, 2, 3
  bool _loading = false;
  String _newEmail = '';

  // Step 1
  final _emailCtrl = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();
  String? _emailError; // server-side error for email field

  // Step 2 & 3 — OTP boxes
  final List<TextEditingController> _otpCtrl =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());

  // Resend cooldown
  int _resendCooldown = 0;
  Timer? _resendTimer;

  @override
  void dispose() {
    _emailCtrl.dispose();
    for (final c in _otpCtrl) c.dispose();
    for (final f in _otpFocus) f.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    _resendCooldown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_resendCooldown > 0) _resendCooldown--;
        else t.cancel();
      });
    });
  }

  String get _otp => _otpCtrl.map((c) => c.text).join();

  void _clearOtp() {
    for (final c in _otpCtrl) c.clear();
    _otpFocus[0].requestFocus();
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  // ── Step 1: request change ──────────────────────────────────────
  Future<void> _step1Submit() async {
    if (!_emailFormKey.currentState!.validate()) return;
    setState(() { _loading = true; _emailError = null; });
    try {
      _newEmail = _emailCtrl.text.trim();
      await _api.requestEmailChange(_newEmail);
      setState(() { _step = 2; _loading = false; });
      _startResendCooldown();
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => _otpFocus[0].requestFocus());
    } catch (e) {
      // Use Api.parseError to extract clean backend message
      final msg = _parseError(e);
      setState(() {
        _loading = false;
        _emailError = msg;
      });
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => _emailFormKey.currentState?.validate());
    }
  }

  // ── Step 2: verify current email OTP ───────────────────────────
  Future<void> _step2Submit() async {
    if (_otp.length < 6) { _showError('Enter the 6-digit code'); return; }
    setState(() => _loading = true);
    try {
      await _api.verifyCurrentEmailOtp(_otp);
      _clearOtp();
      setState(() { _step = 3; _loading = false; });
      _startResendCooldown();
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => _otpFocus[0].requestFocus());
    } catch (e) {
      setState(() => _loading = false);
      _showError(e);
    }
  }

  // ── Step 3: verify new email OTP ───────────────────────────────
  Future<void> _step3Submit() async {
    if (_otp.length < 6) { _showError('Didn\'t receive it?'); return; }
    setState(() => _loading = true);
    try {
      await _api.verifyNewEmailOtp(newEmail: _newEmail, otp: _otp);
      if (mounted) {
        // onChanged handles navigation (logout + go to login)
        // Show snackbar via root context before navigating away
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Email changed successfully! Please log in again.'),
          backgroundColor: AppTheme.success,
        ));
        widget.onChanged();
      }
    } catch (e) {
      setState(() => _loading = false);
      _showError(e);
    }
  }

  Future<void> _resend() async {
    if (_resendCooldown > 0) return;
    setState(() => _loading = true);
    try {
      if (_step == 2) {
        await _api.requestEmailChange(_newEmail);
      } else {
        await _api.verifyCurrentEmailOtp('resend'); // triggers resend
      }
    } catch (_) {}
    setState(() => _loading = false);
    _clearOtp();
    _startResendCooldown();
  }

  void _showError(Object e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(Api.parseError(e)),
      backgroundColor: AppTheme.error,
    ));
  }

  String _parseError(Object e) {
    // Use Api.parseError to extract the clean backend message from DioException
    return Api.parseError(e);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Change Email',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            _StepIndicator(current: _step),
            const SizedBox(height: 28),

            if (_step == 1) _buildStep1(),
            if (_step == 2) _buildStep2(),
            if (_step == 3) _buildStep3(),
          ],
        ),
      ),
    );
  }

  // ── Step 1 UI ───────────────────────────────────────────────────
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Enter new email',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 6),
        Text(
          'We will send a verification code to your current email: ${widget.currentEmail}',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 24),
        Form(
          key: _emailFormKey,
          child: TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) {
              if (_emailError != null) setState(() => _emailError = null);
            },
            decoration: InputDecoration(
              labelText: 'New Email Address',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppTheme.primaryBlue, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.error, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.error, width: 1.5),
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              if (v.trim() == widget.currentEmail) {
                return 'New email must be different from current email';
              }
              if (_emailError != null) return _emailError;
              return null;
            },
          ),
        ),
        const SizedBox(height: 24),
        _SubmitButton(
          label: 'Send Verification Code',
          loading: _loading,
          onPressed: _step1Submit,
        ),
      ],
    );
  }

  // ── Step 2 UI ───────────────────────────────────────────────────
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Verify current email',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 6),
        Text(
          'Enter the 6-digit code sent to\n${widget.currentEmail}',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 24),
        _OtpRow(controllers: _otpCtrl, focusNodes: _otpFocus),
        const SizedBox(height: 24),
        _SubmitButton(
          label: 'Verify',
          loading: _loading,
          onPressed: _step2Submit,
        ),
        const SizedBox(height: 16),
        _ResendRow(
          cooldown: _resendCooldown,
          fmt: _fmt,
          onResend: _resend,
        ),
      ],
    );
  }

  // ── Step 3 UI ───────────────────────────────────────────────────
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Verify new email',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 6),
        Text(
          'Enter the 6-digit code sent to\n$_newEmail',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 24),
        _OtpRow(controllers: _otpCtrl, focusNodes: _otpFocus),
        const SizedBox(height: 24),
        _SubmitButton(
          label: 'Confirm Email Change',
          loading: _loading,
          onPressed: _step3Submit,
        ),
        const SizedBox(height: 16),
        _ResendRow(
          cooldown: _resendCooldown,
          fmt: _fmt,
          onResend: _resend,
        ),
      ],
    );
  }
}

// ── Step indicator ─────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int current;
  const _StepIndicator({required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepCircle(step: 1, current: current),
        Expanded(child: _StepLine(done: current > 1)),
        _StepCircle(step: 2, current: current),
        Expanded(child: _StepLine(done: current > 2)),
        _StepCircle(step: 3, current: current),
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int step;
  final int current;
  const _StepCircle({required this.step, required this.current});

  @override
  Widget build(BuildContext context) {
    final done = step < current;
    final active = step == current;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: done || active ? AppTheme.primaryBlue : const Color(0xFFE5E7EB),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : Text(
                '$step',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : AppTheme.textSecondary,
                ),
              ),
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool done;
  const _StepLine({required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      color: done ? AppTheme.primaryBlue : const Color(0xFFE5E7EB),
    );
  }
}

// ── OTP row ────────────────────────────────────────────────────────
class _OtpRow extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  const _OtpRow({required this.controllers, required this.focusNodes});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (i) {
        return SizedBox(
          width: 48,
          height: 58,
          child: TextFormField(
            controller: controllers[i],
            focusNode: focusNodes[i],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                height: 1.2),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFFD1D5DB), width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFFD1D5DB), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppTheme.primaryBlue, width: 2),
              ),
            ),
            onChanged: (val) {
              if (val.isNotEmpty && i < 5) {
                focusNodes[i + 1].requestFocus();
              } else if (val.isEmpty && i > 0) {
                focusNodes[i - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }
}

// ── Submit button ──────────────────────────────────────────────────
class _SubmitButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onPressed;
  const _SubmitButton(
      {required this.label, required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text(label),
      ),
    );
  }
}

// ── Resend row ─────────────────────────────────────────────────────
class _ResendRow extends StatelessWidget {
  final int cooldown;
  final String Function(int) fmt;
  final VoidCallback onResend;
  const _ResendRow(
      {required this.cooldown, required this.fmt, required this.onResend});

  @override
  Widget build(BuildContext context) {
    final canResend = cooldown == 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Didn't receive it? ",
            style: TextStyle(color: AppTheme.textSecondary)),
        GestureDetector(
          onTap: canResend ? onResend : null,
          child: Text(
            canResend ? 'Resend' : 'Resend in ${fmt(cooldown)}',
            style: TextStyle(
              color: canResend ? AppTheme.primaryBlue : AppTheme.textLight,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
