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

import 'package:anonymous_chat/interfaces/online_database_interface.dart';
import 'package:anonymous_chat/interfaces/local_storage_interface.dart';
import 'package:anonymous_chat/utilities/general_functions.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final archivedRoomsFuture =
    FutureProvider.autoDispose<List<String>>((ref) async {
  ref.maintainState = true;

  final IDatabase db = IDatabase.db;
  final ILocalStorage storage = ILocalStorage.storage;

  List<String> userArchivedRooms =
      await db.getUserArchivedRooms(userId: storage.user!.id);

  ref.read(archivedRoomsProvider.notifier).archivedRooms = userArchivedRooms;
  return userArchivedRooms;
});

final archivedRoomsProvider =
    StateNotifierProvider<ArchivedRoomsNotifier, List<String>?>(
  (ref) => ArchivedRoomsNotifier(),
);

class ArchivedRoomsNotifier extends StateNotifier<List<String>?> {
  ArchivedRoomsNotifier() : super(null);

  final IDatabase db = IDatabase.db;
  final ILocalStorage storage = ILocalStorage.storage;

  set archivedRooms(List<String> rooms) => state = rooms;

  void editArchives({required String roomId, required bool archive}) {
    if (archive) {
      state!.add(roomId);
      state = state;
      retry(f: () => db.archiveChat(userId: storage.user!.id, roomId: roomId));
    } else {
      state!.remove(roomId);
      state = state;
      retry(
          f: () => db.unArchiveChat(userId: storage.user!.id, roomId: roomId));
    }
  }
}
