import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../config/theme.dart';
import '../providers/auth_provider.dart';
import '../data/services/social_login_service.dart';
import '../../../features/trainer/shell/trainer_shell.dart';

class SocialLoginButtons extends StatefulWidget {
  const SocialLoginButtons({super.key});

  @override
  State<SocialLoginButtons> createState() => _SocialLoginButtonsState();
}

class _SocialLoginButtonsState extends State<SocialLoginButtons> {
  bool _isGoogleLoading = false;
  bool _isFacebookLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    
    try {
      final result = await SocialLoginService.signInWithGoogle();
      if (result == null) {
        // User cancelled
        setState(() => _isGoogleLoading = false);
        return;
      }

      if (!mounted) return;
      
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.oauthLogin('google', result.accessToken);
      
      if (success && mounted) {
        final role = authProvider.currentUser?.role.toUpperCase() ?? '';
        if (role == 'TRAINER') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TrainerShell()),
          );
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (mounted) {
        context.read<AuthProvider>().clearError();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign In failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  Future<void> _handleFacebookSignIn() async {
    setState(() => _isFacebookLoading = true);
    
    try {
      final result = await SocialLoginService.signInWithFacebook();
      if (result == null) {
        // User cancelled
        setState(() => _isFacebookLoading = false);
        return;
      }

      if (!mounted) return;
      
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.oauthLogin('facebook', result.accessToken);
      
      if (success && mounted) {
        final role = authProvider.currentUser?.role.toUpperCase() ?? '';
        if (role == 'TRAINER') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TrainerShell()),
          );
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (mounted) {
        context.read<AuthProvider>().clearError();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Facebook Sign In failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isFacebookLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with "OR"
        Row(
          children: [
            const Expanded(child: Divider(color: Colors.grey)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 20),

        // Google Sign In Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _isGoogleLoading || _isFacebookLoading ? null : _handleGoogleSignIn,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.white,
            ),
            icon: _isGoogleLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : SvgPicture.asset(
                    'assets/icons/google_icon.svg',
                    width: 20,
                    height: 20,
                  ),
            label: Text(
              _isGoogleLoading ? 'Signing in...' : 'Continue with Google',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Facebook Sign In Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _isGoogleLoading || _isFacebookLoading ? null : _handleFacebookSignIn,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFFFFFF)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: const Color(0xFF00E1FF),
            ),
            icon: _isFacebookLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : SvgPicture.asset(
                    'assets/icons/facebook_icon.svg',
                      width: 20,
                      height: 20,

    ),
            label: Text(
              _isFacebookLoading ? 'Signing in...' : 'Continue with Facebook',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}