import 'package:anonymous_chat/models/activity_status.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/providers/loading_provider.dart';
import 'package:anonymous_chat/services.dart/authentication.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/models/user.dart' as model;
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:anonymous_chat/providers/activity_status_provider.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = ChangeNotifierProvider(
  (ref) => _AuthProcessNotifier(
    ref.read,
  ),
);

class _AuthProcessNotifier extends ChangeNotifier {
  late ErrorNotifier _errorNotifier;
  late LoadingNotifer _loadingNotifer;
  final Reader read;

  String email = '';
  String password = '';

  _AuthProcessNotifier(
    this.read,
  ) {
    _errorNotifier = read(errorsProvider);
    _loadingNotifer = read(loadingProvider);
  }

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

      await read(userActivityStateProvider).set(
        activityStatus: ActivityStatus.offline(
            lastSeen: DateTime.now().millisecondsSinceEpoch),
      );

      await AuthService().signOut();

      await LocalStorage().setUser(null);

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

      await LocalStorage().setUser(user);

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
        blockedUsers: [],
        activeTags: [],
        archivedRooms: [],
        email: email.trim(),
        nickname: '',
      );

      await FirestoreService().saveUserData(user: user);

      await LocalStorage().setUser(user);

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

  Future<bool> onDeleteAccountPressed() async {
    try {
      _loadingNotifer.isLoading = true;

      await read(userActivityStateProvider).set(
        activityStatus: ActivityStatus.offline(
            lastSeen: DateTime.now().millisecondsSinceEpoch),
      );
      await FirestoreService().deleteAccount(userId: LocalStorage().user!.id);
      await AuthService().signOut();
      await LocalStorage().setUser(null);

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
