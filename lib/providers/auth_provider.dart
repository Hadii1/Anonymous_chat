import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/providers/loading_provider.dart';
import 'package:anonymous_chat/services.dart/authentication.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/models/user.dart' as model;
import 'package:anonymous_chat/services.dart/local_storage.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = ChangeNotifierProvider(
  (ref) => _AuthProcessNotifier(
    ref.read(errorsProvider),
    ref.read(loadingProvider),
  ),
);

class _AuthProcessNotifier extends ChangeNotifier {
  final ErrorNotifier _errorNotifier;
  final LoadingNotifer _loadingNotifer;

  String email = '';
  String password = '';

  _AuthProcessNotifier(
    this._errorNotifier,
    this._loadingNotifer,
  );

  void onForgetPasswordPressed() async {
    if (email.isEmpty) {
      _errorNotifier.setError(
        message: 'Please enter email address',
      );
      return;
    }
    try {
      _loadingNotifer.isLoading = true;

      await AuthService().resetPassword(email: email.trim());

      _errorNotifier.setError(
        message: 'An email was sent to $email',
      );
    } on Exception catch (e, s) {
      _errorNotifier.setError(
        exception: e,
        stackTrace: s,
        hint: 'onForgetPasswordPressed',
      );
    }

    _loadingNotifer.isLoading = false;
  }

  Future<bool> onSignOutPressed() async {
    try {
      _loadingNotifer.isLoading = true;

      await AuthService().signOut();
      // ignore: unnecessary_statements
      LocalStorage().user == null;

      _loadingNotifer.isLoading = false;

      return true;
    } on Exception catch (e, s) {
      _errorNotifier.setError(
        exception: e,
        stackTrace: s,
      );
      _loadingNotifer.isLoading = false;
      return false;
    }
  }

  Future<bool> onLoginPressed() async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      _errorNotifier.setError(
        message: 'Please fill in both fields',
      );
      return false;
    }

    try {
      _loadingNotifer.isLoading = true;

      UserCredential credential =
          await AuthService().signInWithEmail(email: email, password: password);

      Map<String, dynamic>? userData =
          await FirestoreService().getUserData(id: credential.user!.uid);

      model.User user = model.User.fromMap(userData);

      LocalStorage().user = user;

      _loadingNotifer.isLoading = false;

      return true;
    } on Exception catch (e, s) {
      _errorNotifier.setError(
        exception: e,
        stackTrace: s,
      );
      _loadingNotifer.isLoading = false;
      return false;
    }
  }

  Future<bool> onRegisterPressed() async {
    if (email.trim().isEmpty || password.isEmpty) {
      _errorNotifier.setError(
        message: 'Please fill in both fields',
      );
      return false;
    }

    try {
      _loadingNotifer.isLoading = true;

      UserCredential credential = await AuthService()
          .registerWithEmail(email: email.trim(), password: password);

      model.User user = model.User(
        id: credential.user!.uid,
        email: email.trim(),
        nickname: '',
      );

      FirestoreService().saveUserData(user: user);

      LocalStorage().user = user;

      _loadingNotifer.isLoading = false;

      return true;
    } on Exception catch (e, s) {
      _errorNotifier.setError(
        exception: e,
        stackTrace: s,
      );
      _loadingNotifer.isLoading = false;
      return false;
    }
  }
}
