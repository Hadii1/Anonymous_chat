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

import 'package:anonymous_chat/interfaces/irooms_persistance_service.dart';
import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/models/message.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalRoomsPersistance extends IRoomsPersistance {
  static final LocalRoomsPersistance _instance =
      LocalRoomsPersistance._internal();

  static late Database _db;

  LocalRoomsPersistance._internal() {
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    _db = await openDatabase(join(dbPath, 'Anonima.db'), version: 1);
  }

  factory LocalRoomsPersistance() => _instance;

  @override
  Future<List<Map<String, dynamic>>> getAllMessages({required String roomId}) {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> getUserRooms({required String userId}) {
    throw UnimplementedError();
  }

  @override
  void markMessageAsRead({required String roomId, required String messageId}) {}

  @override
  Future<void> saveNewRoom({required Room room}) {
    throw UnimplementedError();
  }

  @override
  Future<void> writeMessage(
      {required String roomId, required Message message}) {
    throw UnimplementedError();
  }
}

  // Future<void> _initDatabase() async {
  //   _database = await openDatabase(
  //     join(await getDatabasesPath(), _databaseName),
  //     version: _databaseVersion,
  //     onCreate: _onCreateDatabase,
  //   );
  // }

  // _onCreateDatabase(Database database, int version) async {
  //   await database.execute('''CREATE TABLE $_table (
  //       contactId TEXT NOT NULL UNIQUE,
  //       firstName TEXT,
  //       lastName TEXT,
  //       jobTitle TEXT,
  //       department TEXT, 
  //       email TEXT, 
  //       address TEXT, 
  //       phoneNumber1 TEXT, 
  //       phoneNumber2 TEXT, 
  //       phoneNumber3 TEXT )''');
  // }

  //Helper methods to add and retrieve contacts data

//   Future<void> saveContact(Contact contact) async {
//     await _database.insert(
//       _table,
//       Contact.toMap(contact),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   Future<List<Contact>> getAllContacts() async {
//     var res = await _database.query(_table);
//     return res.isEmpty ? [] : res.map((e) => Contact.fromJson(e)).toList();
//   }

//   Future<List<Contact>> queryContacts(String name, String job) async {
//     var res = await _database.rawQuery(
//       "SELECT * From $_table WHERE firstName LIKE ? OR lastName LIKE ? ",
//       ['%$name%', '%$name%'],
//     );

//     if (job.isNotEmpty) {
//       res = res.where((element) => element['jobTitle'] == job).toList();
//     }

//     return res.isEmpty ? [] : res.map((e) => Contact.fromJson(e)).toList();
//   }
// }
