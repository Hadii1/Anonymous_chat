import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/views/room_screen.dart';
import 'package:anonymous_chat/utilities/extrentions.dart';
import 'package:anonymous_chat/widgets/custom_route.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatHeader extends StatelessWidget {
  final Room room;

  const ChatHeader({required this.room});

  User get other =>
      room.users!.firstWhere((User user) => user.id != LocalStorage().user!.id);

  @override
  Widget build(BuildContext context) {
    ApplicationStyle style = InheritedAppTheme.of(context).style;

    Message lastMessage = room.messages.last;

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        Navigator.of(context).push(
          CustomRoute(
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
          AnimatedContainer(
            duration: Duration(milliseconds: 250),
            alignment: Alignment.centerLeft,
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: lastMessage.isSent() || lastMessage.isRead
                  ? Colors.transparent
                  : style.accentColor.withOpacity(0.5),
              border: Border.all(
                width: 0.2,
                color: style.borderColor,
              ),
            ),
            child: Center(
              child: Text(
                other.nickname.substring(0, 1).toUpperCase(),
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
                    Hero(
                      tag: '${other.id}${other.nickname}',
                      flightShuttleBuilder: (
                        BuildContext flightContext,
                        Animation<double> animation,
                        HeroFlightDirection flightDirection,
                        BuildContext fromHeroContext,
                        BuildContext toHeroContext,
                      ) {
                        return DefaultTextStyle(
                          style: DefaultTextStyle.of(toHeroContext).style,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: toHeroContext.widget,
                          ),
                        );
                      },
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          other.nickname,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      lastMessage.content,
                      style: style.bodyText,
                    )
                  ],
                ),
                Text(
                  lastMessage.time.formatDate(),
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
