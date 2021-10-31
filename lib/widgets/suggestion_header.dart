import 'package:anonymous_chat/models/chat_room.dart';
import 'package:anonymous_chat/models/contact.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/views/room_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SuggestedContact extends StatelessWidget {
  final Contact contact;

  const SuggestedContact({
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    AppStyle style = AppTheming.of(context).style;

    return Consumer(
      builder: (context, watch, _) {
        return InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (c) {
                  return ChatRoomScreen(
                    room: ChatRoom.startNew(contact),
                  );
                },
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                width: 45,
                height: 55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 0.2,
                    color: style.borderColor,
                  ),
                ),
                child: Center(
                  child: Text(
                    contact.nickname.substring(0, 1).toUpperCase(),
                    style: style.chatHeaderLetter,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                width: 12,
              ),
              Text(
                contact.nickname,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              // SizedBox(
              //   height: 4,
              // ),
              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     children: List.generate(
              //       commonTags.length,
              //       (index) => Padding(
              //         padding: const EdgeInsets.only(
              //           right: 4.0,
              //           bottom: 2,
              //           top: 2,
              //         ),
              //         child: Text(
              //           commonTags[index].label,
              //           style: style.bodyText.copyWith(
              //             color: AppStyle.secondaryTextColor,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              //   ],
              // )
            ],
          ),
        );
      },
    );
  }
}
