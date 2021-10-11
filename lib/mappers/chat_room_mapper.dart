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

import 'package:anonymous_chat/database_entities/message_entity.dart';
import 'package:anonymous_chat/database_entities/room_entity.dart';
import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/interfaces/local_storage_interface.dart';
import 'package:anonymous_chat/mappers/contact_mapper.dart';
import 'package:anonymous_chat/mappers/message_mapper.dart';
import 'package:anonymous_chat/models/chat_room.dart';
import 'package:anonymous_chat/models/contact.dart';
import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/utilities/enums.dart';
import 'package:observable_ish/observable_ish.dart';
import 'package:tuple/tuple.dart';

class ChatRoomsMapper {
  final IDatabase<LocalRoomEntity, LocalMessageEntity> offlineDb =
      IDatabase.offlineDb;
  final IDatabase<OnlineRoomEntity, OnlineMessageEntity> onlineDb =
      IDatabase.onlineDb;

  final String userId = ILocalPrefs.storage.user!.id;

  final MessageMapper messageMapper = MessageMapper();
  final ContactMapper contactMapper = ContactMapper();

  Future<List<ChatRoom>> getUserRooms({
    required String userId,
    GetDataSource source = GetDataSource.LOCAL,
  }) async {
    if (source == GetDataSource.LOCAL) {
      List<LocalRoomEntity> roomsData = await offlineDb.getUserRoomsEntities(
        userId: userId,
      );

      List<ChatRoom> rooms = [];

      for (LocalRoomEntity entity in roomsData) {
        Contact contact = await contactMapper.getContactData(
            contactId: entity.contact, source: GetDataSource.LOCAL);

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
          source: GetDataSource.LOCAL,
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
    SetDataSource source = SetDataSource.BOTH,
  }) async {
    if (source == SetDataSource.BOTH || source == SetDataSource.ONLINE) {
      OnlineRoomEntity roomEntity =
          OnlineRoomEntity(id: room.id, participiants: [
        userId,
        room.contact.id,
      ]);

      await onlineDb.saveNewRoomEntity(roomEntity: roomEntity);

      for (OnlineMessageEntity message in room.messages.map(
        (Message m) => OnlineMessageEntity.fromMessageModel(m, room.id),
      )) {
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
        await offlineDb.writeMessage(
            roomId: room.id,
            message: LocalMessageEntity.fromMessageModel(message, room.id));
      }
    }
  }

  Future<void> editArchives(
      {required String roomId,
      required bool archive,
      required String userId}) async {
    if (archive) {
      await offlineDb.archiveChat(userId: userId, roomId: roomId);
      await onlineDb.archiveChat(userId: userId, roomId: roomId);
    } else {
      await offlineDb.unArchiveChat(userId: userId, roomId: roomId);
      await onlineDb.unArchiveChat(userId: userId, roomId: roomId);
    }
  }

  // Initially fetches all user rooms and triggers for new rooms added or ones deleted
  Stream<List<Tuple2<ChatRoom, RoomsServerUpdateType>>>
      roomsServerUpdates() async* {
    onlineDb
        .userRoomsChanges(userId: userId)
        .map((List<Tuple2<Map<String, dynamic>, DataChangeType>> event) async* {
      List<Tuple2<ChatRoom, RoomsServerUpdateType>> temp = [];
      for (Tuple2<Map<String, dynamic>, DataChangeType> v in event) {
        if (v.item2 == DataChangeType.ADDED) {
          OnlineRoomEntity entity = OnlineRoomEntity.fromMap(v.item1);

          Contact contact = await contactMapper.getContactData(
              contactId: entity.participiants.firstWhere((c) => c != userId));

          List<Message> messages = await messageMapper.getRoomMessages(
            entity.id,
            GetDataSource.ONLINE,
          );

          bool isArchived =
              await onlineDb.isArchived(roomId: entity.id, userId: userId);

          ChatRoom chatRoom = ChatRoom(
            contact: contact,
            messages: RxList.from(messages),
            id: entity.id,
            isArchived: isArchived,
          );

          temp.add(Tuple2(chatRoom, RoomsServerUpdateType.ROOM_ADDED));
        } else if (v.item2 == DataChangeType.DELETED) {
          OnlineRoomEntity entity = OnlineRoomEntity.fromMap(v.item1);

          Contact contact = await contactMapper.getContactData(
              contactId: entity.participiants.firstWhere((c) => c != userId));

          // Won't fetch msgs bcz the room will just be deleted using id comparison.
          ChatRoom chatRoom = ChatRoom(
            contact: contact,
            messages: RxList(),
            id: entity.id,
            isArchived: false,
          );
          temp.add(Tuple2(chatRoom, RoomsServerUpdateType.ROOM_DELETED));
        }
      }
      yield temp;
    });
  }
}
