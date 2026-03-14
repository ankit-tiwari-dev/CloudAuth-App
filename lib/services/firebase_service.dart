import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart' if (dart.library.html) 'google_sign_in_stub.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_model.dart';
import 'local_storage_service.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Google Sign-In
  Future<UserModel?> signInWithGoogle() async {
    try {
      UserCredential userCredential;
      
      if (kIsWeb) {
         // Use GoogleAuthProvider directly on Web
         GoogleAuthProvider googleProvider = GoogleAuthProvider();
         userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
         final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
         if (googleUser == null) return null; // User canceled the sign-in

         final GoogleSignInAuthentication googleAuth =
             await googleUser.authentication;

         final OAuthCredential credential = GoogleAuthProvider.credential(
           accessToken: googleAuth.accessToken,
           idToken: googleAuth.idToken,
         );
         userCredential = await _auth.signInWithCredential(credential);
      }
      
      final User? user = userCredential.user;

      if (user != null) {
        UserModel userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
        );

        // Store or update user in Firestore
        await createUserInFirestore(userModel);
        
        // Save auth state locally
        await LocalStorageService.setLoggedIn(true);

        return userModel;
      }
      return null;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Register with Email Password
  Future<UserModel?> registerWithEmail(String email, String password, String name) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;

      if (user != null) {
        await user.updateDisplayName(name);
        
        UserModel userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: name,
          createdAt: DateTime.now(),
        );

        await createUserInFirestore(userModel);
        await LocalStorageService.setLoggedIn(true);
        return userModel;
      }
      return null;
    } catch (e) {
      print('Error registering with Email: $e');
      rethrow;
    }
  }

  // Login with Email Password
  Future<UserModel?> loginWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;

      if (user != null) {
         Map<String, dynamic>? userData = await getUserFromFirestore(user.uid);
         if (userData != null) {
             await LocalStorageService.setLoggedIn(true);
             return UserModel.fromJson(userData);
         }
      }
      return null;
    } catch (e) {
      print('Error logging in with Email: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
      await LocalStorageService.setLoggedIn(false);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Firestore operations
  Future<void> createUserInFirestore(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(
            user.toJson(),
            SetOptions(merge: true),
          );
    } catch (e) {
      print('Error saving user to Firestore: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserFromFirestore(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching user from Firestore: $e');
      return null;
    }
  }
}
