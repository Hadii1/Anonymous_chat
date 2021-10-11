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
import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/interfaces/local_storage_interface.dart';
import 'package:anonymous_chat/models/local_user.dart';
import 'package:anonymous_chat/providers/user_auth_events_provider.dart';
import 'package:anonymous_chat/providers/user_rooms_provider.dart';
import 'package:anonymous_chat/services.dart/algolia.dart';
import 'package:anonymous_chat/services.dart/authentication.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:anonymous_chat/services.dart/push_notificaitons.dart';
import 'package:anonymous_chat/utilities/enums.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Returns if the user is authenticated or not
final appInitialzationProvider =
    FutureProvider.autoDispose<UserState>((ref) async {
  await Firebase.initializeApp();
  await SharedPrefs.init();
  await AlgoliaSearch.init();
  await NotificationsService.init();

  // await FirebaseAuthService().signOut();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  IDatabase db = IDatabase.onlineDb;
  ILocalPrefs storage = ILocalPrefs.storage;
  IAuth auth = IAuth.auth as FirebaseAuthService;

  User? user = auth.getUser();
  if (user == null) return UserState.NOT_AUTHENTICATTED;

  LocalUser localUser = (await db.getUserData(id: user.uid))!;

  if (localUser.isNicknamed) {
    // Update local user in case it's missing (due to uninstalling app)
    if (storage.user == null || storage.user != localUser) {
      storage.setUser(localUser);
    }
    ref.read(userAuthEventsProvider.notifier).user = localUser;

    // Load the local chats here to directly display them in chats screen
    ref.read(localUserRoomsFuture);

    return UserState.AUTHENTICATETD_AND_NICKNAMED;
  } else {
    return UserState.AUTHENTICATED_NOT_NICKNAMED;
  }
});
