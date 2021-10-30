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

import 'package:anonymous_chat/mappers/chat_room_mapper.dart';
import 'package:anonymous_chat/mappers/message_mapper.dart';
import 'package:anonymous_chat/models/chat_room.dart';
import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/utilities/enums.dart';
import 'package:flutter/material.dart';

class RoomsSyncer {
  static final RoomsSyncer _instance = RoomsSyncer._internal();
  factory RoomsSyncer() => _instance;
  RoomsSyncer._internal();

  final ChatRoomsMapper _roomsMapper = ChatRoomsMapper();
  final MessageMapper _messageMapper = MessageMapper();

  void onUserLogin(List<ChatRoom> rooms, String userId) async {
    for (var room in rooms) {
      await _roomsMapper.saveUserRoom(
          room: room, userId: userId, source: SetDataSource.LOCAL);
    }
  }

  Future<bool> syncRooms(List<ChatRoom> onlineRooms, List<ChatRoom> localRooms,
      String userId) async {
    bool didModify = false;

    List<RoomSyncingAction> actions =
        getSyncingActions(localRooms, onlineRooms);

    for (RoomSyncingAction action in actions) {
      switch (action.type) {
        case ActionType.NONE:
          break;

        case ActionType.MESSAGES_OUT_OF_SYNC:
          didModify = true;
          for (Message m in action.messagesToWrite) {
            await _messageMapper.writeMessage(
              roomId: action.room.id,
              message: m,
              source: SetDataSource.LOCAL,
            );
          }

          for (Message m in action.messagesToDelete) {
            await _messageMapper.deleteMessage(m.id);
          }
          break;

        case ActionType.ROOM_MISSING:
          didModify = true;
          await _roomsMapper.saveUserRoom(
            room: action.room,
            userId: userId,
            source: SetDataSource.LOCAL,
          );
          break;
      }
    }

    return didModify;
  }
}

@visibleForTesting
List<RoomSyncingAction> getSyncingActions(
    List<ChatRoom> localList, List<ChatRoom> onlineList) {
  List<RoomSyncingAction> result = [];

  onlineList.forEach((ChatRoom onlineRoom) {
    int index = localList.indexOf(onlineRoom);
    if (index == -1) {
      result.add(RoomSyncingAction.missing(onlineRoom));
    } else {
      ChatRoom localRoom = localList[index];

      // Check if msgs are in sync
      if (localRoom.messages.length != onlineRoom.messages.length ||
          localRoom.messages.last != onlineRoom.messages.last) {
        List<Message> pendingWrites = [];
        List<Message> pendingDeletes = [];

        for (int i = onlineRoom.messages.length - 1; i >= 0; i--) {
          if (!localRoom.messages.contains(onlineRoom.messages[i]))
            pendingWrites.add(onlineRoom.messages[i]);
        }

        for (int i = 0; i < localRoom.messages.length; i++) {
          if (!onlineRoom.messages.contains(localRoom.messages[i]))
            pendingDeletes.add(localRoom.messages[i]);

          // // Check for duplicates too
          // bool isDuplicated = localRoom.messages
          //         .where((m) => m == localRoom.messages[i])
          //         .length >
          //     1;
        }

        if (pendingWrites.isNotEmpty || pendingDeletes.isNotEmpty)
          result.add(RoomSyncingAction.unsyncedMsgs(
              onlineRoom, [...pendingWrites], [...pendingDeletes]));
        else
          result.add(RoomSyncingAction.synced(onlineRoom));

        pendingWrites.clear();
        pendingDeletes.clear();
      }
    }
  });

  return result;
}

enum ActionType {
  NONE,
  MESSAGES_OUT_OF_SYNC,
  ROOM_MISSING,
}

@visibleForTesting
class RoomSyncingAction {
  final List<Message> messagesToWrite;
  final List<Message> messagesToDelete;
  final bool isRoomMissing;
  final bool inSync;
  final ActionType type;
  final ChatRoom room;

  RoomSyncingAction._internal(
    this.messagesToWrite,
    this.messagesToDelete,
    this.isRoomMissing,
    this.inSync,
    this.room,
    this.type,
  );

  factory RoomSyncingAction.synced(ChatRoom room) =>
      RoomSyncingAction._internal(
        [],
        [],
        false,
        true,
        room,
        ActionType.NONE,
      );

  factory RoomSyncingAction.unsyncedMsgs(ChatRoom room,
          List<Message> msgsToWrite, List<Message> msgsToDelete) =>
      RoomSyncingAction._internal(
        msgsToWrite,
        msgsToDelete,
        false,
        false,
        room,
        ActionType.MESSAGES_OUT_OF_SYNC,
      );

  factory RoomSyncingAction.missing(ChatRoom room) =>
      RoomSyncingAction._internal(
        room.messages,
        [],
        true,
        false,
        room,
        ActionType.ROOM_MISSING,
      );
}
