import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  //google signin
  signInWithGoogle() async {
    //start signin popup
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    //obtain auth details
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    //create new credential from user
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    // Use credential to sign in
    return FirebaseAuth.instance.signInWithCredential(credential);
  }
}
