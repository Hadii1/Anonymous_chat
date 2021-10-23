// // Copyright 2021 Hadi Hammoud
// //
// // Licensed under the Apache License, Version 2.0 (the "License");
// // you may not use this file except in compliance with the License.
// // You may obtain a copy of the License at
// //
// //     http://www.apache.org/licenses/LICENSE-2.0
// //
// // Unless required by applicable law or agreed to in writing, software
// // distributed under the License is distributed on an "AS IS" BASIS,
// // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// // See the License for the specific language governing permissions and
// // limitations under the License.

// import 'package:anonymous_chat/interfaces/local_storage_interface.dart';
// import 'package:anonymous_chat/models/chat_room.dart';
// import 'package:anonymous_chat/providers/user_rooms_provider.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final archivedRoomsProvider =
//     StateNotifierProvider<ArchivedRoomsNotifier, List<ChatRoom>>(
//   (ref) => ArchivedRoomsNotifier(
//     ref.watch(userRoomsProvider).where((r) => r.isArchived).toList(),
//   ),
// );

// class ArchivedRoomsNotifier extends StateNotifier<List<ChatRoom>> {
//   final String userId = ILocalPrefs.storage.user!.id;

//   ArchivedRoomsNotifier(List<ChatRoom> value) : super(value);

//   void archive(ChatRoom room) {
//     state = [...state, room];
//   }

//   void unArchive(ChatRoom room) {
//     state.remove(room);
//     state = [...state];
//   }
// }
