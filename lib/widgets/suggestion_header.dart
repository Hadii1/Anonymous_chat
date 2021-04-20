import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/views/room_screen.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class SuggestedContact extends StatelessWidget {
  final Tuple2<User, List<Tag>> data;

  const SuggestedContact({
    required this.data,
  });

  User get suggestedUser => data.item1;
  List<Tag> get commonTags => data.item2;

  @override
  Widget build(BuildContext context) {
    ApplicationStyle style = InheritedAppTheme.of(context).style;
    String id = FirestoreService().getRoomReference();
       Room defaultRoom = Room(
              id: id,
              participants: [
                LocalStorage().user!.id,
                suggestedUser.id,
              ],
              users: [
                LocalStorage().user!,
                suggestedUser,
              ],
            );

           
            return InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (c) {
                      return ChatRoom(
                        room: defaultRoom,
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
                      child: Hero(
                        tag: '${suggestedUser.id}${suggestedUser.nickname}',
                        child: Text(
                          suggestedUser.nickname.substring(0, 1).toUpperCase(),
                          style: style.chatHeaderLetter,
                          textAlign: TextAlign.center,
                        ),
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
                            commonTags.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(
                                right: 4.0,
                                bottom: 2,
                                top: 2,
                              ),
                              child: Text(
                                commonTags[index].label,
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
