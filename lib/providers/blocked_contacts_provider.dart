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

import 'package:anonymous_chat/interfaces/online_database_interface.dart';
import 'package:anonymous_chat/database_entities/user_entity.dart';
import 'package:anonymous_chat/interfaces/local_storage_interface.dart';
import 'package:anonymous_chat/utilities/enums.dart';
import 'package:anonymous_chat/utilities/general_functions.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';

final blockedContactsFuture =
    FutureProvider.autoDispose<List<LocalUser>>((ref) async {
  ref.maintainState = true;

  final db = IDatabase.db;
  final userId = ILocalStorage.storage.user!.id;

  List<String> blockedIds = await db.getBlockedContacts(userId: userId);

  List<LocalUser> blockedUsers = [];

  for (String id in blockedIds) {
    Map<String, dynamic>? data = await db.getUserData(id: id);
    if (data != null) {
      LocalUser user = LocalUser.fromMap(data);
      blockedUsers.add(user);
    }
  }

  ref.read(blockedContactsProvider.notifier).blockedContacts = blockedUsers;

  return blockedUsers;
});

final blockedContactsProvider = StateNotifierProvider.autoDispose<
    BlockedContactsNotifier, List<LocalUser>?>((ref) {
  ref.maintainState = true;
  return BlockedContactsNotifier();
});

class BlockedContactsNotifier extends StateNotifier<List<LocalUser>?> {
  BlockedContactsNotifier() : super(null);

  final db = IDatabase.db;
  final userId = ILocalStorage.storage.user!.id;

  set blockedContacts(List<LocalUser> contacts) => state = contacts;

  void toggleBlock({required LocalUser other, required bool block}) {
    if (block) {
      state!.add(other);
      state = state;
      retry(f: () => db.blockUser(client: userId, other: other.id));
    } else {
      state!.remove(other);
      state = state;
      retry(f: () => db.unblockUser(client: userId, other: other.id));
    }
  }
}

final blockingContactsFuture =
    FutureProvider.autoDispose<List<LocalUser>>((ref) async {
  ref.maintainState = true;
  final String userId = ILocalStorage.storage.user!.id;
  final db = IDatabase.db;

  List<String> blockingContacts = await db.getBlockingContacts(userId: userId);

  List<LocalUser> temp = [];
  for (String id in blockingContacts) {
    Map<String, dynamic>? userData =
        await retry(f: () async => await db.getUserData(id: id));
    if (userData != null) {
      LocalUser user = LocalUser.fromMap(userData);
      temp.add(user);
    }
  }
  ref.read(blockedByProvider.notifier).blockedBy = temp;

  return temp;
});

final blockedByProvider =
    StateNotifierProvider<BlockedByContactsNotifier, List<LocalUser>?>(
  (ref) => BlockedByContactsNotifier(),
);

class BlockedByContactsNotifier extends StateNotifier<List<LocalUser>?> {
  BlockedByContactsNotifier() : super(null) {
    init();
  }
  late final StreamSubscription<List<Tuple2<String, DataChangeType>>>
      _subscription;
  final userId = ILocalStorage.storage.user!.id;
  final db = IDatabase.db;

  set blockedBy(List<LocalUser> data) => state = data;

  void init() {
    _subscription = db
        .blockingContactsChanges(userId: userId)
        .listen((List<Tuple2<String, DataChangeType>> changes) async {
      List<LocalUser> temp = [];
      for (Tuple2<String, DataChangeType> change in changes) {
        if (change.item2 == DataChangeType.added) {
          try {
            Map<String, dynamic>? userData =
                await retry(f: () async => db.getUserData(id: change.item1));
            if (userData != null) {
              LocalUser user = LocalUser.fromMap(userData);
              temp.add(user);
            }
          } on Exception {
            continue;
          }
        } else {
          state!.removeWhere((element) => element.id == change.item1);
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
