import 'package:firebase_auth/firebase_auth.dart';
import 'google_user.dart';

class GoogleAuthService {
  GoogleAuthService({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  Future<GoogleAccount> signInWithGoogle() async {
    final googleProvider = GoogleAuthProvider()
      ..addScope('email')
      ..addScope('profile')
      ..setCustomParameters({'prompt': 'select_account'});

    late UserCredential userCredential;
    try {
      userCredential = await _firebaseAuth.signInWithProvider(googleProvider);
    } on FirebaseAuthException catch (e) {
      print(" erooooooor ${e}");
      if (e.code == 'canceled' || e.code == 'user-cancelled') {
        throw Exception('sign_in_cancelled');
      }
      rethrow;
    }

    final user = userCredential.user;
    if (user == null) {
      throw Exception('user_not_found');
    }

    final email = user?.email;
    if (email == null || email.isEmpty) {
      throw Exception('email_not_found');
    }

    return GoogleAccount(
      uid: user.uid,
      email: email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false,
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
