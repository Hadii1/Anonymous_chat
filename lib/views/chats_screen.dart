import 'package:anonymous_chat/models/chat_room.dart';
import 'package:anonymous_chat/models/contact.dart';
import 'package:anonymous_chat/providers/archived_rooms_provider.dart';
import 'package:anonymous_chat/providers/blocked_contacts_provider.dart';
import 'package:anonymous_chat/providers/user_rooms_provider.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/widgets/animated_widgets.dart';
import 'package:anonymous_chat/widgets/chat_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttericon/iconic_icons.dart';

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
    AppStyle style = AppTheming.of(context).style;
    return Consumer(
      builder: (context, watch, _) {
        bool isLoading = false;

        AsyncValue<List<ChatRoom>?> userRooms = watch(localUserRoomsFuture);

        AsyncValue<List<Contact>> blockedContacts =
            watch(localBlockedContactsFuture);

        AsyncValue<List<String>?> archivedRooms = watch(archivedRoomsFuture);

        List<AsyncValue> values = [userRooms, blockedContacts, archivedRooms];

        values.forEach((element) {
          if (element is AsyncLoading) isLoading = true;
        });

        if (userRooms is AsyncError) {
          context.refresh(localUserRoomsFuture);
          isLoading = true;
        }

        if (blockedContacts is AsyncError) {
          context.refresh(localBlockedContactsFuture);
          isLoading = true;
        }
        if (archivedRooms is AsyncError) {
          context.refresh(archivedRoomsFuture);
          isLoading = true;
        }

        return AnimatedSwitcher(
          duration: Duration(milliseconds: 350),
          child: () {
            if (isLoading) {
              return Center(
                child: SpinKitThreeBounce(
                  color: style.loadingBarColor,
                  size: 25,
                ),
              );
            }
            List<ChatRoom> chatRooms = watch(chatsListProvider)!;

            return chatRooms.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconic.chat,
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
                      child: ImplicitlyAnimatedList<ChatRoom>(
                        areItemsTheSame: (a, b) => a.id == b.id,
                        items: chatRooms,
                        insertDuration: Duration(milliseconds: 200),
                        removeDuration: Duration(milliseconds: 200),
                        removeItemBuilder: (context, animation, room) {
                          return SizeFadeTransition(
                            animation: animation,
                            child: Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Column(
                                children: [
                                  ChatHeader(
                                    room: room,
                                    archivable: true,
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
                                      room: room,
                                      archivable: true,
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
          }(),
        );
      },
    );
  }
}
