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
import 'package:anonymous_chat/interfaces/prefs_storage_interface.dart';
import 'package:anonymous_chat/mappers/chat_room_mapper.dart';
import 'package:anonymous_chat/models/chat_room.dart';
import 'package:anonymous_chat/models/local_user.dart';
import 'package:anonymous_chat/providers/starting_data_provider.dart';
import 'package:anonymous_chat/providers/user_auth_events_provider.dart';
import 'package:anonymous_chat/services.dart/algolia.dart';
import 'package:anonymous_chat/services.dart/authentication.dart';
import 'package:anonymous_chat/services.dart/push_notificaitons.dart';
import 'package:anonymous_chat/services.dart/shared_preferences.dart';
import 'package:anonymous_chat/services.dart/sqlite.dart';
import 'package:anonymous_chat/utilities/enums.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Returns if the user is authenticated or not
final appInitialzationProvider = FutureProvider.autoDispose<UserState>(
  (ref) async {
    await Firebase.initializeApp();
    // await SqlitePersistance().deleteAccount(userId:  FirebaseAuthService().getUser()!.uid);
    // await FirebaseAuthService().signOut();
    await SharedPrefs.init();
    // await ILocalPrefs.storage.setUser(null);
    await dotenv.load(fileName: '.env');
    await NotificationsService.init(ILocalPrefs.storage.user?.id);
    await SqlitePersistance.init();
    await AlgoliaSearch.init();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    IDatabase onlineDb = IDatabase.onlineDb;
    ILocalPrefs storage = ILocalPrefs.storage;
    IAuth auth = IAuth.auth as FirebaseAuthService;

    User? user = auth.getUser();
    LocalUser? userData =
        user == null ? null : (await onlineDb.getUserData(id: user.uid));

    if (user == null || userData == null) return UserState.NOT_AUTHENTICATTED;

    if (userData.isNicknamed) {
      // Update local user in case it's missing (due to uninstalling app)
      if (storage.user == null || storage.user != userData) {
        storage.setUser(userData);
      }
      ref.read(userAuthEventsProvider.notifier).user = userData;

      // Load the local chats here to directly display them in chats screen
      List<ChatRoom> rooms = await ChatRoomsMapper().getUserRooms(
        userId: user.uid,
        source: GetDataSource.LOCAL,
      );

      ref.read(startingDataProvider.notifier).room = rooms;

      return UserState.AUTHENTICATETD_AND_NICKNAMED;
    } else {
      return UserState.AUTHENTICATED_NOT_NICKNAMED;
    }
  },
);
