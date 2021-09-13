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
import 'package:anonymous_chat/interfaces/local_storage_interface.dart';
import 'package:anonymous_chat/providers/user_rooms_provider.dart';
import 'package:anonymous_chat/utilities/general_functions.dart';
import 'package:anonymous_chat/models/room.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final archivedRoomsProvider =
    StateNotifierProvider<ArchivedRoomsNotifier, List<Room>?>(
  (ref) => ArchivedRoomsNotifier(
    userRooms: ref.watch(userRoomsProvider),
  ),
);

class ArchivedRoomsNotifier extends StateNotifier<List<Room>?> {
  final List<Room>? userRooms;

  ArchivedRoomsNotifier({
    required this.userRooms,
  }) : super(null) {
    init();
  }

  final db = IDatabase.databseService;
  final storage = ILocalStorage.storage;

  List<Room>? archivedRooms = [];

  void init() async {
    retry(f: () async {
      if (userRooms == null) {
        state = null;
        return;
      } else if (userRooms!.isEmpty) {
        state = [];
        return;
      } else {
        List<String> userArchivedRooms =
            await db.getUserArchivedRooms(userId: storage.user!.id);

        archivedRooms = userRooms
            ?.where((room) => userArchivedRooms.contains(room.id))
            .toList();

        state = archivedRooms;
      }
    });
  }

  void editArchives({required Room room, required bool archive}) {
    if (archive) {
      retry(f: () => db.archiveChat(userId: storage.user!.id, roomId: room.id));
      archivedRooms!.add(room);
      state = archivedRooms;
    } else {
      retry(
          f: () => db.unArchiveChat(userId: storage.user!.id, roomId: room.id));
      archivedRooms!.remove(room);
      state = archivedRooms;
    }
  }
}
