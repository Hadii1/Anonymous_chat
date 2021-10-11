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

import 'package:anonymous_chat/models/local_user.dart';
import 'package:anonymous_chat/interfaces/auth_interface.dart';
import 'package:anonymous_chat/interfaces/local_storage_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// This is watched by providers that need to re-evaluate their state after auth changes
final userAuthEventsProvider =
    StateNotifierProvider<UserAuthNotifier, LocalUser?>(
  (ref) => UserAuthNotifier(),
);

class UserAuthNotifier extends StateNotifier<LocalUser?> {
  UserAuthNotifier() : super(ILocalPrefs.storage.user);

  final auth = IAuth.auth;

  set user(LocalUser user) => state = user;

  void onLogin(LocalUser user) => state = user;
  void onLogout() => state = null;
}
