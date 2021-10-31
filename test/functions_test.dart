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

import 'package:anonymous_chat/models/chat_room.dart';
import 'package:anonymous_chat/models/contact.dart';
import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/syncer/rooms_syncer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:observable_ish/observable_ish.dart';

void main() {
  group('Room Syncing Logic Tests', () {
    List<ChatRoom> localList = [
      ChatRoom(
        contact: Contact(id: 'contactId', isBlocked: false, nickname: ''),
        messages: RxList.from(
          [
            Message(
                sender: 'contactId',
                recipient: 'recipientId',
                content: 'Hello',
                time: DateTime(2020, 1, 1, 1).millisecondsSinceEpoch,
                id: 'messageId',
                isRead: false,
                roomId: ''),
          ],
        ),
        id: '123456789',
        isArchived: false,
      ),
    ];
    List<ChatRoom> onlineList = [
      ChatRoom(
        contact: Contact(id: 'contactId', isBlocked: false, nickname: ''),
        messages: RxList.from(
          [
            Message(
              sender: 'contactId',
              roomId: '',
              recipient: 'recipientId',
              content: 'Hello',
              time: DateTime(2020, 1, 1, 1).millisecondsSinceEpoch,
              id: 'messageId',
              isRead: false,
            ),
            Message(
              sender: 'contactId',
              recipient: 'recipientId',
              roomId: '',
              content: 'Kifak',
              time: DateTime(2020, 1, 1, 2).millisecondsSinceEpoch,
              id: 'messageId1',
              isRead: false,
            )
          ],
        ),
        id: '123456789',
        isArchived: false,
      ),
      ChatRoom(
        contact: Contact(id: 'contactId', isBlocked: false, nickname: ''),
        messages: RxList.from(
          [
            Message(
              sender: 'contact1Id',
              recipient: 'recipientId',
              content: 'Lorem ipsum',
              time: DateTime(2020, 1, 1, 1).millisecondsSinceEpoch,
              id: 'messageId',
              roomId: '',
              isRead: false,
            ),
          ],
        ),
        id: 'abcdefgh',
        isArchived: false,
      ),
    ];

    test(
      'Room syncing logic',
      () {
        List<RoomSyncingAction> actions =
            getSyncingActions(localList, onlineList, 0);

        expect(actions.length, 2);
        expect(actions.first.type, ActionType.MESSAGES_OUT_OF_SYNC);
        expect(actions.first.messagesToWrite.length, 1);
        expect(actions.first.messagesToWrite.first.content, 'Kifak');

        expect(actions[1].type, ActionType.ROOM_MISSING);
        expect(actions[1].messagesToWrite, actions[1].room.messages);
      },
    );

    test('Only unsynced messages are being checked', () {
      List<RoomSyncingAction> actions1 = getSyncingActions(
          localList, onlineList, DateTime.now().millisecondsSinceEpoch);
      expect(actions1.length, 2);
      expect(
        actions1[0].type,
        ActionType.NONE,
        reason:
            'We passed now to be the last sync date and all msgs are before now so no msgs checks are supposed to be made',
      );
      expect(actions1[1].type, ActionType.ROOM_MISSING);
    });
  });
}
