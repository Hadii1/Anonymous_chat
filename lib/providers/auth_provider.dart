import 'dart:io';

import 'package:anonymous_chat/interfaces/auth_interface.dart';
import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/interfaces/prefs_storage_interface.dart';
import 'package:anonymous_chat/models/local_user.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/providers/loading_provider.dart';
import 'package:anonymous_chat/providers/user_auth_events_provider.dart';
import 'package:anonymous_chat/services.dart/authentication.dart';
import 'package:anonymous_chat/utilities/enums.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationSignal = StateNotifierProvider.autoDispose<
    NavigationSignalNotifier, DestinationAfterAuth?>(
  (_) => NavigationSignalNotifier(),
);

class NavigationSignalNotifier extends StateNotifier<DestinationAfterAuth?> {
  NavigationSignalNotifier() : super(null);

  set navigate(DestinationAfterAuth navigate) => state = navigate;
}

final authProvider = ChangeNotifierProvider.autoDispose(
  (ref) => PhoneVerificationNotifier(
    ref.read(errorsStateProvider.notifier),
    ref.read(loadingProvider.notifier),
    ref.read(navigationSignal.notifier),
    ref.read(userAuthEventsProvider.notifier),
  ),
);

class PhoneVerificationNotifier extends ChangeNotifier {
  final ErrorsNotifier _errorNotifier;
  final LoadingNotifier _loadingNotifier;
  final NavigationSignalNotifier _navigationSignal;
  final ILocalPrefs prefs = ILocalPrefs.storage;
  final FirebaseAuthService _auth = (IAuth.auth as FirebaseAuthService);

  final UserAuthNotifier _authNotifier;

  String number = '';

  bool isCodeSent = false;

  String? _verificationId;

  PhoneVerificationNotifier(
    this._errorNotifier,
    this._loadingNotifier,
    this._navigationSignal,
    this._authNotifier,
  );

  void onSendCodePressed() {
    _loadingNotifier.loading = true;
    if (number.substring(0, 1) != '+') {
      number = '+' + number;
    }
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
              credential: phoneAuthCredential,
            )
          : await _auth.signInWithPhoneCredential(
              verificationId: _verificationId!,
              code: code!,
            );

      bool isNewUser = credentail.additionalUserInfo!.isNewUser;

      LocalUser? onlineUser =
          await IDatabase.onlineDb.getUserData(id: credentail.user!.uid);

      if (isNewUser || onlineUser == null) {
        // User is tottaly new or the user
        // deleted his account then registered again
        // so we just treat it as new one
        LocalUser createdUser = LocalUser.newlyCreated(
          id: credentail.user!.uid,
          phoneNumber: number,
        );
        await _authNotifier.onLogin(createdUser, true);
        _navigationSignal.navigate = DestinationAfterAuth.NAME_GENERATOR_SCREEN;
      } else {
        // Logging in
        await _authNotifier.onLogin(onlineUser, false);
        _navigationSignal.navigate = onlineUser.isNicknamed
            ? DestinationAfterAuth.HOME_SCREEN
            : DestinationAfterAuth.NAME_GENERATOR_SCREEN;
      }
    } on Exception catch (e) {
      print(e);
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
