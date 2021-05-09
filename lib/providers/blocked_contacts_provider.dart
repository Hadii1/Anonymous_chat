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

import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final blockedContactsProvider = StateNotifierProvider.autoDispose(
  (ref) => BlockedContactsNotifier(),
);

class BlockedContactsNotifier extends StateNotifier<List<String>> {
  BlockedContactsNotifier() : super([]) {
    init();
  }
  final firestore = FirestoreService();
  late User user;

  void init() async {
    Map<String, dynamic> data =
        await firestore.getUserData(id: LocalStorage().user!.id);
    user = User.fromMap(data);
    state = user.blockedUsers;
  }

  void toggleBlock({required String other, required bool block}) {
    if (block) {
      user.blockedUsers.add(other);
      state = user.blockedUsers;
      firestore.blockUser(client: user.id, other: other);
    } else {
      user.blockedUsers.remove(other);
      state = user.blockedUsers;
      firestore.unblockUser(client: user.id, other: other);
    }
  }
}

final blockedByContactsProvider = StreamProvider.autoDispose<List<String>>(
  (ref) async* {
    await for (List<String> a in FirestoreService()
        .blockedByStream(userId: LocalStorage().user!.id)) {
      yield a;
    }
  },
);
