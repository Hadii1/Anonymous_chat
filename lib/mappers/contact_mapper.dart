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

import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/models/contact.dart';
import 'package:anonymous_chat/utilities/enums.dart';

class ContactMapper {
  final IDatabase _onlineDb = IDatabase.onlineDb;
  final IDatabase _offlineDb = IDatabase.offlineDb;

  Future<void> saveContactData({
    required Contact contact,
  }) async {
    await _offlineDb.saveContactData(contact: contact);
  }

  Future<void> toggleContactBlock({
    required Contact contact,
    required bool block,
    required String userId,
  }) async {
    await _onlineDb.blockContact(userId: userId, blockedContact: contact.id);
    await _offlineDb.blockContact(userId: userId, blockedContact: contact.id);
  }

  Future<Contact> getContactData({
    GetDataSource source = GetDataSource.ONLINE,
    required String contactId,
  }) async {
    switch (source) {
      case GetDataSource.LOCAL:
        return await _offlineDb.getContactData(id: contactId);

      case GetDataSource.ONLINE:
        return await _onlineDb.getContactData(id: contactId);
    }
  }

  Future<List<Contact>> getBlockedContacts(
      {required String userId, required GetDataSource source}) async {
    if (source == GetDataSource.ONLINE) {
      List<String> ids = await _onlineDb.getBlockedContacts(userId: userId);
      List<Contact> temp = [];
      for (String id in ids) {
        Contact contact = await _onlineDb.getContactData(id: id);
        temp.add(contact);
      }
      return temp;
    } else {
      List<String> ids = await _offlineDb.getBlockedContacts(userId: userId);
      List<Contact> temp = [];
      for (String id in ids) {
        Contact contact = await _offlineDb.getContactData(id: id);
        temp.add(contact);
      }
      return temp;
    }
  }
}
