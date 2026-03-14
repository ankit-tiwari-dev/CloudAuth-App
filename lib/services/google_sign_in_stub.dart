class GoogleSignIn {
  GoogleSignIn();

  Future<GoogleSignInAccount?> signIn() async {
    throw UnsupportedError("Use GoogleAuthProvider on Web directly.");
  }

  Future<void> signOut() async {}
}

class GoogleSignInAccount {
  Future<GoogleSignInAuthentication> get authentication async {
      throw UnsupportedError("Use GoogleAuthProvider on Web directly.");
  }
}

class GoogleSignInAuthentication {
  final String? accessToken = null;
  final String? idToken = null;
}
