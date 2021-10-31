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
import 'package:anonymous_chat/services.dart/shared_preferences.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';

abstract class ILocalPrefs {
  static ILocalPrefs get storage => SharedPrefs();

  LocalUser? get user;
  Future<void> setUser(LocalUser? user);

  ThemeState get preferedTheme;
  set preferedTheme(ThemeState theme);

  int get lastSyncingDate;
  Future<void> setSyncingDate(int millisSinceEpoch);
}
