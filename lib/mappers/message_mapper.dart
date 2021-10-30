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
import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/utilities/enums.dart';
import 'package:tuple/tuple.dart';

class MessageMapper {
  static final MessageMapper _instance = MessageMapper._internal();

  factory MessageMapper() => _instance;

  MessageMapper._internal();

  final IDatabase<LocalRoomEntity> offlineDb = IDatabase.offlineDb;
  final IDatabase<OnlineRoomEntity> onlineDb = IDatabase.onlineDb;

  Stream<Tuple2<Message, MessageServeUpdateType>?> serverMessagesUpdates(
      {required String roomId, required String userId}) {
    return onlineDb
        .roomMessagesUpdates(roomId: roomId)
        .map((Tuple2<Message, DataChangeType> event) {
      Message message = event.item1;
      MessageServeUpdateType? type;
      if (event.item2 == DataChangeType.ADDED && message.isReceived(userId))
        type = MessageServeUpdateType.MESSAGE_RECEIVED;
      else if (event.item2 == DataChangeType.MODIFIED && message.isSent(userId))
        type = MessageServeUpdateType.MESSAGE_READ;
      // else if (event.item2 == DataChangeType. && message.isSent(userId))
      // type = MessageServeUpdateType.MESSAGE_READ;
      if (type != null) return Tuple2(message, type);
      return null;
    });
  }

  Future<List<Message>> getRoomMessages(
      String roomId, GetDataSource source) async {
    if (source == GetDataSource.LOCAL) {
      List<Message> entities = await offlineDb.getAllMessages(roomId: roomId);
      return entities;
    } else {
      List<Message> entities = await onlineDb.getAllMessages(roomId: roomId);
      return entities;
    }
  }

  Future<void> writeMessage({
    required String roomId,
    required Message message,
    required SetDataSource source,
  }) async {
    if (source == SetDataSource.BOTH || source == SetDataSource.LOCAL) {
      await offlineDb.writeMessage(
        roomId: roomId,
        message: message,
      );
    }
    if (source == SetDataSource.BOTH || source == SetDataSource.ONLINE) {
      await onlineDb.writeMessage(
        roomId: roomId,
        message: message,
      );
    }
  }

  Future<void> deleteMessage(String id) async {
    await offlineDb.deleteMessage(id);
  }

  Future<void> markMessageAsRead({
    required String messageId,
    required String roomId,
    SetDataSource source = SetDataSource.BOTH,
  }) async {
    if (source == SetDataSource.BOTH || source == SetDataSource.LOCAL) {
      await offlineDb.markMessageAsRead(roomId: roomId, messageId: messageId);
    }
    if (source == SetDataSource.BOTH || source == SetDataSource.ONLINE) {
      await onlineDb.markMessageAsRead(roomId: roomId, messageId: messageId);
    }
  }
}
