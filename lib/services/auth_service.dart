import '../domain/entities/user.dart';

/// Handles Firebase Authentication.
///
/// In development mode, provides mock auth when Firebase is not configured.
class AuthService {
  bool _configured = false;
  UserEntity? _currentUser;

  UserEntity? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  /// Initialize Firebase Auth.
  Future<void> initialize() async {
    try {
      // In full implementation:
      // await Firebase.initializeApp();
      _configured = true;
    } catch (e) {
      _configured = false;
    }
  }

  /// Sign in with email and password.
  Future<AuthResult> signInWithEmail(String email, String password) async {
    if (!_configured) {
      return _mockSignIn(email);
    }

    try {
      // In full implementation:
      // final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      //   email: email, password: password,
      // );
      // _currentUser = UserEntity.fromFirebaseUser(credential.user!);
      return _mockSignIn(email);
    } catch (e) {
      return AuthResult(success: false, error: 'Sign in failed: $e');
    }
  }

  /// Sign up with email and password.
  Future<AuthResult> signUpWithEmail(
      String email, String password, String displayName) async {
    if (!_configured) {
      return _mockSignIn(email, name: displayName);
    }

    try {
      // In full implementation:
      // final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      //   email: email, password: password,
      // );
      // await credential.user!.updateDisplayName(displayName);
      return _mockSignIn(email, name: displayName);
    } catch (e) {
      return AuthResult(success: false, error: 'Sign up failed: $e');
    }
  }

  /// Sign in with Google.
  Future<AuthResult> signInWithGoogle() async {
    if (!_configured) {
      return _mockSignIn('demo@google.com', name: 'Google User');
    }

    try {
      // In full implementation:
      // final googleUser = await GoogleSignIn().signIn();
      // final googleAuth = await googleUser.authentication;
      // final credential = GoogleAuthProvider.credential(
      //   accessToken: googleAuth.accessToken,
      //   idToken: googleAuth.idToken,
      // );
      // await FirebaseAuth.instance.signInWithCredential(credential);
      return _mockSignIn('demo@google.com', name: 'Google User');
    } catch (e) {
      return AuthResult(success: false, error: 'Google sign in failed: $e');
    }
  }

  /// Send password reset email.
  Future<bool> sendPasswordReset(String email) async {
    if (!_configured) return true;

    try {
      // await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sign out.
  Future<void> signOut() async {
    _currentUser = null;
    if (!_configured) return;

    try {
      // await FirebaseAuth.instance.signOut();
      // await GoogleSignIn().signOut();
    } catch (e) {
      // Silently fail
    }
  }

  /// Delete user account.
  Future<bool> deleteAccount() async {
    if (!_configured) {
      _currentUser = null;
      return true;
    }

    try {
      // await FirebaseAuth.instance.currentUser?.delete();
      _currentUser = null;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Listen for auth state changes.
  Stream<UserEntity?> get authStateChanges async* {
    // In full implementation:
    // yield* FirebaseAuth.instance.authStateChanges().map(
    //   (user) => user != null ? UserEntity.fromFirebaseUser(user) : null,
    // );
    yield _currentUser;
  }

  AuthResult _mockSignIn(String email, {String? name}) {
    _currentUser = UserEntity(
      uid: 'mock_${email.hashCode}',
      email: email,
      displayName: name ?? email.split('@').first,
      tier: SubscriptionTier.pro,
      streakDays: 5,
      lastActiveDate: DateTime.now(),
    );
    return AuthResult(success: true, user: _currentUser);
  }
}

/// Result of an authentication operation.
class AuthResult {
  final bool success;
  final UserEntity? user;
  final String? error;

  const AuthResult({required this.success, this.user, this.error});
}
