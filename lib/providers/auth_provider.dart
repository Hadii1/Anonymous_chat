import 'dart:io';

import 'package:anonymous_chat/interfaces/auth_interface.dart';
import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/interfaces/local_storage_interface.dart';
import 'package:anonymous_chat/database_entities/user_entity.dart' as _local;
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/providers/loading_provider.dart';
import 'package:anonymous_chat/services.dart/authentication.dart';
import 'package:anonymous_chat/utilities/general_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/foundation.dart';

// 76868011
enum DestinationAfterSuccessfulAuth {
  NameGeneratorScreen,
  HomeScreen,
}

final destinationScreenProvider = StateNotifierProvider.autoDispose<
    DesitnationState, DestinationAfterSuccessfulAuth?>(
  (_) => DesitnationState(),
);

class DesitnationState extends StateNotifier<DestinationAfterSuccessfulAuth?> {
  DesitnationState() : super(null);

  void set(DestinationAfterSuccessfulAuth destination) => state = destination;
}

final phoneVerificationProvider = ChangeNotifierProvider.autoDispose(
  (ref) => PhoneVerificationNotifier(
    ref.read(errorsStateProvider.notifier),
    ref.read(loadingProvider.notifier),
    ref.read(destinationScreenProvider.notifier),
  ),
);

class PhoneVerificationNotifier extends ChangeNotifier {
  final ErrorsNotifier _errorNotifier;
  final LoadingNotifier _loadingNotifier;
  final DesitnationState _desitnationNotifier;

  final FirebaseAuthService _auth = (IAuth.auth as FirebaseAuthService);
  final IDatabase _db = IDatabase.databseService;
  final ILocalStorage _storage = ILocalStorage.storage;

  String number = '';

  bool isCodeSent = false;

  String? _verificationId;

  PhoneVerificationNotifier(
    this._errorNotifier,
    this._loadingNotifier,
    this._desitnationNotifier,
  );

  void onSendCodePressed() {
    _loadingNotifier.loading = true;
    if (number.isEmpty) {
      _errorNotifier.set('Number field required');
      _loadingNotifier.loading = false;
      return;
    }

    number = '+1' + number;
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
      late UserCredential credential;

      credential = phoneAuthCredential != null
          ? await _auth.signInWithPhoneCredential(
              credential: phoneAuthCredential)
          : await _auth.signInWithPhoneCredential(
              verificationId: _verificationId!,
              code: code!,
            );

      Map<String, dynamic>? userData;
      bool isNewUser = credential.additionalUserInfo!.isNewUser;

      if (!isNewUser)
        userData = await _db.getUserData(id: credential.user!.uid);

      if (isNewUser || userData == null) {
        // _local.User user = _local.User(
        //   phoneNumber: number,
        //   id: credential.user!.uid,
        // );

        // await retry(
        //   f: () async {
        //     _db.saveUserData(
        //       user: user,
        //     );
        //   },
        // );

        // await _storage.setUser(user);

        _desitnationNotifier
            .set(DestinationAfterSuccessfulAuth.NameGeneratorScreen);
      } else {
        _local.User user = _local.User.fromMap(userData);

        await _storage.setUser(user);

        _desitnationNotifier.set(DestinationAfterSuccessfulAuth.HomeScreen);
      }

      notifyListeners();
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
