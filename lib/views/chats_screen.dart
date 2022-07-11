import 'dart:io';

import 'package:anonymous_chat/models/chat_room.dart';
import 'package:anonymous_chat/providers/user_rooms_provider.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/widgets/animated_widgets.dart';
import 'package:anonymous_chat/widgets/chat_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttericon/iconic_icons.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';

class ChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppStyle style = AppTheming.of(context).style;
    return Column(
      children: [
        Consumer(
          builder: (context, ref, _) {
            bool isLoading = ref.watch(roomsProvider).isFirstFetch;
            // watch(backgroundNotificationsState);
            return CustomSizeTransition(
              duration: Duration(milliseconds: 350),
              hide: !isLoading,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 350),
                child: !isLoading
                    ? SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Platform.isIOS
                                  ? Theme(
                                      data: ThemeData(
                                        cupertinoOverrideTheme:
                                            CupertinoThemeData(
                                          brightness: Brightness.dark,
                                        ),
                                      ),
                                      child:
                                          CupertinoActivityIndicator(radius: 8),
                                    )
                                  : SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                            style.accentColor),
                                      ),
                                    ),
                            ),
                            Text(
                              'Updating',
                              textAlign: TextAlign.center,
                              style: style.bodyText,
                            ),
                          ],
                        ),
                      ),
              ),
            );
          },
        ),
        Expanded(
          child: Consumer(
            builder: (context, ref, _) {
              List<ChatRoom> chatRooms =
                  List.from(ref.watch(roomsProvider).unarhcivedRooms);
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 350),
                child: chatRooms.isEmpty
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
                                  padding: EdgeInsets.only(top: 1),
                                  child: Column(
                                    children: [
                                      ChatHeader(
                                        room: room,
                                      ),
                                      Divider(
                                        thickness: 0.15,
                                        color: style.borderColor,
                                        indent:
                                            MediaQuery.of(context).size.width *
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
                                  padding: EdgeInsets.only(
                                      top: index == 0 ? 8.0 : 8),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 24,
                                        ),
                                        child: ChatHeader(
                                          room: room,
                                        ),
                                      ),
                                      Divider(
                                        thickness: 0.15,
                                        color: style.borderColor,
                                        indent:
                                            MediaQuery.of(context).size.width *
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
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}
