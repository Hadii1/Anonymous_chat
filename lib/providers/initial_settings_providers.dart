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

import 'package:anonymous_chat/database_entities/user_entity.dart';
import 'package:anonymous_chat/interfaces/auth_interface.dart';
import 'package:anonymous_chat/interfaces/online_database_interface.dart';
import 'package:anonymous_chat/interfaces/local_storage_interface.dart';
import 'package:anonymous_chat/providers/user_auth_events_provider.dart';
import 'package:anonymous_chat/services.dart/algolia.dart';
import 'package:anonymous_chat/services.dart/authentication.dart';
import 'package:anonymous_chat/services.dart/push_notificaitons.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:anonymous_chat/utilities/general_functions.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/services.dart';

// Returns if the user is authenticated or not
final appInitialzationProvider = FutureProvider.autoDispose<bool>((ref) async {
  await Firebase.initializeApp();
  await SharedPrefs.init();
  await AlgoliaSearch.init();
  await NotificationsService.init();

  // await FirebaseAuthService().signOut();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  return FirebaseAuthService().getUser() != null;
});

// Check if the user info (nickname/dob/gender) are filled.
final userInfoProvider =
    StateNotifierProvider.autoDispose<UserInfoNotifier, bool?>(
        (ref) => UserInfoNotifier(ref.read));

class UserInfoNotifier extends StateNotifier<bool?> {
  UserInfoNotifier(this.read) : super(null) {
    init();
  }

  final Reader read;

  init() async {
    retry(f: () async {
      IDatabase db = IDatabase.db;
      ILocalStorage storage = ILocalStorage.storage;
      FirebaseAuthService auth = IAuth.auth as FirebaseAuthService;

      User user = auth.getUser()!;
      Map<String, dynamic> userData = await db.getUserData(id: user.uid)!;

      bool isDataComplete = LocalUser.isDataComplete(userData);

      if (isDataComplete) {
        LocalUser user = LocalUser.fromMap(userData);
        // Update local user in case it's missing (due to uninstalling app)
        if (storage.user == null || storage.user != user) {
          storage.setUser(user);
        }
        read(userAuthEventsProvider.notifier).user = user;
        state = true;
      } else
        state = false;
    });
  }
}
