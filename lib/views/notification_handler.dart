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
import 'package:anonymous_chat/providers/notifications_provider.dart';
import 'package:anonymous_chat/views/room_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsHandler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (c, ref, _) {
        ChatRoom? room = ref.watch(notificationsProvider);
        return AnimatedOpacity(
          opacity: room == null ? 0 : 1,
          duration: Duration(milliseconds: 300),
          child: room == null
              ? SizedBox.shrink()
              : ChatRoomScreen(
                  room: room,
                  onBackPressed: () => ref
                      .read(notificationsProvider.notifier)
                      .onExitRoomPressed(),
                ),
        );
      },
    );
  }
}
