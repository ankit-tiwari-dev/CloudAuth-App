// Stub for google_sign_in on web. Web sign-in uses GoogleAuthProvider.

class GoogleSignIn {
  GoogleSignIn._();

  static final GoogleSignIn instance = GoogleSignIn._();

  Future<GoogleSignInAccount> authenticate({
    List<String> scopeHint = const <String>[],
  }) async {
    throw UnsupportedError('Use GoogleAuthProvider on Web directly.');
  }

  Future<void> signOut() async {}
}

class GoogleSignInAccount {
  GoogleSignInAuthentication get authentication =>
      const GoogleSignInAuthentication(idToken: null);
}

class GoogleSignInAuthentication {
  const GoogleSignInAuthentication({required this.idToken});

  final String? idToken;
}
