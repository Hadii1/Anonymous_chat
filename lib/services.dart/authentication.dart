import 'package:anonymous_chat/interfaces/auth_interface.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService implements IAuthenticationServive {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<UserCredential> registerWithEmail(
      {required String email, required String password}) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential> signInWithEmail(
      {required String email, required String password}) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async => await _auth.signOut();

  @override
  bool isAuthenticated() {
    return _auth.currentUser != null;
  }

  @override
  String? userId() {
    return _auth.currentUser?.uid;
  }

  @override
  Future<void> resetPassword({required String email}) async =>
      _auth.sendPasswordResetEmail(email: email);
}
