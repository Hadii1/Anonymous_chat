import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/providers/messages_provider.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/widgets/chat_header.dart';
import 'package:anonymous_chat/widgets/loading_widget.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ApplicationStyle style = InheritedAppTheme.of(context).style;
    return Consumer(
      builder: (context, watch, _) {
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              watch(messagesProvider).when(
                data: (List<Room> rooms) {
                  return Column(
                    children: List.generate(
                      rooms.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: 24,
                                top: index == 0 ? 0 : 16,
                              ),
                              child: ChatHeader(
                                room: rooms[index],
                              ),
                            ),
                            Divider(
                              thickness: 0.15,
                              color: style.borderColor,
                              indent: MediaQuery.of(context).size.width * 0.15,
                              endIndent:
                                  MediaQuery.of(context).size.width * 0.15,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                loading: () => LoadingWidget(),
                error: (e, s) {
                  context.read(errorsProvider).setError(
                        exception: e,
                        stackTrace: s,
                        hint: 'Loading chat rooms on home screen',
                      );

                  Future.delayed(Duration(seconds: 2)).then(
                    (value) => context.refresh(messagesProvider),
                  );

                  print(e);
                  print(s);

                  return LoadingWidget();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
