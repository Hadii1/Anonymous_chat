import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/providers/chat_provider.dart';
import 'package:anonymous_chat/providers/user_rooms_provider.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/widgets/animated_widgets.dart';
import 'package:anonymous_chat/widgets/chat_header.dart';
import 'package:flutter/cupertino.dart';

import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';

class ChatsScreen extends StatefulWidget {
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  Widget build(BuildContext context) {
    ApplicationStyle style = InheritedAppTheme.of(context).style;
    return Consumer(
      builder: (context, watch, _) {
        return watch(userRoomsProvider).when(
          data: (List<Room> rooms) {
            List<Room> sortedRooms = watch(chatsSorterProvider.state);

            return rooms.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.not_interested,
                        color: style.accentColor,
                        size: 50,
                      ),
                      SizedBox(height: 24),
                      Text(
                        'No chats yet.\n Select your interests in the \ntags screen to match up with contacts.',
                        style: TextStyle(
                          color: Colors.white,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : CustomSlide(
                    duration: Duration(milliseconds: 300),
                    startOffset: Offset(0, 0.4),
                    child: Fader(
                      duration: Duration(milliseconds: 250),
                      child: ImplicitlyAnimatedList<Room>(
                        areItemsTheSame: (a, b) => a.id == b.id,
                        items: sortedRooms,
                        insertDuration: Duration(milliseconds: 200),
                        removeDuration: Duration(milliseconds: 200),
                        removeItemBuilder: (context, animation, room) {
                          return SizeFadeTransition(
                            animation: animation,
                            child: Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 0,
                                    ),
                                    child: ChatHeader(
                                      onBlockPressed: (Room room) => context
                                          .read(chatsSorterProvider)
                                          .blockContact(roomId: room.id),
                                      onDeletePressed: (Room room) => context
                                          .read(chatsSorterProvider)
                                          .deleteChat(roomId: room.id),
                                      room: room,
                                    ),
                                  ),
                                  Divider(
                                    thickness: 0.15,
                                    color: style.borderColor,
                                    indent: MediaQuery.of(context).size.width *
                                        0.15,
                                    endIndent:
                                        MediaQuery.of(context).size.width *
                                            0.15,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        itemBuilder: (context, animation, room, index) {
                          watch(chattingProvider(room));

                          return SizeFadeTransition(
                            animation: animation,
                            child: Padding(
                              padding:
                                  EdgeInsets.only(top: index == 0 ? 16.0 : 8),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 24,
                                    ),
                                    child: ChatHeader(
                                      onBlockPressed: (Room room) => context
                                          .read(chatsSorterProvider)
                                          .blockContact(roomId: room.id),
                                      onDeletePressed: (Room room) => context
                                          .read(chatsSorterProvider)
                                          .deleteChat(roomId: room.id),
                                      room: room,
                                    ),
                                  ),
                                  Divider(
                                    thickness: 0.15,
                                    color: style.borderColor,
                                    indent: MediaQuery.of(context).size.width *
                                        0.15,
                                    endIndent:
                                        MediaQuery.of(context).size.width *
                                            0.15,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
          },
          loading: () => Center(
            child: SpinKitThreeBounce(
              color: style.loadingBarColor,
              size: 25,
            ),
          ),
          error: (e, s) {
            context.refresh(userRoomsProvider);
            print(e);
            print(s);
            return Center(
              child: SpinKitThreeBounce(
                color: style.loadingBarColor,
                size: 25,
              ),
            );
          },
        );
      },
    );
  }
}
