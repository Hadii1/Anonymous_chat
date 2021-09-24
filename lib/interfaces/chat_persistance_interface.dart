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

import 'package:anonymous_chat/database_entities/room_entity.dart';
import 'package:anonymous_chat/models/message.dart';

abstract class DataRepository {
  Future<void> saveNewRoom({required RoomEntity roomEntity});
  Future<void> writeMessage({required String roomId, required Message message});
  Future<List<Map<String, dynamic>>> getUserRooms({required String userId});
  Future<List<String>> getUserArchivedRooms({required String userId});
  Future<List<String>> getBlockedContacts({required String userId});
  Future<List<Map<String, dynamic>>> getAllMessages({required String roomId});
  Future<void> archiveChat({required String userId, required String roomId});
  Future<void> unArchiveChat({required String userId, required String roomId});
  Future<void> deleteChat({required String roomId});
  Future<void> blockUser({required String client, required String other});
  Future<void> unblockUser({required String client, required String other});
}
