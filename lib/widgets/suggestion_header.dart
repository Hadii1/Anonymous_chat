import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/views/chat_screen.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SuggestionHeader extends StatelessWidget {
  final List<Tag> tags;
  final User suggestedUser;

  const SuggestionHeader({
    required this.suggestedUser,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    ApplicationStyle style = InheritedAppTheme.of(context).style;
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (c) {
              return ChatRoom(
                room: Room.startChat(
                  id: FirestoreService().getReference('Rooms'),
                  users: [
                    LocalStorage().user!,
                    suggestedUser,
                  ],
                ),
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
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 0.2,
                color: style.borderColor,
              ),
            ),
            child: Center(
              child: Text(
                suggestedUser.nickname.substring(0, 1).toUpperCase(),
                style: style.chatHeaderLetter,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                suggestedUser.nickname,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    tags.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(
                        right: 4.0,
                        bottom: 2,
                        top: 2,
                      ),
                      child: Text(
                        tags[index].label,
                        style: style.bodyText.copyWith(
                          color: ApplicationStyle.secondaryTextColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
