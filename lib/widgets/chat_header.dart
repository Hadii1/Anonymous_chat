import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/views/chat_screen.dart';
import 'package:anonymous_chat/utilities/extrentions.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatHeader extends StatelessWidget {
  final Room room;

  const ChatHeader({
    required this.room,
  });

  String get recipientName => room.participants
      .firstWhere((element) => element.id != LocalStorage().user!.id)
      .nickname;

  @override
  Widget build(BuildContext context) {
    ApplicationStyle style = InheritedAppTheme.of(context).style;

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (c) {
              return ChatRoom(
                room: room,
              );
            },
          ),
        );
      },
      child: Row(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 0.2,
                color: style.borderColor,
              ),
            ),
            child: Center(
              child: Text(
                recipientName.substring(0, 1).toUpperCase(),
                style: style.chatHeaderLetter,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipientName,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      room.messages.last.content,
                      style: style.bodyText,
                    )
                  ],
                ),
                Text(
                  room.messages.last.time.formatDate(),
                  style:
                      style.bodyText.copyWith(color: style.chatHeaderMsgTime),
                )
              ],
            ),
          ),
          SizedBox(
            width: 24,
          ),
        ],
      ),
    );
  }
}
