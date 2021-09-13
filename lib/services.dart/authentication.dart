// Copyright 2021 Hadi Hammoud
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:anonymous_chat/interfaces/auth_interface.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService
    implements IAuth<AuthCredential, User?, UserCredential> {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();

  factory FirebaseAuthService() => _instance;

  FirebaseAuthService._internal();

  FirebaseAuth _authInstance = FirebaseAuth.instance;

  @override
  Future<UserCredential> signInWithPhoneCredential({
    PhoneAuthCredential? credential,
    String? verificationId,
    String? code,
  }) async {
    return await _authInstance.signInWithCredential(
      credential != null
          ? credential
          : PhoneAuthProvider.credential(
              verificationId: verificationId!,
              smsCode: code!,
            ),
    );
  }

  @override
  Future<void> verifyPhoneNumber({
    required String number,
    required Function(FirebaseAuthException p1) onVerificaitonFailed,
    required Function(String verificationId, int? resendingToken) onCodeSent,
    required Function(PhoneAuthCredential) onVerificationCompleted,
  }) async {
    _authInstance.verifyPhoneNumber(
      phoneNumber: number,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificaitonFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  @override
  User? getUser() => _authInstance.currentUser;

  @override
  Future<void> signOut() => _authInstance.signOut();

  // @override
  // Future<UserCredential> linkUserWithCredential(
  //     AuthCredential credential) async {
  //   return await _authInstance.currentUser!.linkWithCredential(credential);
  // }
}
