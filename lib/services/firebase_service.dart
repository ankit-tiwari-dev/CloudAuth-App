import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:google_sign_in/google_sign_in.dart'
    if (dart.library.html) 'google_sign_in_stub.dart';

import '../models/user_model.dart';
import 'local_storage_service.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserModel?> signInWithGoogle() async {
    try {
      UserCredential userCredential;
      if (kIsWeb) {
        userCredential = await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        final googleUser = await _googleSignIn.authenticate();
        final googleAuth = googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth.signInWithCredential(credential);
      }

      final user = userCredential.user;
      if (user == null) return null;

      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
      );
      await createUserInFirestore(userModel);
      await LocalStorageService.saveCurrentUser(userModel);
      return userModel;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  Future<UserModel?> registerWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user == null) return null;

      await user.updateDisplayName(name);
      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: name,
        createdAt: DateTime.now(),
      );
      await createUserInFirestore(userModel);
      await LocalStorageService.savePasswordHash(email, password);
      await LocalStorageService.saveCurrentUser(userModel);
      return userModel;
    } catch (e) {
      debugPrint('Error registering with Email: $e');
      rethrow;
    }
  }

  Future<UserModel?> loginWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user == null) return null;

      final userData = await getUserFromFirestore(user.uid);
      if (userData == null) return null;

      final userModel = UserModel.fromJson(userData);
      await LocalStorageService.savePasswordHash(email, password);
      await LocalStorageService.saveCurrentUser(userModel);
      return userModel;
    } catch (e) {
      debugPrint('Error logging in with Email: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
      await LocalStorageService.clearCurrentUser();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  Future<void> createUserInFirestore(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toJson(), SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error fetching user from Firestore: $e');
      return null;
    }
  }
}
