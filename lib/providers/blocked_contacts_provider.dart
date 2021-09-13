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

import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/database_entities/user_entity.dart';
import 'package:anonymous_chat/interfaces/local_storage_interface.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/utilities/general_functions.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final blockedContactsFuture =
    FutureProvider.autoDispose<List<User>>((ref) async {
  ref.maintainState = true;

  final db = IDatabase.databseService;
  final userId = ILocalStorage.storage.user!.id;

  List<String> blockedIds = await db.getBlockedContacts(userId: userId);

  List<User> blockedUsers = [];

  for (String id in blockedIds) {
    Map<String, dynamic> data = await FirestoreService().getUserData(id: id);
    User user = User.fromMap(data);
    blockedUsers.add(user);
  }

  return blockedUsers;
});

final blockedContactsProvider =
    StateNotifierProvider.autoDispose<BlockedContactsNotifier, List<User>>(
  (ref) =>
      BlockedContactsNotifier(ref.watch(blockedContactsFuture).data!.value),
);

class BlockedContactsNotifier extends StateNotifier<List<User>> {
  BlockedContactsNotifier(List<User> state) : super(state);

  final db = IDatabase.databseService;
  final userId = ILocalStorage.storage.user!.id;

  void toggleBlock({required User other, required bool block}) {
    if (block) {
      state.add(other);
      state = state;
      retry(f: () => db.blockUser(client: userId, other: other.id));
    } else {
      state.remove(other);
      state = state;
      retry(f: () => db.unblockUser(client: userId, other: other.id));
    }
  }
}

final blockedByProvider =
    StateNotifierProvider<BlockedByContactsNotifier, List<User>?>(
  (ref) => BlockedByContactsNotifier(),
);

class BlockedByContactsNotifier extends StateNotifier<List<User>?> {
  BlockedByContactsNotifier() : super(null) {
    init();
  }
  late final StreamSubscription<List<String>> _subscription;
  final String userId = ILocalStorage.storage.user!.id;
  final db = IDatabase.databseService;

  void init() {
    _subscription =
        db.blockedByStream(userId: userId).listen((List<String> ids) async {
      List<User> temp = [];
      for (String id in ids) {
        try {
          Map<String, dynamic> userData =
              await retry(f: () => FirestoreService().getUserData(id: id));
          User user = User.fromMap(userData);
          temp.add(user);
        } on Exception {
          continue;
        }
      }
      state = List.from(temp);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }
}
