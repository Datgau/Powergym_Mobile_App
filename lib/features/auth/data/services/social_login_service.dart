import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class SocialLoginService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // ─── Google Sign In ───────────────────────────────────────────────────────

  static Future<GoogleSignInResult?> signInWithGoogle() async {
    try {
      // Check if Google Play Services are available
      final bool isAvailable = await _googleSignIn.isSignedIn();
      print('Google Sign In - Play Services available: $isAvailable');
      
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        print('Google Sign In - User cancelled or no account selected');
        return null; // User cancelled
      }

      print('Google Sign In - Account: ${account.email}');
      
      final GoogleSignInAuthentication auth = await account.authentication;
      if (auth.accessToken == null) {
        print('Google Sign In - No access token received');
        throw Exception('Failed to get Google access token');
      }

      print('Google Sign In - Success: ${account.email}');
      
      return GoogleSignInResult(
        accessToken: auth.accessToken!,
        email: account.email,
        displayName: account.displayName ?? '',
        photoUrl: account.photoUrl,
      );
    } catch (e) {
      print('Google Sign In - Error: $e');
      
      // Provide more specific error messages
      if (e.toString().contains('SIGN_IN_REQUIRED') || 
          e.toString().contains('DEVELOPER_ERROR') ||
          e.toString().contains('10')) {
        throw Exception('Google Sign In not configured properly. Please check Firebase setup and SHA-1 fingerprint.');
      } else if (e.toString().contains('NETWORK_ERROR')) {
        throw Exception('Network error. Please check your internet connection.');
      } else if (e.toString().contains('SIGN_IN_CANCELLED')) {
        return null; // User cancelled
      } else if (e.toString().contains('sign_in_failed')) {
        throw Exception('Google Sign In configuration error. Please check google-services.json file.');
      } else {
        throw Exception('Google Sign In failed: ${e.toString()}');
      }
    }
  }

  static Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
  }

  static Future<FacebookSignInResult?> signInWithFacebook() async {
    try {
      throw Exception('Facebook Login chưa được cấu hình. Thiếu token.');
      
      // Code bên dưới sẽ được kích hoạt sau khi setup Facebook
      /*
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success) {
        if (result.status == LoginStatus.cancelled) {
          return null; // User cancelled
        }
        throw Exception('Facebook login failed: ${result.message}');
      }

      final AccessToken? accessToken = result.accessToken;
      if (accessToken == null) {
        throw Exception('Failed to get Facebook access token');
      }

      // Get user data
      final userData = await FacebookAuth.instance.getUserData(
        fields: "name,email,picture.width(200).height(200)",
      );

      return FacebookSignInResult(
        accessToken: accessToken.tokenString,
        email: userData['email'] as String? ?? '',
        displayName: userData['name'] as String? ?? '',
        photoUrl: userData['picture']?['data']?['url'] as String?,
      );
      */
    } catch (e) {
      if (e.toString().contains('SDK has not been initialized') ||
          e.toString().contains('FacebookSdk.sdkInitialize')) {
        throw Exception('Facebook chưa được cấu hình.');
      }
      throw Exception('Facebook Sign In failed: ${e.toString()}');
    }
  }

  static Future<void> signOutFacebook() async {
    await FacebookAuth.instance.logOut();
  }
}

class GoogleSignInResult {
  final String accessToken;
  final String email;
  final String displayName;
  final String? photoUrl;

  const GoogleSignInResult({
    required this.accessToken,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });
}

class FacebookSignInResult {
  final String accessToken;
  final String email;
  final String displayName;
  final String? photoUrl;

  const FacebookSignInResult({
    required this.accessToken,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });
}