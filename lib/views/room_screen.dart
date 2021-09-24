import 'package:anonymous_chat/models/activity_status.dart';
import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/database_entities/user_entity.dart';
import 'package:anonymous_chat/providers/activity_status_provider.dart';
import 'package:anonymous_chat/providers/blocked_contacts_provider.dart';
import 'package:anonymous_chat/providers/chat_provider.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/widgets/animated_widgets.dart';
import 'package:anonymous_chat/widgets/chat_bubble.dart';
import 'package:anonymous_chat/widgets/chat_message_field.dart';
import 'package:anonymous_chat/widgets/keyboard_hider.dart';
import 'package:anonymous_chat/utilities/extentions.dart';
import 'package:anonymous_chat/widgets/shaded_container.dart';
import 'package:anonymous_chat/widgets/typing_indicator.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatRoomScreen extends StatefulWidget {
  final Room room;

  const ChatRoomScreen({
    required this.room,
  });

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  LocalUser get other =>
      widget.room.users.firstWhere((u) => u.id != SharedPrefs().user!.id);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      context.read(chattingProvider(widget.room)).onChatOpened();
    });
  }

  @override
  void deactivate() {
    context.read(chattingProvider(widget.room)).onChatClosed();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    AppStyle style = AppTheming.of(context).style;
    return Scaffold(
      backgroundColor: style.backgroundColor,
      body: Consumer(builder: (context, watch, _) {
        final chatNotifier = watch(chattingProvider(widget.room));
        List<LocalUser> blockedContacts = watch(blockedContactsProvider)!;

        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 65),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Fader(
                        duration: Duration(milliseconds: 300),
                        child: KeyboardHider(
                          child: SingleChildScrollView(
                            reverse: true,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 24,
                                left: 2,
                                right: 2,
                                bottom: 0,
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
                                          Message? replyOn;

                                          if (message.replyingOn != null) {
                                            replyOn = chatNotifier.allMessages
                                                .firstWhere(
                                              (m) => m.id == message.replyingOn,
                                            );
                                          }

                                          return CustomSlide(
                                            duration:
                                                Duration(milliseconds: 250),
                                            startOffset: Offset(0, 1),
                                            child: ChatBubble(
                                              message: message,
                                              other: chatNotifier.other,
                                              onHold: (Message m) =>
                                                  chatNotifier
                                                      .onMessageLongPress(m),
                                              replyOn: replyOn,
                                              isLatestMessage: chatNotifier
                                                  .isLatestMessage(message),
                                              isReceived: message.isReceived(),
                                              isSuccesful: chatNotifier
                                                  .isSuccessful(message),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 2, top: 2),
                      child: Consumer(
                        builder: (context, watch, _) {
                          ActivityStatus status =
                              watch(contactActivityStateProvider(other.id));
                          return TypingIndicator(
                            showIndicator:
                                status.state == ActivityStatus.TYPING,
                          );
                        },
                      ),
                    ),
                    CustomSlide(
                      duration: Duration(milliseconds: 500),
                      delay: Duration(milliseconds: 200),
                      startOffset: Offset(0, 1),
                      child: MessageBox(
                        onSendPressed: (String value) {
                          chatNotifier.onSendPressed(text: value);
                        },
                        replyMessage: chatNotifier.replyingOn,
                        onCancelReply: chatNotifier.onCancelReply,
                        isContactBlocked: blockedContacts.contains(other),
                        onTypingStateChange: (bool typing) {
                          context.read(userActivityStateProvider.notifier).set(
                                activityStatus: typing
                                    ? ActivityStatus.chatting(otherId: other.id)
                                    : ActivityStatus.online(),
                              );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              ShadedContainer(
                stops: [0.65, 0.95],
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 12,
                      bottom: 36,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Hero(
                                  tag: '${other.id}${other.nickname}',
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: Text(
                                      other.nickname,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: Consumer(
                                    builder: (context, watch, _) {
                                      ActivityStatus status = watch(
                                          contactActivityStateProvider(
                                              other.id));
                                      switch (status.state) {
                                        case ActivityStatus.LOADING:
                                          return SizedBox.shrink();

                                        default:
                                          return AnimatedContainer(
                                            duration:
                                                Duration(milliseconds: 300),
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: status.state ==
                                                      ActivityStatus.OFFLINE
                                                  ? style.iconColors
                                                  : style.accentColor,
                                            ),
                                          );
                                      }
                                    },
                                  ),
                                )
                              ],
                            ),
                            Icon(
                              Icons.arrow_back_ios,
                              size: 21,
                              color: Colors.transparent,
                            ),
                          ],
                        ),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          child: blockedContacts.contains(other)
                              ? InkWell(
                                  onTap: () => context
                                      .read(blockedContactsProvider.notifier)
                                      .toggleBlock(
                                        other: other,
                                        block: !blockedContacts.contains(other),
                                      ),
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Text(
                                      'Unblock contact to continue chat',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: style.accentColor,
                                        letterSpacing: 1,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox.shrink(),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
