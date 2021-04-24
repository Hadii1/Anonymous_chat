import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/providers/chat_provider.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/widgets/animated_widgets.dart';
import 'package:anonymous_chat/widgets/chat_bubble.dart';
import 'package:anonymous_chat/widgets/chat_message_field.dart';
import 'package:anonymous_chat/widgets/keyboard_hider.dart';
import 'package:anonymous_chat/utilities/extrentions.dart';
import 'package:anonymous_chat/widgets/shaded_container.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatRoom extends StatefulWidget {
  final Room room;

  const ChatRoom({
    required this.room,
  });

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  User get other =>
      widget.room.users!.firstWhere((u) => u.id != LocalStorage().user!.id);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      context.read(chattingProvider(widget.room)).onChatOpened();
      context.read(chattingProvider(widget.room)).isChatPageOpened = true;
    });
  }

  @override
  void deactivate() {
    context.read(chattingProvider(widget.room)).isChatPageOpened = false;
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    ApplicationStyle style = InheritedAppTheme.of(context).style;
    return Scaffold(
      backgroundColor: style.backgroundColor,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            ShadedContainer(
              stops: [0, 0.7],
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, top: 12, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 21,
                          color: style.accentColor,
                        ),
                      ),
                      Hero(
                        tag: '${other.id}${other.nickname}',
                        child: Material(
                          type: MaterialType.transparency,
                          child: Text(
                            other.nickname,
                            style: style.appBarTextStyle,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_back_ios,
                        size: 21,
                        color: Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Consumer(
                builder: (context, watch, _) {
                  final chatNotifier = watch(chattingProvider(widget.room));
                  return Column(
                    children: [
                      Expanded(
                        child: KeyboardHider(
                          child: SingleChildScrollView(
                            reverse: true,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 2,
                                right: 2,
                                bottom: 4,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: chatNotifier.allMessages.isEmpty
                                    ? [
                                        Container(),
                                      ]
                                    : List.generate(
                                        chatNotifier.allMessages.length,
                                        (index) {
                                          Message message =
                                              chatNotifier.allMessages[index];

                                          return CustomSlide(
                                            duration:
                                                Duration(milliseconds: 250),
                                            startOffset: Offset(0, 1),
                                            child: Fader(
                                              duration:
                                                  Duration(milliseconds: 170),
                                              child: ChatBubble(
                                                message: message,
                                                isLatestMessage: chatNotifier
                                                    .isLatestMessage(message),
                                                isReceived:
                                                    message.isReceived(),
                                                isSuccesful: chatNotifier
                                                    .isSuccessful(message),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      MessageBox(
                        onSendPressed: (String value) {
                          chatNotifier.onSendPressed(value);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
