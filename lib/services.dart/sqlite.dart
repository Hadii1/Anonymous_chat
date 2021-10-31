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
import 'package:anonymous_chat/models/contact.dart';
import 'package:anonymous_chat/models/local_user.dart';
import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/utilities/enums.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tuple/tuple.dart';

const String _messagesTable = 'MessagesTable';
const String _contactsTable = 'ContactsTable';
const String _roomsTable = 'RoomsTable';

class SqlitePersistance implements IDatabase<LocalRoomEntity> {
  static final SqlitePersistance _instance = SqlitePersistance._internal();

  factory SqlitePersistance() => _instance;

  SqlitePersistance._internal();

  static late final Database db;

  static bool _initialized = false;

  static init() async {
    if (!_initialized) {
      db = await openDatabase(
        join(await getDatabasesPath(), 'MESSAGES.db'),
        onCreate: (db, __) async {
          _createTables(db);
        },
        version: 1,
      );
      _initialized = true;
    }
  }

  static _createTables(Database db) async {
    await db.execute(
      '''CREATE TABLE $_messagesTable(
           id TEXT PRIMAREY KEY,
           roomId TEXT,
           sender TEXT,
           recipient TEXT,
           content TEXT,
           replyingOn TEXT,
           time INTEGER,
           isRead INTEGER
         ) ''',
    );

    await db.execute(
      '''CREATE TABLE $_contactsTable(
           id TEXT PRIMAREY KEY,
           nickname TEXT UNIQUE,
           isBlocked INTEGER
         ) ''',
    );

    await db.execute(
      '''CREATE TABLE $_roomsTable(
        id TEXT PRIMARY KEY,
        isArchived INTEGER,
        contact TEXT
      ) ''',
    );
  }

  @override
  Future<void> saveNewRoomEntity({required RoomEntity roomEntity}) async {
    LocalRoomEntity entity = roomEntity as LocalRoomEntity;
    await db.rawInsert(
      'INSERT INTO $_roomsTable VALUES ("${entity.id}",0,"${entity.contact}")',
    );
  }

  @override
  Future<void> saveUserData({required LocalUser user}) async {
    await db.rawInsert(
      'INSERT INTO $_contactsTable VALUES ("${user.id}","${user.nickname}",0)',
    );
  }

  @override
  Future<void> archiveChat({
    required String userId,
    required String roomId,
  }) async {
    int count = await db.rawUpdate(
      'UPDATE $_roomsTable SET isArchived = ? WHERE id =?',
      [1, roomId],
    );
    assert(count == 1);
    // if (count == 0) {
    //   await db.rawInsert('INSERT INTO $_roomsTable VALUES (roomId,1)');
    // }
  }

  @override
  Future<void> unArchiveChat(
      {required String userId, required String roomId}) async {
    int count = await db.rawUpdate(
      'UPDATE $_roomsTable SET isArchived = ? WHERE id = ?',
      [0, roomId],
    );
    assert(count == 1);
  }

  @override
  Future<bool> isArchived(
      {required String roomId, required String userId}) async {
    List<Map<String, Object?>> d = await db.rawQuery(
      'SELECT isArchived FROM $_roomsTable WHERE id = ?',
      [roomId],
    );
    assert(d.length == 1);
    return d.first['isArchived'] as bool;
  }

  @override
  Future<void> blockContact({
    required String userId,
    required String blockedContact,
  }) async {
    int count = await db.rawUpdate(
      'UPDATE $_contactsTable SET isBlocked = ? WHERE id = ?',
      [1, blockedContact],
    );
    assert(count == 1);
    // if(count==0){
    //   await db.rawInsert('INSERT INTO $_usersTable')
    // }
  }

  @override
  Future<void> unblockContact({
    required String userId,
    required String blockedContact,
  }) async {
    int count = await db.rawUpdate(
      'UPDATE $_contactsTable SET isBlocked = ? WHERE id = ?',
      [0, blockedContact],
    );
    assert(count == 1);
  }

  @override
  Future<void> deleteChat(
      {required String roomId, required String contactId}) async {
    int count =
        await db.rawDelete('DELETE FROM $_roomsTable WHERE id = ?', [roomId]);
    int count1 = await db
        .rawDelete('DELETE FROM $_messagesTable WHERE roomId = ?', [roomId]);
    int count2 = await db
        .rawDelete('DELETE FROM $_contactsTable WHERE id = ?', [contactId]);
    assert(count == 1);
    assert(count1 >= 1);
    assert(count2 > 0);
  }

  @override
  Future<void> writeMessage(
      {required String roomId, required Message message}) async {
    int isRead = message.isRead ? 1 : 0;
    await db.rawInsert(
      'INSERT INTO $_messagesTable VALUES("${message.id}","$roomId","${message.sender}","${message.recipient}","${message.content}","${message.replyingOn}",${message.time},$isRead)',
    );
  }

