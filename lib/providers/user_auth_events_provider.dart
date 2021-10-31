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

import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/mappers/chat_room_mapper.dart';
import 'package:anonymous_chat/models/chat_room.dart';
import 'package:anonymous_chat/models/local_user.dart';
import 'package:anonymous_chat/interfaces/auth_interface.dart';
import 'package:anonymous_chat/interfaces/prefs_storage_interface.dart';
import 'package:anonymous_chat/providers/starting_data_provider.dart';
import 'package:anonymous_chat/services.dart/push_notificaitons.dart';
import 'package:anonymous_chat/syncer/rooms_syncer.dart';
import 'package:anonymous_chat/utilities/enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// This is watched by providers that need to re-evaluate their state after auth changes
final userAuthEventsProvider =
    StateNotifierProvider<UserAuthNotifier, LocalUser?>(
  (ref) => UserAuthNotifier(ref.read),
);

class UserAuthNotifier extends StateNotifier<LocalUser?> {
  UserAuthNotifier(this.read) : super(ILocalPrefs.storage.user);
  Reader read;
  final auth = IAuth.auth;

  set user(LocalUser user) => state = user;

  Future<void> onLogin(LocalUser user, bool isNew) async {
    await ILocalPrefs.storage.setUser(user);
    await NotificationsService.initMessagingTokens(user.id);
    if (isNew) {
      await IDatabase.onlineDb.saveUserData(user: user);
      read(startingDataProvider.notifier).room = [];
    } else {
      List<ChatRoom> userRooms = await ChatRoomsMapper()
          .getUserRooms(userId: user.id, source: GetDataSource.ONLINE);
      RoomsSyncer().onUserLogin(userRooms, user.id);
      read(startingDataProvider.notifier).room = userRooms;
    }
    state = user;
  }

  Future<void> onLogout(String id) async {
    await ILocalPrefs.storage.setUser(null);
    await ILocalPrefs.storage.setSyncingDate(0);
    await IDatabase.offlineDb.deleteAccount(userId: id);
    state = null;
  }
}
