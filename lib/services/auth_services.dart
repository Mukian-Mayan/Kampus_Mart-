import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = kIsWeb
          ? GoogleSignIn(
              clientId:
                  '260066278496-196412lo8apouv51cdshajdl847oj1o2.apps.googleusercontent.com',
            )
          : GoogleSignIn(); // Default config for Android/iOS

      final GoogleSignInAccount? gUser = await googleSignIn.signIn();
      if (gUser == null) return null;

      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print("Google Sign-In Error: $e");
      rethrow;
    }
  }
}
