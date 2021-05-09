import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/providers/blocked_contacts_provider.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/views/room_screen.dart';
import 'package:anonymous_chat/utilities/extrentions.dart';
import 'package:anonymous_chat/widgets/custom_route.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ChatHeader extends StatelessWidget {
  final Room room;
  final Function(Room) onDeletePressed;

  const ChatHeader({
    required this.room,
    required this.onDeletePressed,
  });

  User get other =>
      room.users!.firstWhere((User user) => user.id != LocalStorage().user!.id);

  @override
  Widget build(BuildContext context) {
    ApplicationStyle style = InheritedAppTheme.of(context).style;

    Message lastMessage = room.messages.last;

    return Consumer(builder: (context, watch, _) {
      List<String> blockedContacts = watch(blockedContactsProvider.state);
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
        child: Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.2,
          fastThreshold: 1800,
          actions: [
            SlideAction(
              onTap: () => onDeletePressed(room),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            SlideAction(
              onTap: () => context.read(blockedContactsProvider).toggleBlock(
                    other: room.participants.firstWhere(
                      (id) => id != LocalStorage().user!.id,
                    ),
                    block: !blockedContacts.contains(other.id),
                  ),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 250),
                child: blockedContacts.contains(other.id)
                    ? Column(
                        key: ValueKey<int>(0),
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.white,
                          ),
                          Text(
                            'Unblock',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        key: ValueKey<int>(1),
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            Icons.block,
                            color: Colors.white,
                          ),
                          Text(
                            'Block',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
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
                      style: style.bodyText
                          .copyWith(color: style.chatHeaderMsgTime),
                    )
                  ],
                ),
              ),
              SizedBox(
                width: 24,
              ),
            ],
          ),
        ),
      );
    });
  }
}
