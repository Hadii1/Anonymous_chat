import 'package:anonymous_chat/models/chat_room.dart';
import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/providers/user_auth_events_provider.dart';
import 'package:anonymous_chat/providers/user_rooms_provider.dart';
import 'package:anonymous_chat/utilities/extentions.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/views/room_screen.dart';
import 'package:anonymous_chat/widgets/custom_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttericon/linearicons_free_icons.dart';

class ChatHeader extends StatelessWidget {
  final ChatRoom room;

  const ChatHeader({
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    AppStyle style = AppTheming.of(context).style;

    Message lastMessage = room.messages.last;

    return Consumer(builder: (context, ref, _) {
      final String? userId = ref.watch(userAuthEventsProvider)?.id;
      bool blocked =
          ref.watch(roomsProvider).blockedContacts.contains(room.contact);
      bool archived = ref.watch(roomsProvider).archivedRooms.contains(room);

      return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          Navigator.of(context).push(
            FadingRoute(
              builder: (c) {
                return ChatRoomScreen(
                  room: room,
                );
              },
            ),
          );
        },
        // actionPane: SlidableDrawerActionPane(),
        // actionExtentRatio: 0.2,
        // fastThreshold: 1800,
        child: Slidable(
          startActionPane: ActionPane(motion: SizedBox.shrink(), children: [
            InkWell(
              onTap: () =>
                  ref.read(roomsProvider.notifier).deleteChat(room: room),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    LineariconsFree.trash,
                    color: Colors.white.withOpacity(0.85),
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
            InkWell(
              onTap: () => ref
                  .read(roomsProvider.notifier)
                  .toggleBlock(contact: room.contact, block: !blocked),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 250),
                child: blocked
                    ? Column(
                        key: ValueKey<int>(0),
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            LineariconsFree.thumbs_up,
                            color: Colors.white.withOpacity(0.85),
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
                            LineariconsFree.hand,
                            color: Colors.white.withOpacity(0.85),
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
            InkWell(
              onTap: () => ref.read(roomsProvider.notifier).editArchives(
                    room: room,
                    archive: !archived,
                  ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    LineariconsFree.database_1,
                    color: Colors.white.withOpacity(0.85),
                  ),
                  Text(
                    !archived ? 'Archive' : 'Restore',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ]),
          child: Row(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 250),
                alignment: Alignment.centerLeft,
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: lastMessage.isSent(userId!) || lastMessage.isRead
                      ? Colors.transparent
                      : style.accentColor.withOpacity(0.5),
                  border: Border.all(
                    width: 0.2,
                    color: style.borderColor,
                  ),
                ),
                child: Center(
                  child: Text(
                    room.contact.nickname.substring(0, 1).toUpperCase(),
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
                          tag: '${room.contact.id}${room.contact.nickname}',
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
                              room.contact.nickname,
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
