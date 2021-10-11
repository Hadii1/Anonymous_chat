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

import 'package:anonymous_chat/mappers/contact_mapper.dart';
import 'package:anonymous_chat/models/contact.dart';
import 'package:anonymous_chat/interfaces/local_storage_interface.dart';
import 'package:anonymous_chat/providers/user_auth_events_provider.dart';
import 'package:anonymous_chat/utilities/enums.dart';
import 'package:anonymous_chat/utilities/general_functions.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final localBlockedContactsFuture =
    FutureProvider.autoDispose<List<Contact>>((ref) async {
  ref.maintainState = true;

  final userId = ref.watch(userAuthEventsProvider)!.id;
  final contactsMapper = ContactMapper();

  List<Contact> blockedContacts = await contactsMapper.getBlockedContacts(
      userId: userId, source: GetDataSource.LOCAL);

  ref.read(blockedContactsProvider.notifier).blockedContacts = blockedContacts;

  return blockedContacts;
});

final blockedContactsProvider =
    StateNotifierProvider.autoDispose<BlockedContactsNotifier, List<Contact>?>(
  (ref) {
    ref.maintainState = true;
    return BlockedContactsNotifier();
  },
);

class BlockedContactsNotifier extends StateNotifier<List<Contact>?> {
  BlockedContactsNotifier() : super(null);

  final ContactMapper contactMapper = ContactMapper();
  final userId = ILocalPrefs.storage.user!.id;

  set blockedContacts(List<Contact> contacts) => state = contacts;

  void toggleBlock({required Contact contact, required bool block}) {
    if (block) {
      state!.add(contact);
      state = state;
      retry(
        f: () => contactMapper.toggleContactBlock(
            contact: contact, block: block, userId: userId),
      );
    } else {
      state!.remove(contact);
      state = state;
      retry(
        f: () => contactMapper.toggleContactBlock(
            contact: contact, block: block, userId: userId),
      );
    }
  }
}
