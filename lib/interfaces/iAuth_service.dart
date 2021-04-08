import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthenticationServive {
  Future<void> signOut();

  Future<UserCredential> signInWithEmail(
      {required String email, required String password});

  Future<UserCredential> registerWithEmail(
      {required String email, required String password});

  bool isAuthenticated();

  Future<void> resetPassword({required String email});

  String? userId();
}
