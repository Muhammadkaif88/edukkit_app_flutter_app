import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Google Sign-In Method
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // The user canceled the sign-in

      // 2. Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Once signed in, return the UserCredential
      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Error signing in with Google: $e");
      rethrow;
    }
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint("Error signing in: $e");
      rethrow;
    }
  }

  Future<void> signUpWithEmailPassword(String email, String password, String displayName) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Update the user's display name immediately
      await credential.user?.updateDisplayName(displayName);
    } catch (e) {
      debugPrint("Error signing up: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint("Google sign out error: $e");
    }
    await _firebaseAuth.signOut();
  }

  /// Uploads [imageBytes] to Firebase Storage under the current user's UID,
  /// then updates the Firebase Auth profile photoURL and returns the download URL.
  Future<String> uploadProfilePhoto(List<int> imageBytes, String extension) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No user signed in');

    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_photos')
        .child('${user.uid}.$extension');

    final uploadTask = ref.putData(
      Uint8List.fromList(imageBytes),
      SettableMetadata(contentType: 'image/$extension'),
    );

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    // Update Firebase Auth profile
    await user.updatePhotoURL(downloadUrl);

    debugPrint('Profile photo uploaded: $downloadUrl');
    return downloadUrl;
  }
}
