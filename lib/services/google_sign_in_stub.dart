// Stub for google_sign_in on web — all sign-in is handled via
// GoogleAuthProvider / signInWithPopup, so these types only need to
// exist to satisfy the analyzer.

class GoogleSignIn {
  GoogleSignIn._();
  static final GoogleSignIn instance = GoogleSignIn._();

  Future<void> initialize({
    String? clientId,
    String? serverClientId,
    String? nonce,
    String? hostedDomain,
  }) async {}

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
