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

  Future<void> syncRooms(
      List<ChatRoom> onlineRooms, List<ChatRoom> localRooms, String userId,
      {required int lastSyncDate}) async {
    List<RoomSyncingAction> actions = getSyncingActions(
      localRooms,
      onlineRooms,
      lastSyncDate,
    );

    for (RoomSyncingAction action in actions) {
      switch (action.type) {
        case ActionType.NONE:
          break;

        case ActionType.SYNC_MSGS:
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

          for (Message m in action.messagesToUpdate) {
            await _messageMapper.editReadStatus(
              messageId: m.id,
              roomId: action.room.id,
              isRead: m.isRead,
            );
          }
          break;

        case ActionType.ADD_ROOM:
          await _roomsMapper.saveUserRoom(
            room: action.room,
            userId: userId,
            source: SetDataSource.LOCAL,
          );
          break;
      }
    }
  }
}

@visibleForTesting
List<RoomSyncingAction> getSyncingActions(
  List<ChatRoom> localList,
  List<ChatRoom> onlineList,
  int lastSyncDate,
) {
  List<RoomSyncingAction> result = [];

  onlineList.forEach((ChatRoom onlineRoom) {
    int index = localList.map((e) => e.id).toList().indexOf(onlineRoom.id);
    if (index == -1) {
      // Room doesn't exist in the local database
      result.add(RoomSyncingAction.missing(onlineRoom));
    } else {
      ChatRoom localRoom = localList[index];

      List<Message> pendingWrites = [];
      List<Message> pendingDeletes = [];
      List<Message> pendingUpdates = [];

      // We only check the messages that weren't checked before.
      // We keep track of the last sync time in the prefrences strorge.
      List<Message> uncheckedLocalMsgs =
          List.from(localRoom.messages.where((m) => m.time > lastSyncDate));
      List<Message> uncheckedOnlineMsgs =
          List.from(onlineRoom.messages.where((m) => m.time > lastSyncDate));

      // Check if msgs are in sync
      //
      if (uncheckedLocalMsgs.isEmpty && uncheckedOnlineMsgs.isEmpty) {
        // No unsynced messages yet
        result.add(RoomSyncingAction.synced(onlineRoom));
      } else if (uncheckedLocalMsgs.isEmpty && uncheckedOnlineMsgs.isNotEmpty) {
        // There's new messages that are missings locally.
        for (Message m in uncheckedOnlineMsgs) {
          pendingWrites.add(m);
        }
        result.add(
            RoomSyncingAction.unsyncedMsgs(onlineRoom, pendingWrites, [], []));
      } else if (uncheckedLocalMsgs.isNotEmpty && uncheckedOnlineMsgs.isEmpty) {
        // There's added messages that are shouldn't be present locally.
        for (Message m in uncheckedLocalMsgs) {
          pendingDeletes.add(m);
        }
        result.add(
          RoomSyncingAction.unsyncedMsgs(onlineRoom, [], pendingDeletes, []),
        );
      } else if (uncheckedLocalMsgs.length != uncheckedOnlineMsgs.length ||
          uncheckedLocalMsgs.last != uncheckedOnlineMsgs.last) {
        // Start from the last message in the room and go backwards
        // Checking if each message exists or not.
        for (int i = uncheckedOnlineMsgs.length - 1; i >= 0; i--) {
          int index = uncheckedLocalMsgs.indexOf(uncheckedOnlineMsgs[i]);
          if (index == -1) {
            pendingWrites.add(uncheckedOnlineMsgs[i]);
          } else {
            // Go through messages to check if [isRead] status is synced
            if (uncheckedOnlineMsgs[i].isRead !=
                uncheckedLocalMsgs[index].isRead)
              pendingUpdates.add(uncheckedOnlineMsgs[i]);
          }
        }

        // Checking for any excess msgs found locally and not
        // not found in the online database.
        // This is theoretically impossible as we only
        // save the sent message locally after it was successfuly
        // sent to the server but nevertheless we're just acting defensively.
        for (int i = 0; i < uncheckedLocalMsgs.length; i++) {
          if (!uncheckedOnlineMsgs.contains(uncheckedLocalMsgs[i]))
            pendingDeletes.add(uncheckedLocalMsgs[i]);
        }

        result.add(RoomSyncingAction.unsyncedMsgs(
            onlineRoom, pendingWrites, pendingDeletes, pendingUpdates));
      } else {
        // Messages are in sync accroding to their numbers,
        // check the [isRead] status
        for (int i = 0; i < onlineRoom.messages.length; i++) {
          if (localRoom.messages[i].isRead != onlineRoom.messages[i].isRead) {
            pendingUpdates.add(onlineRoom.messages[i]);
          }
        }
        if (pendingUpdates.isNotEmpty)
          result.add(RoomSyncingAction.unsyncedMsgs(
              onlineRoom, [], [], pendingUpdates));
        else
          result.add(RoomSyncingAction.synced(onlineRoom));
      }

      pendingWrites.clear();
      pendingDeletes.clear();
    }
  });

  return result;
}

enum ActionType {
  NONE,
  SYNC_MSGS,
  ADD_ROOM,
}

@visibleForTesting
class RoomSyncingAction {
  final List<Message> messagesToWrite;
  final List<Message> messagesToDelete;
  final List<Message> messagesToUpdate;
  final bool isRoomMissing;
  final bool inSync;
  final ActionType type;
  final ChatRoom room;

  RoomSyncingAction._internal({
    required this.messagesToWrite,
    required this.messagesToDelete,
    required this.messagesToUpdate,
    required this.isRoomMissing,
    required this.inSync,
    required this.room,
    required this.type,
  });

  factory RoomSyncingAction.synced(ChatRoom room) =>
      RoomSyncingAction._internal(
        messagesToWrite: [],
        messagesToDelete: [],
        messagesToUpdate: [],
        isRoomMissing: false,
        inSync: true,
        room: room,
        type: ActionType.NONE,
      );

  factory RoomSyncingAction.unsyncedMsgs(
          ChatRoom room,
          List<Message> msgsToWrite,
          List<Message> msgsToDelete,
          List<Message> msgsToUpdate) =>
      RoomSyncingAction._internal(
        messagesToWrite: msgsToWrite,
        messagesToDelete: msgsToDelete,
        messagesToUpdate: msgsToUpdate,
        isRoomMissing: false,
        inSync: false,
        room: room,
        type: ActionType.SYNC_MSGS,
      );

  factory RoomSyncingAction.missing(ChatRoom room) =>
      RoomSyncingAction._internal(
        messagesToWrite: room.messages,
        messagesToDelete: [],
        messagesToUpdate: [],
        isRoomMissing: true,
        inSync: false,
        room: room,
        type: ActionType.ADD_ROOM,
      );
}
