// Copyright 2021 hadihammoud
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

import 'package:bubble/bubble.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/database_entities/user_entity.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:anonymous_chat/utilities/extentions.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';

class ChatBubble extends StatelessWidget {
  final bool isLatestMessage;
  final bool isReceived;
  final Message message;
  final Message? replyOn;
  final LocalUser other;
  final bool isSuccesful;
  final Function(Message) onHold;

  const ChatBubble({
    required this.isLatestMessage,
    required this.message,
    required this.isSuccesful,
    required this.onHold,
    required this.isReceived,
    required this.other,
    this.replyOn,
  });

  @override
  Widget build(BuildContext context) {
    AppStyle style = AppTheming.of(context).style;
    return Align(
      alignment: isReceived ? Alignment.centerLeft : Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(
          top: 2.0,
          left: isReceived
              ? isLatestMessage
                  ? 2
                  : 8
              : 0,
          right: !isReceived
              ? isLatestMessage
                  ? 2
                  : 8
              : 0,
          bottom: 2,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          highlightColor: style.accentColor,
          onLongPress: () {
            HapticFeedback.lightImpact();
            onHold(message);
          },
          child: Bubble(
            nip: !isLatestMessage
                ? null
                : isReceived
                    ? BubbleNip.leftBottom
                    : BubbleNip.rightBottom,
            nipRadius: 1,
            radius: Radius.circular(8),
            nipHeight: 8,
            nipWidth: 6,
            elevation: 8,
            borderColor: isReceived || !isSuccesful
                ? style.borderColor
                : style.accentColor,
            borderWidth: 0.3,
            child: TextMessageBody(
              message: message,
              replyOn: replyOn,
              isReceived: isReceived,
              isSuccesful: isSuccesful,
              other: other,
            ),
            color: style.backgroundColor,
          ),
        ),
      ),
    );
  }
}

class TextMessageBody extends StatelessWidget {
  final Message message;
  final Message? replyOn;
  final bool isReceived;
  final bool isSuccesful;
  final LocalUser other;

  const TextMessageBody({
    Key? key,
    required this.message,
    required this.replyOn,
    required this.isReceived,
    required this.isSuccesful,
    required this.other,
  });

  @override
  Widget build(BuildContext context) {
    AppStyle style = AppTheming.of(context).style;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        replyOn == null
            ? SizedBox.shrink()
            : Container(
                padding: const EdgeInsets.only(
                  bottom: 2,
                  top: 2,
                  left: 6,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: style.accentColor,
                      width: 2,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      replyOn!.sender == SharedPrefs().user!.id
                          ? 'You'
                          : other.nickname,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      replyOn!.content,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
        replyOn == null ? SizedBox.shrink() : SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.content,
              style: style.bodyText.copyWith(
                color: style.chatBubbleTextColor,
                backgroundColor: style.backgroundColor,
              ),
            ),
            MessageTimeAndStatus(
              isSuccesful: isSuccesful,
              isReceived: isReceived,
              time: message.time,
              isRead: message.isRead,
            )
          ],
        ),
      ],
    );
  }
}

class MessageTimeAndStatus extends StatelessWidget {
  final bool isSuccesful;
  final bool isReceived;
  final bool isRead;
  final int time;

  const MessageTimeAndStatus({
    required this.isSuccesful,
    required this.isReceived,
    required this.time,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    AppStyle style = AppTheming.of(context).style;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 4),
          child: Text(
            time.formatDate(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
            ),
          ),
        ),
        isReceived
            ? SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(left: 4.0, top: 4),
                child: AnimatedSwitcher(
                  duration: Duration(seconds: 1),
                  child: isSuccesful
                      ? Icon(
                          CupertinoIcons.check_mark,
                          color: isRead ? style.accentColor : Colors.white,
                          size: 12,
                        )
                      : Icon(
                          CupertinoIcons.clock,
                          color: Colors.white,
                          size: 12,
                        ),
                ),
              ),
      ],
    );
  }
}
