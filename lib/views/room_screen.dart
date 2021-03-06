import 'package:anonymous_chat/models/activity_status.dart';
import 'package:anonymous_chat/models/chat_room.dart';
import 'package:anonymous_chat/models/contact.dart';
import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/providers/activity_status_provider.dart';
import 'package:anonymous_chat/providers/blocked_contacts_provider.dart';
import 'package:anonymous_chat/providers/chat_provider.dart';
import 'package:anonymous_chat/providers/user_auth_events_provider.dart';
import 'package:anonymous_chat/providers/user_rooms_provider.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/widgets/animated_widgets.dart';
import 'package:anonymous_chat/widgets/chat_bubble.dart';
import 'package:anonymous_chat/widgets/chat_message_field.dart';
import 'package:anonymous_chat/widgets/custom_alert_dialoge.dart';
import 'package:anonymous_chat/widgets/keyboard_hider.dart';
import 'package:anonymous_chat/widgets/shaded_container.dart';
import 'package:anonymous_chat/widgets/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final ChatRoom room;
  final Function()? onBackPressed;

  const ChatRoomScreen({
    required this.room,
    this.onBackPressed,
  });

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  Contact get other => widget.room.contact;

  // @override
  // void didUpdateWidget(covariant ChatRoomScreen oldWidget) {
  //   // if (widget.room.isDifferent(oldWidget.room) && mounted) setState(() {});

  //   super.didUpdateWidget(oldWidget);
  // }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(chattingProvider(widget.room)).onChatOpened();
    });
  }

  @override
  void deactivate() {
    ref.read(chattingProvider(widget.room)).onChatClosed();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    AppStyle style = AppTheming.of(context).style;
    return Scaffold(
      backgroundColor: style.backgroundColor,
      body: Consumer(builder: (context, watch, _) {
        final chatNotifier = ref.watch(chattingProvider(widget.room));
        final String userId = ref.watch(userAuthEventsProvider)!.id;
        // This is to show a dialoge when the other contact deletes
        // the room while this user is viewing it.
        final bool exists = ref.watch(roomExistanceState(widget.room.id));
        final bool isContactBlocked =
            ref.watch(blockedContactsProvider).contains(other);
        final bool? isUserBlocked =
            ref.watch(userBlockedState(widget.room.contact.id));
        ActivityStatus status =
            ref.watch(contactActivityStateProvider(other.id));

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
                                                .cast<Message?>()
                                                .firstWhere(
                                                  (m) =>
                                                      m!.id ==
                                                      message.replyingOn,
                                                  orElse: () => null,
                                                );
                                          }

                                          return CustomSlide(
                                            duration:
                                                Duration(milliseconds: 250),
                                            startOffset: Offset(0, 1),
                                            child: ChatBubble(
                                              message: message,
                                              other: other,
                                              onHold: (Message m) =>
                                                  chatNotifier
                                                      .onMessageLongPress(m),
                                              replyOn: replyOn,
                                              isLatestMessage: chatNotifier
                                                  .isLatestMessage(message),
                                              isReceived:
                                                  message.isReceived(userId),
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
                      child: TypingIndicator(
                        showIndicator: status.state == ActivityStatus.TYPING,
                      ),
                    ),
                    CustomSlide(
                      duration: Duration(milliseconds: 500),
                      delay: Duration(milliseconds: 200),
                      startOffset: Offset(0, 1),
                      child: MessageBox(
                        onSendPressed: (String value) {
                          chatNotifier.onSendPressed(value);
                        },
                        replyMessage: chatNotifier.replyingOn,
                        onCancelReply: chatNotifier.onCancelReply,
                        isContactBlocked: isContactBlocked,
                        loading: isUserBlocked == null,
                        onTypingStateChange: (bool typing) {
                          if (mounted)
                            ref.read(userActivityStateProvider.notifier).set(
                                  activityStatus: typing
                                      ? ActivityStatus.chatting(
                                          otherId: other.id)
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
                              onTap: () => widget.onBackPressed != null
                                  ? widget.onBackPressed!()
                                  : Navigator.of(context).pop(),
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
                                  child: () {
                                    switch (status.state) {
                                      case ActivityStatus.LOADING:
                                        return SizedBox.shrink();
                                      default:
                                        return AnimatedContainer(
                                          duration: Duration(milliseconds: 300),
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
                                  }(),
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
                          child: isContactBlocked
                              ? InkWell(
                                  onTap: () => ref
                                      .read(roomsProvider.notifier)
                                      .toggleBlock(
                                        contact: other,
                                        block: !isContactBlocked,
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
              Align(
                alignment: Alignment.center,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: isUserBlocked == null || !isUserBlocked
                      ? SizedBox.shrink()
                      : CustomAlertDialoge(
                          actionMsg: 'GO BACK',
                          msg:
                              'YOU WERE BLOCKED BY ${widget.room.contact.nickname}',
                          onAction: () => Navigator.of(context).pop(),
                        ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: exists
                      ? SizedBox.shrink()
                      : CustomAlertDialoge(
                          actionMsg: 'GO BACK',
                          msg:
                              'THIS ROOM WAS DELETED BY ${widget.room.contact.nickname}',
                          onAction: () => Navigator.of(context).pop(),
                        ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
