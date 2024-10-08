import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  // Google sign in
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      if (gUser == null) {
        print('Google sign-in was canceled or failed.');
        return null;
      }

      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      if (gAuth.accessToken == null || gAuth.idToken == null) {
        print('Google authentication tokens are null.');
        return null;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<UserCredential?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        //  Android redirect to a web-based sign-in flow
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.example.dairy_harbor', 
          redirectUri: Uri.parse('https://example.com/callbacks/sign_in_with_apple'),
        ),
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    } catch (e) {
      print('Error signing in with Apple: $e');
      return null;
    }
  }

  // Logout function
  Future<void> logout() async {
    try {
      // Sign out from Google
      await GoogleSignIn().signOut();
      
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      
      // Sign out from Apple
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
