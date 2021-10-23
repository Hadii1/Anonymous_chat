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

class Contact {
  final String nickname;
  final String id;
  final bool isBlocked;

  Contact({
    required this.nickname,
    required this.id,
    required this.isBlocked,
  });

  Contact block() {
    return Contact(nickname: this.nickname, id: this.id, isBlocked: true);
  }

  Contact unBlock() {
    return Contact(nickname: this.nickname, id: this.id, isBlocked: false);
  }

  Map<String, dynamic> toMap() {
    return {
      'nickname': nickname,
      'id': id,
      'isBlocked': isBlocked,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      nickname: map['nickname'],
      id: map['id'],
      // This is stored as bool in firestore and as 0/1 in sqlite
      isBlocked: () {
        var data = map['isBlocked'];
        return data is bool
            ? data
            : data == 0
                ? false
                : true;
      }(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Contact &&
        other.nickname == nickname &&
        other.id == id &&
        other.isBlocked == isBlocked;
  }

  @override
  int get hashCode => nickname.hashCode ^ id.hashCode ^ isBlocked.hashCode;
}
