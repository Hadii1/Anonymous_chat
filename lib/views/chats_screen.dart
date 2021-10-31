import 'dart:convert';
import 'dart:io';

import 'package:anonymous_chat/models/chat_room.dart';
import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/providers/user_rooms_provider.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/views/room_screen.dart';
import 'package:anonymous_chat/widgets/animated_widgets.dart';
import 'package:anonymous_chat/widgets/chat_header.dart';
import 'package:anonymous_chat/widgets/custom_route.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttericon/iconic_icons.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';

// This is to handle the app being opened by a chat notification.
// We navigate to the specific room of that notificaiton.
final backgroundNotificationsState =
    StateNotifierProvider<BackgroundNotificationsNotifier, ChatRoom?>(
        (ref) => BackgroundNotificationsNotifier(ref.read));

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

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage remoteMessage) {
    Map<String, dynamic> messageData =
        jsonDecode(remoteMessage.data['message']);
    print(messageData);
    Message message = Message.fromMap(messageData);
    ChatRoom room = read(roomsProvider)
        .allRooms
        .firstWhere((ChatRoom r) => r.id == message.roomId);
    state = room;
  }
}

class ChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppStyle style = AppTheming.of(context).style;
    return ProviderListener(
      provider: backgroundNotificationsState,
      onChange: (context, ChatRoom? room) {
        if (room == null) return;
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
      child: Column(
        children: [
          Consumer(builder: (context, watch, _) {
            bool isLoading = watch(roomsProvider).isFirstFetch;
            watch(backgroundNotificationsState);
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
          }),
          Expanded(
            child: Consumer(
              builder: (context, watch, _) {
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 350),
                  child: () {
                    List<ChatRoom> chatRooms =
                        watch(roomsProvider).unarhcivedRooms;

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
                                      padding: EdgeInsets.only(top: 1),
                                      child: Column(
                                        children: [
                                          ChatHeader(
                                            room: room,
                                          ),
                                          Divider(
                                            thickness: 0.15,
                                            color: style.borderColor,
                                            indent: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.15,
                                            endIndent: MediaQuery.of(context)
                                                    .size
                                                    .width *
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
                                            indent: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.15,
                                            endIndent: MediaQuery.of(context)
                                                    .size
                                                    .width *
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
            ),
          ),
        ],
      ),
    );
  }
}
