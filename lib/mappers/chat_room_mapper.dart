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

import 'dart:async';

import 'package:anonymous_chat/database_entities/room_entity.dart';
import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/mappers/contact_mapper.dart';
import 'package:anonymous_chat/mappers/message_mapper.dart';
import 'package:anonymous_chat/models/chat_room.dart';
import 'package:anonymous_chat/models/contact.dart';
import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/utilities/enums.dart';
import 'package:observable_ish/observable_ish.dart';
import 'package:tuple/tuple.dart';

class ChatRoomsMapper {
  static final ChatRoomsMapper _instance = ChatRoomsMapper._internal();

  factory ChatRoomsMapper() => _instance;

  ChatRoomsMapper._internal();

  final IDatabase<LocalRoomEntity> offlineDb = IDatabase.offlineDb;
  final IDatabase<OnlineRoomEntity> onlineDb = IDatabase.onlineDb;

  final MessageMapper messageMapper = MessageMapper();
  final ContactMapper contactMapper = ContactMapper();

  Future<List<ChatRoom>> getUserRooms({
    required String userId,
    required GetDataSource source,
  }) async {
    if (source == GetDataSource.LOCAL) {
      List<LocalRoomEntity> roomsData = await offlineDb.getUserRoomsEntities(
        userId: userId,
      );

      List<ChatRoom> rooms = [];

      for (LocalRoomEntity entity in roomsData) {
        Contact contact = await contactMapper.getContactData(
            contactId: entity.contact,
            source: GetDataSource.LOCAL,
            userId: userId);

        List<Message> msgsData =
            await messageMapper.getRoomMessages(entity.id, GetDataSource.LOCAL);

        RxList<Message> messages = RxList.from(msgsData);

        ChatRoom chatRoom = ChatRoom(
          contact: contact,
          messages: messages,
          id: entity.id,
          isArchived: entity.isArchived,
        );
        rooms.add(chatRoom);
      }
      return rooms;
    } else {
      List<OnlineRoomEntity> entities = await onlineDb.getUserRoomsEntities(
        userId: userId,
      );

      List<ChatRoom> rooms = [];

      for (OnlineRoomEntity entity in entities) {
        Contact contact = await contactMapper.getContactData(
          contactId: entity.participiants.firstWhere((c) => c != userId),
          source: GetDataSource.ONLINE,
          userId: userId,
        );

        List<Message> msgsData = await messageMapper.getRoomMessages(
            entity.id, GetDataSource.ONLINE);

        RxList<Message> messages = RxList.from(msgsData);

        bool isArchived =
            await onlineDb.isArchived(roomId: entity.id, userId: userId);

        ChatRoom chatRoom = ChatRoom(
          contact: contact,
          messages: messages,
          id: entity.id,
          isArchived: isArchived,
        );
        rooms.add(chatRoom);
      }
      return rooms;
    }
  }

  Future<void> saveUserRoom({
    required ChatRoom room,
    required String userId,
    required SetDataSource source,
  }) async {
    if (source == SetDataSource.BOTH || source == SetDataSource.ONLINE) {
      OnlineRoomEntity roomEntity =
          OnlineRoomEntity(id: room.id, participiants: [
        userId,
        room.contact.id,
      ]);

      await onlineDb.saveNewRoomEntity(roomEntity: roomEntity);

      for (Message message in room.messages) {
        await onlineDb.writeMessage(roomId: room.id, message: message);
      }
    }
    if (source == SetDataSource.BOTH || source == SetDataSource.LOCAL) {
      LocalRoomEntity entity = LocalRoomEntity(
        id: room.id,
        isArchived: room.isArchived,
        contact: room.contact.id,
      );
      await offlineDb.saveNewRoomEntity(roomEntity: entity);

      await offlineDb.saveContactData(contact: room.contact);

      for (Message message in room.messages) {
        await offlineDb.writeMessage(roomId: room.id, message: message);
      }
    }
  }

  Future<void> editArchives({
    required String roomId,
    required bool archive,
    required String userId,
  }) async {
    if (archive) {
      await onlineDb.archiveChat(userId: userId, roomId: roomId);
      await offlineDb.archiveChat(userId: userId, roomId: roomId);
    } else {
      await onlineDb.unArchiveChat(userId: userId, roomId: roomId);
      await offlineDb.unArchiveChat(userId: userId, roomId: roomId);
    }
  }

  Future<void> deleteRoom(ChatRoom room, SetDataSource source) async {
    if (source == SetDataSource.BOTH || source == SetDataSource.ONLINE) {
      await onlineDb.deleteChat(roomId: room.id, contactId: room.contact.id);
    }
    if (source == SetDataSource.BOTH || source == SetDataSource.LOCAL) {
      await offlineDb.deleteChat(roomId: room.id, contactId: room.contact.id);
    }
  }

  Stream<List<Tuple2<ChatRoom, RoomsUpdateType>>> roomsServerUpdates(
      String userId) async* {
    await for (List<Tuple2<Map<String, dynamic>, DataChangeType>> update
        in onlineDb.userRoomsChanges(userId: userId)) {
      List<Tuple2<ChatRoom, RoomsUpdateType>> temp = [];
      for (var v in update) {
        if (v.item2 == DataChangeType.ADDED) {
          OnlineRoomEntity entity = OnlineRoomEntity.fromMap(v.item1);

          Contact contact = await contactMapper.getContactData(
            contactId: entity.participiants.firstWhere((c) => c != userId),
            userId: userId,
          );

          List<Message> messages = await messageMapper.getRoomMessages(
            entity.id,
            GetDataSource.ONLINE,
          );

          bool isArchived = false;
          // await onlineDb.isArchived(roomId: entity.id, userId: userId);

          ChatRoom chatRoom = ChatRoom(
            contact: contact,
            messages: RxList.from(messages),
            id: entity.id,
            isArchived: isArchived,
          );

          temp.add(Tuple2(chatRoom, RoomsUpdateType.ROOM_ADDED));
        } else if (v.item2 == DataChangeType.DELETED) {
          OnlineRoomEntity entity = OnlineRoomEntity.fromMap(v.item1);

          Contact contact = await contactMapper.getContactData(
            contactId: entity.participiants.firstWhere((c) => c != userId),
            userId: userId,
          );

          // Won't fetch msgs bcz the room will just be deleted using id comparison.
          ChatRoom chatRoom = ChatRoom(
            contact: contact,
            messages: RxList(),
            id: entity.id,
            isArchived: false,
          );
          temp.add(Tuple2(chatRoom, RoomsUpdateType.ROOM_DELETED));
        }
      }
      yield temp;
    }
  }
}
