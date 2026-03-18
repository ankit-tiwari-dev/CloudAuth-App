import 'dart:async';

import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({FirebaseService? service})
      : _firebaseService = service ?? FirebaseService() {
    _initialize();
  }

  final FirebaseService _firebaseService;
  StreamSubscription<dynamic>? _authSubscription;

  UserModel? _user;
  bool _isLoading = true;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<void> _initialize() async {
    _user = await LocalStorageService.getCurrentUser();
    _isLoading = false;
    Future.microtask(() => notifyListeners());

    _authSubscription = _firebaseService.authStateChanges.listen((_) {
      _syncUser();
    });
  }

  Future<void> _syncUser() async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    final firebaseUser = _firebaseService.currentUser;
    if (firebaseUser == null) {
      _user = null;
      await LocalStorageService.clearCurrentUser();
      _isLoading = false;
      Future.microtask(() => notifyListeners());
      return;
    }

    final userData = await _firebaseService.getUserFromFirestore(firebaseUser.uid);
    if (userData != null) {
      _user = UserModel.fromJson(userData);
      await LocalStorageService.saveCurrentUser(_user!);
    } else {
      _user = await LocalStorageService.getCurrentUser();
    }

    _isLoading = false;
    Future.microtask(() => notifyListeners());
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _firebaseService.loginWithEmail(email, password);
      return _user != null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _firebaseService.registerWithEmail(email, password, name);
      return _user != null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _firebaseService.signInWithGoogle();
      return _user != null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firebaseService.signOut();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
