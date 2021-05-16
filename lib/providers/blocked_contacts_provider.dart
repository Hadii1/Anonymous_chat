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

import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final blockedContactsProvider = StateNotifierProvider.autoDispose(
  (_) => BlockedContactsNotifier(),
);

class BlockedContactsNotifier extends StateNotifier<List<User>?> {
  BlockedContactsNotifier() : super(null) {
    init();
  }
  final firestore = FirestoreService();
  late User user;
  List<User> blockedUsers = [];

  void init() async {
    try {
      Map<String, dynamic> data =
          await firestore.getUserData(id: LocalStorage().user!.id);
      user = User.fromMap(data);

      for (String id in user.blockedUsers) {
        Map<String, dynamic> data =
            await FirestoreService().getUserData(id: id);
        User user = User.fromMap(data);
        blockedUsers.add(user);
      }
      state = blockedUsers;
    } on Exception catch (e, _) {
      await Future.delayed(Duration(seconds: 2));
      init();
    }
  }

  void toggleBlock({required User other, required bool block}) {
    if (block) {
      user.blockedUsers.add(other.id);
      blockedUsers.add(other);
      state = blockedUsers;
      firestore.blockUser(client: user.id, other: other.id);
    } else {
      user.blockedUsers.remove(other.id);
      blockedUsers.remove(other);
      state = blockedUsers;
      firestore.unblockUser(client: user.id, other: other.id);
    }
  }
}

class BlockedByContactsNotifier extends StateNotifier<List<User>?> {
  BlockedByContactsNotifier(this._errorNotifier) : super(null) {
    init();
  }
  late StreamSubscription<List<String>> _subscription;
  final ErrorNotifier _errorNotifier;
  List<User> users = [];

  void init() {
    _subscription = FirestoreService()
        .blockedByStream(userId: LocalStorage().user!.id)
        .listen((List<String> ids) async {
      try {
        _handleChange(ids);
      } on Exception catch (e, s) {
        _errorNotifier.submitError(exception: e, stackTrace: s);
        Future.delayed(Duration(seconds: 2)).then((_) => _handleChange(ids));
      }
    });
  }

  void _handleChange(List<String> ids) async {
    users.clear();
    for (String id in ids) {
      Map<String, dynamic> userData =
          await FirestoreService().getUserData(id: id);
      User user = User.fromMap(userData);
      users.add(user);
    }
    state = List.from(users);
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }
}

final blockedByProvider = StateNotifierProvider.autoDispose(
  (ref) => BlockedByContactsNotifier(
    ref.read(errorsProvider),
  ),
);
