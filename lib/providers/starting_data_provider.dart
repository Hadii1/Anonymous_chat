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

import 'package:anonymous_chat/models/chat_room.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final startingDataProvider =
    StateNotifierProvider<StartingData, List<ChatRoom>?>((_) => StartingData());

class StartingData extends StateNotifier<List<ChatRoom>?> {
  StartingData() : super(null);
  // Returns success or not
  // Future<bool> init() async {
  //   try {
  //     List<ChatRoom>? localRooms = await retry<List<ChatRoom>>(
  //       f: () async => await ChatRoomsMapper().getUserRooms(
  //         userId: ILocalPrefs.storage.user!.id,
  //         source: GetDataSource.LOCAL,
  //       ),
  //     );
  //     state = localRooms;
  //     return true;
  //   } on Exception catch (e) {
  //     print(e);
  //     return false;
  //   }
  // }

  set room(List<ChatRoom> rooms) => state = rooms;
}