  @override
  Future<Message?> getMessage(
      {required String messageId, required String roomId}) async {
    List<Map<String, Object?>> data = await db
        .rawQuery('SELECT * FROM $_messagesTable WHERE id = ?', [messageId]);
    if (data.isEmpty) return null;
    return Message.fromMap(data.first);
  }

  @override
  Future<void> deleteMessage(String id) async {
    int count =
        await db.rawDelete('DELETE FROM $_messagesTable WHERE id = ?', [id]);
    assert(count > 0);
  }

  @override
  Future<void> markMessageAsRead(
      {required String roomId, required String messageId}) async {
    int count = await db.rawUpdate(
      'UPDATE $_messagesTable SET isRead = ? WHERE id = ?',
      [1, messageId],
    );
    assert(count == 1);
  }

  @override
  Future<List<Message>> getAllMessages({required String roomId}) async {
    List<Map<String, Object?>> data = await db.rawQuery(
      'SELECT * FROM $_messagesTable WHERE roomId = ? ORDER BY time ASC',
      [roomId],
    );
    return data.map((e) => Message.fromMap(e)).toList();
  }

  @override
  Future<List<String>> getBlockedContacts({required String userId}) async {
    List<Map<String, Object?>> data = await db.rawQuery(
      'SELECT id FROM $_contactsTable WHERE isBlocked = ?',
      [1],
    );
    return data.isEmpty
        ? []
        : data
            .map((Map<String, Object?> e) => e.values.map((e) => e))
            .toList()
            .cast<String>();
  }

  @override
  Future<List<String>> getUserArchivedRooms({required String userId}) async {
    List<Map<String, Object?>> data = await db.rawQuery(
      'SELECT id FROM $_roomsTable WHERE isArchived = ?',
      [1],
    );

    return data.isEmpty
        ? []
        : data.map((Map<String, Object?> e) => e['id']).toList().cast<String>();
  }

  @override
  Future<List<LocalRoomEntity>> getUserRoomsEntities(
      {required String userId}) async {
    List<Map<String, Object?>> data = await db.rawQuery(
      'SELECT * FROM $_roomsTable',
    );
    return data
        .map((Map<String, Object?> e) => LocalRoomEntity.fromMap(e))
        .toList()
        .cast<LocalRoomEntity>();
  }

  @override
  Future<Contact> getContactData(
      {required String contactId, String? userId}) async {
    List<Map<String, Object?>> d = await db
        .rawQuery('SELECT * FROM $_contactsTable WHERE id = ?', [contactId]);
    assert(d.length == 1);
    return Contact.fromMap(d.first);
  }

  @override
  Future<void> saveContactData({required Contact contact}) async {
    await db.rawInsert(
        'INSERT INTO $_contactsTable VALUES ("${contact.id}","${contact.nickname}",0)');
  }

  @override
  Future<LocalUser> getUserData({required String id}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> activateTag({required UserTag userTag, required String userId}) {
    throw UnimplementedError();
  }

  @override
  Stream<Map<String, dynamic>> activityStatusStream({required String id}) {
    throw UnimplementedError();
  }

  @override
  Future<void> createNewTag(
      {required UserTag userTag, required String userId}) {
    throw UnimplementedError();
  }

  @override
  Future<void> deactivateTag(
      {required UserTag userTag, required String userId}) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAccount({required String userId}) async {
    await db.delete(_contactsTable);
    await db.delete(_messagesTable);
    await db.delete(_roomsTable);
  }

  @override
  Future<List<Contact>> getMatchingUsers(
      {required List<String> tagsIds, required String userId}) {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> getTagsById({required List<String> ids}) {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> getUserTags({required String userId}) {
    throw UnimplementedError();
  }

  @override
  Stream<Tuple2<Message, DataChangeType>> roomMessagesUpdates(
      {required String roomId}) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateUserStatus(
      {required String userId, required Map<String, dynamic> status}) {
    throw UnimplementedError();
  }

  @override
  Stream<List<Tuple2<Map<String, dynamic>, DataChangeType>>> userRoomsChanges(
      {required String userId}) {
    throw UnimplementedError();
  }

  @override
  Stream<bool> blockedByContact(String contactId, String userId) {
    throw UnimplementedError();
  }

  @override
  Future<bool> isUserBlocked(String contactId, String userId) {
    throw UnimplementedError();
  }

  @override
  Future<void> saveUserToken(String userId, String token) {
    throw UnimplementedError();
  }

  @override
  Future<void> saveUserNickname(String nickname, String userId) {
    throw UnimplementedError();
  }
}
