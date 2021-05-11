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

import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/providers/user_rooms_provider.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';

final archivedRoomsProvider = StateNotifierProvider.autoDispose(
  (ref) => ArchivedRoomsNotifier(
      errorNotifier: ref.read(errorsProvider),
      userRooms: ref.watch(userRoomsProvider).data?.value),
);

class ArchivedRoomsNotifier extends StateNotifier<List<Room>?> {
  final List<Room>? userRooms;

  ArchivedRoomsNotifier({
    required this.errorNotifier,
    required this.userRooms,
  }) : super(null) {
    init();
  }

  final ErrorNotifier errorNotifier;
  final firestore = FirestoreService();
  final storage = LocalStorage();

  List<Room>? archivedRooms = [];

  void init() async {
    try {
      Map<String, dynamic> data =
          await firestore.getUserData(id: storage.user!.id);
      User user = User.fromMap(data);

      if (userRooms == null) {
        state = null;
        return;
      } else if (userRooms!.isEmpty) {
        state = [];
        return;
      } else
        archivedRooms = userRooms
            ?.where((room) => user.archivedRooms.contains(room.id))
            .toList();

      state = archivedRooms;
    } on Exception catch (e, s) {
      Future.delayed(Duration(seconds: 2)).then((value) => init());

      errorNotifier.submitError(exception: e, stackTrace: s);
    }
  }

  void editArchives({required Room room, required bool archive}) {
    try {
      if (archive) {
        firestore.archiveChat(userId: storage.user!.id, roomId: room.id);
        archivedRooms!.add(room);
        state = archivedRooms;
      } else {
        firestore.unArchiveChat(userId: storage.user!.id, roomId: room.id);
        archivedRooms!.remove(room);
        state = archivedRooms;
      }
    } on Exception catch (e, s) {
      Future.delayed(Duration(seconds: 2))
          .then((value) => editArchives(room: room, archive: archive));

      errorNotifier.submitError(exception: e, stackTrace: s);
    }
  }
}
