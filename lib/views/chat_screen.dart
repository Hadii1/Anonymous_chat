import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/widgets/keyboard_hider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:bubble/bubble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final messageBoxStateProvider = StateNotifierProvider(
  (ref) => MessageBoxState(),
);

class MessageBoxState extends StateNotifier<String> {
  MessageBoxState() : super('');

  onTextChange(String text) => state = text;

  onSendPressed() {
    state = '';
  }
}

class ChatRoom extends StatelessWidget {
  final Room room;

  const ChatRoom({required this.room});

  User get other => room.participants
      .firstWhere((element) => element.id != LocalStorage().user!.id);

  @override
  Widget build(BuildContext context) {
    ApplicationStyle style = InheritedAppTheme.of(context).style;
    return Scaffold(
      backgroundColor: style.backgroundColor,
      appBar: CupertinoNavigationBar(
        previousPageTitle: 'Chats',
        brightness: style == ApplicationStyle.darkStyle
            ? Brightness.dark
            : Brightness.light,
        backgroundColor: style.backgroundColor,
        leading: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () => Navigator.of(context).pop(),
          child: Icon(
            Icons.arrow_back_ios,
            size: 21,
            color: style.accentColor,
          ),
        ),
        middle: Text(
          other.nickname,
          style: style.appBarTextStyle,
        ),
        trailing: Icon(
          Icons.arrow_back_ios,
          size: 21,
          color: Colors.transparent,
        ),
      ),
      body: Consumer(builder: (context, watch, _) {
        return Column(
          children: [
            Expanded(
              child: KeyboardHider(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: room.messages.isEmpty
                          ? [
                              Container(),
                            ]
                          : List.generate(
                              room.messages.length,
                              (index) {
                                Message message = room.messages[index];
                                bool isReceived = message.recipient ==
                                    LocalStorage().user!.id;
                                return ChatBubble(
                                  isLatestMessage: room.messages
                                          .where((Message m) => isReceived
                                              ? m.recipient ==
                                                  LocalStorage().user!.id
                                              : m.recipient !=
                                                  LocalStorage().user!.id)
                                          .last
                                          .id ==
                                      message.id,
                                  message: message,
                                  isReceived: isReceived,
                                );
                              },
                            ),
                    ),
                  ),
                ),
              ),
            ),
            MessageBox(),
          ],
        );
      }),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final bool isLatestMessage;
  final bool isReceived;
  final Message message;

  const ChatBubble({
    required this.isLatestMessage,
    required this.message,
    required this.isReceived,
  });

  @override
  Widget build(BuildContext context) {
    ApplicationStyle style = InheritedAppTheme.of(context).style;
    return Align(
      alignment: isReceived ? Alignment.centerLeft : Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(
          top: 6.0,
          left: isReceived
              ? isLatestMessage
                  ? 2
                  : 8
              : 0,
          right: !isReceived
              ? isLatestMessage
                  ? 2
                  : 8
              : 0,
        ),
        child: Bubble(
          nip: !isLatestMessage
              ? null
              : isReceived
                  ? BubbleNip.leftBottom
                  : BubbleNip.rightBottom,
          nipRadius: 1,
          radius: Radius.circular(8),
          nipHeight: 8,
          nipWidth: 6,
          elevation: 8,
          child: Text(
            message.content,
            style: style.bodyText.copyWith(
              color: style.chatBubbleTextColor,
              backgroundColor: isReceived
                  ? style.receivedMessageBubbleColor
                  : style.sentMessageBubbleColor,
            ),
          ),
          color: isReceived
              ? style.receivedMessageBubbleColor
              : style.sentMessageBubbleColor,
        ),
      ),
    );
  }
}

class MessageBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ApplicationStyle style = InheritedAppTheme.of(context).style;
    return Consumer(builder: (context, watch, _) {
      final messageBox = watch(messageBoxStateProvider);
      return Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.all(8.0),
        color: style.backgroundColor,
        child: SafeArea(
          top: false,
          left: false,
          right: false,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  cursorColor: style.accentColor,
                  style: style.bodyText,
                  onChanged: messageBox.onTextChange,
                  decoration: InputDecoration(
                    hintText: 'Message',
                    hintStyle: style.bodyText
                        .copyWith(color: ApplicationStyle.secondaryTextColor),
                    filled: true,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    fillColor: style.backgroundColor,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        width: 0.15,
                        color: style.borderColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        width: 0.15,
                        color: style.accentColor,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        width: 0.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 250),
                  child: watch(messageBoxStateProvider.state).isEmpty
                      ? Icon(
                          Icons.send,
                          color: Colors.grey,
                        )
                      : InkWell(
                          onTap: messageBox.onSendPressed,
                          child: Icon(
                            Icons.send,
                            color: style.accentColor,
                          ),
                        ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
