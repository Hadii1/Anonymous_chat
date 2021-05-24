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

class ActivityStatus {
  static const String ONLINE = 'online';
  static const String TYPING = 'typing';
  static const String OFFLINE = 'offline';
  static const String LOADING = 'loading';

  final String state;

  final int? lastSeen;
  final String? chattingWith;

  // If the state is online, lastSeen is null
  // If the user is offline, lastSeen will be set
  // If the user is online and not chatting with anyone, chatting with is null
  // Last seen is milliseconds since epoch

  ActivityStatus._status({
    required this.state,
    this.lastSeen,
    this.chattingWith,
  }) {
    if (state == TYPING) {
      assert(chattingWith != null);
    } else if (state == ONLINE) {
      assert(chattingWith == null);
    } else if (state == LOADING) {
      assert(lastSeen == null && chattingWith == null);
    } else {
      assert(lastSeen != null);
    }
  }

  factory ActivityStatus.online() => ActivityStatus._status(state: ONLINE);

  factory ActivityStatus.chatting({required String otherId}) =>
      ActivityStatus._status(state: TYPING, chattingWith: otherId);

  factory ActivityStatus.offline({required int lastSeen}) =>
      ActivityStatus._status(state: OFFLINE, lastSeen: lastSeen);

  factory ActivityStatus.loading() => ActivityStatus._status(state: LOADING);

  Map<String, dynamic> toMap() {
    return {
      'currentState': state,
      'lastSeen': lastSeen,
      'chattingWith': chattingWith,
    };
  }

  factory ActivityStatus.fromMap(Map<String, dynamic> map) {
    return ActivityStatus._status(
      state: map['currentState'],
      lastSeen: map['lastSeen'],
      chattingWith: map['chattingWith'],
    );
  }

  @override
  String toString() =>
      'ActivityStatus(state: $state, lastSeen: $lastSeen, chattingWith: $chattingWith)';
}
