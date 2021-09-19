import 'dart:io';

import 'package:anonymous_chat/database_entities/user_entity.dart';
import 'package:anonymous_chat/interfaces/auth_interface.dart';
import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/providers/loading_provider.dart';
import 'package:anonymous_chat/services.dart/authentication.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/foundation.dart';

final navigationSignal =
    StateNotifierProvider.autoDispose<NavigationSignalNotifier, bool>(
  (_) => NavigationSignalNotifier(),
);

class NavigationSignalNotifier extends StateNotifier<bool> {
  NavigationSignalNotifier() : super(false);

  set navigate(bool navigate) => state = navigate;
}

final phoneVerificationProvider = ChangeNotifierProvider.autoDispose(
  (ref) => PhoneVerificationNotifier(
    ref.read(errorsStateProvider.notifier),
    ref.read(loadingProvider.notifier),
    ref.read(navigationSignal.notifier),
  ),
);

class PhoneVerificationNotifier extends ChangeNotifier {
  final ErrorsNotifier _errorNotifier;
  final LoadingNotifier _loadingNotifier;
  final NavigationSignalNotifier _navigationSignal;

  final FirebaseAuthService _auth = (IAuth.auth as FirebaseAuthService);

  String number = '';

  bool isCodeSent = false;

  String? _verificationId;

  PhoneVerificationNotifier(
    this._errorNotifier,
    this._loadingNotifier,
    this._navigationSignal,
  );

  void onSendCodePressed() {
    _loadingNotifier.loading = true;
    if (number.isEmpty) {
      _errorNotifier.set('Number field required');
      _loadingNotifier.loading = false;
      return;
    }

    number.trim();

    _auth.verifyPhoneNumber(
      number: number,
      onVerificaitonFailed: (FirebaseAuthException e) {
        print(e.code);
        print(e.message);
        _errorNotifier.set(
          e.code == 'invalid-phone-number'
              ? 'Invalid phone number.\nPlease make sure the number you entered is correct.'
              : e.code == 'too-many-requests'
                  ? ('Too many requests!\nTry again in a while.')
                  : 'Something went wrong.\nTry again please.',
        );
        _verificationId = null;
        isCodeSent = false;
        notifyListeners();
        _loadingNotifier.loading = false;
      },
      onCodeSent: (String verificationId, int? resendingToken) {
        print('code sent');
        _loadingNotifier.loading = false;
        _verificationId = verificationId;
        isCodeSent = true;
        notifyListeners();
      },
      onVerificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
        // ANDROID ONLY! Automatic handling of the received code.
        print('verificaiton complete');
        onCodeSubmitted(phoneAuthCredential: phoneAuthCredential);
      },
    );
  }

  void onCodeSubmitted({
    String? code,
    PhoneAuthCredential? phoneAuthCredential,
  }) async {
    _loadingNotifier.loading = true;

    try {
      assert((code == null && phoneAuthCredential == null) == false);
      UserCredential credentail = phoneAuthCredential != null
          ? await _auth.signInWithPhoneCredential(
              credential: phoneAuthCredential)
          : await _auth.signInWithPhoneCredential(
              verificationId: _verificationId!,
              code: code!,
            );

      IDatabase db = IDatabase.databseService;
      await db.saveUserData(
        user: LocalUser.newlyCreated(
          id: credentail.user!.uid,
          phoneNumber: number,
        ),
      );

      _navigationSignal.navigate = true;
    } on Exception catch (e) {
      if (e is FirebaseAuthException && e.code == 'invalid-verification-code')
        _errorNotifier.set('Invalid code.');
      else if (e is FirebaseAuthException && e.code == 'too-many-requests')
        _errorNotifier.set('Too many requests!\nTry again in a while.');
      else if (e is SocketException)
        _errorNotifier
            .set('Bad Internet Connection.\nTry resubmitting the code.');
      else
        _errorNotifier.set('Unknown error occured.');

      await _auth.signOut();
    } finally {
      _loadingNotifier.loading = false;
    }
  }

  void onEditNumberPressed() {
    isCodeSent = false;
    _verificationId = null;
    notifyListeners();
  }
}
