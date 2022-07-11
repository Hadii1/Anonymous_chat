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

// This is to handle the app being opened by a chat notification.
// We navigate to the specific room of that notificaiton.
import 'dart:convert';

import 'package:anonymous_chat/models/chat_room.dart';
import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/providers/user_rooms_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationsProvider =
    StateNotifierProvider<BackgroundNotificationsNotifier, ChatRoom?>(
  (ref) => BackgroundNotificationsNotifier(ref.read),
);

class BackgroundNotificationsNotifier extends StateNotifier<ChatRoom?> {
  BackgroundNotificationsNotifier(this.read) : super(null) {
    _setupInteractedMessage();
  }
  final Reader read;

  Future<void> _setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage remoteMessage) {
    print('Handling message from background');
    Map<String, dynamic> messageData =
        jsonDecode(remoteMessage.data['message']);
    print(messageData);
    Message message = Message.fromMap(messageData);
    ChatRoom? room = read(roomsProvider).allRooms.cast<ChatRoom?>().firstWhere(
          (ChatRoom? r) => r!.id == message.roomId,
          orElse: () => null,
        );
    if (room == null) {
      print('New room was added');
    }
    state = room;
  }

  void onExitRoomPressed() => state = null;
}
