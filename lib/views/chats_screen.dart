import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/providers/user_rooms_provider.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/widgets/animated_widgets.dart';
import 'package:anonymous_chat/widgets/chat_header.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ChatsScreen extends StatefulWidget {
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  List<Room> sortedList = [];

  @override
  void initState() {
    super.initState();
    context.read(latestActiveChatProvider).mostRecentRoom.listen((Room room) {
      if (mounted) {
        setState(() {
          AnimatedListState? listState = _listKey.currentState;
          int index = sortedList.indexOf(room);

          if (listState != null) {
            listState.removeItem(
                index, (context, animation) => ChatHeader(room: room));

            listState.insertItem(0);

            sortedList.removeAt(index);
            sortedList.insert(0, room);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ApplicationStyle style = InheritedAppTheme.of(context).style;
    return Consumer(
      builder: (context, watch, _) {
        return watch(userRoomsProvider).when(
          data: (List<Room> rooms) {
            sortedList = rooms;

            return sortedList.isEmpty
                ? Text(
                    'No chats yet.\n Change your tags to match with other and \nstart chatting',
                  )
                : CustomSlide(
                    duration: Duration(milliseconds: 300),
                    startOffset: Offset(0, 0.4),
                    child: Fader(
                      duration: Duration(milliseconds: 250),
                      child: AnimatedList(
                        key: _listKey,
                        initialItemCount: sortedList.length,
                        itemBuilder: (context, index, animation) {
                          Room room = sortedList[index];

                          return Padding(
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
                                  ),
                                ),
                                Divider(
                                  thickness: 0.15,
                                  color: style.borderColor,
                                  indent:
                                      MediaQuery.of(context).size.width * 0.15,
                                  endIndent:
                                      MediaQuery.of(context).size.width * 0.15,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
          },
          loading: () => Center(
            child: SpinKitThreeBounce(
              color: style.loadingBarColor,
              size: 25,
            ),
          ),
          error: (e, s) {
            context.refresh(userRoomsProvider);
            print(e);
            print(s);
            return Center(
              child: SpinKitThreeBounce(
                color: style.loadingBarColor,
                size: 25,
              ),
            );
          },
        );
      },
    );
  }
}
