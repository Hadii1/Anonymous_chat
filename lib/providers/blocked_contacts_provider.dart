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
import 'package:anonymous_chat/interfaces/prefs_storage_interface.dart';
import 'package:anonymous_chat/mappers/contact_mapper.dart';
import 'package:anonymous_chat/models/contact.dart';
import 'package:anonymous_chat/providers/user_auth_events_provider.dart';
import 'package:anonymous_chat/providers/user_rooms_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final blockedContactsProvider =
    StateNotifierProvider.autoDispose<BlockedContactsNotifier, List<Contact>>(
  (ref) {
    ref.watch(userAuthEventsProvider);
    ref.maintainState = true;
    return BlockedContactsNotifier(ref.read(roomsProvider).blockedContacts);
  },
);

class BlockedContactsNotifier extends StateNotifier<List<Contact>> {
  String userId = ILocalPrefs.storage.user!.id;
  bool loading = true;
  ContactMapper contactMapper = ContactMapper();
  BlockedContactsNotifier(List<Contact> localBlockedContacts)
      : super(localBlockedContacts) {
    _initBlockedContacts();
  }

  _initBlockedContacts() async {
    List<Contact> blockedContacts = [];
    List<String> ids =
        await IDatabase.onlineDb.getBlockedContacts(userId: userId);

    for (String id in ids) {
      Contact contact =
          await contactMapper.getContactData(userId: userId, contactId: id);
      blockedContacts.add(contact);
    }
    loading = false;
    state = [...blockedContacts];
  }

  void toggleBlock({required Contact contact, required bool block}) {
    if (block) {
      state = [...state, contact];
    } else {
      state.remove(contact);
      state = [...state];
    }
  }
}
