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

import 'package:anonymous_chat/interfaces/prefs_storage_interface.dart';
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
  final String userId = ILocalPrefs.storage.user!.id;

  void onUserLogin(List<ChatRoom> rooms) async {
    for (var room in rooms) {
      await _roomsMapper.saveUserRoom(
          room: room, userId: userId, source: SetDataSource.LOCAL);
    }
  }

  Future<bool> syncRooms(
      List<ChatRoom> onlineRooms, List<ChatRoom> localRooms) async {
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
        for (int i = onlineRoom.messages.length - 1; i >= 0; i--) {
          if (!localRoom.messages.contains(onlineRoom.messages[i])) {
            pendingWrites.add(onlineRoom.messages[i]);
          }
        }

        if (pendingWrites.isNotEmpty)
          result.add(
              RoomSyncingAction.unsyncedMsgs(onlineRoom, [...pendingWrites]));
        else
          result.add(RoomSyncingAction.synced(onlineRoom));

        pendingWrites.clear();
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
  // final List<Message> messagesToWrite;
  final bool isRoomMissing;
  final bool inSync;
  final ActionType type;
  final ChatRoom room;

  RoomSyncingAction._internal(
    this.messagesToWrite,
    this.isRoomMissing,
    this.inSync,
    this.room,
    this.type,
  );

  factory RoomSyncingAction.synced(ChatRoom room) =>
      RoomSyncingAction._internal(
        [],
        false,
        true,
        room,
        ActionType.NONE,
      );

  factory RoomSyncingAction.unsyncedMsgs(
          ChatRoom room, List<Message> msgsToWrite) =>
      RoomSyncingAction._internal(
        msgsToWrite,
        false,
        false,
        room,
        ActionType.MESSAGES_OUT_OF_SYNC,
      );

  factory RoomSyncingAction.missing(ChatRoom room) =>
      RoomSyncingAction._internal(
        room.messages,
        true,
        false,
        room,
        ActionType.ROOM_MISSING,
      );
}
