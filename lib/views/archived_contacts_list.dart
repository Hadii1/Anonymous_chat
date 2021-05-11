// Copyright 2021 Hadi Hammoud
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/providers/archived_rooms_provider.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/widgets/animated_widgets.dart';
import 'package:anonymous_chat/widgets/chat_header.dart';
import 'package:anonymous_chat/widgets/titled_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttericon/linearicons_free_icons.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';

class ArchivedContactsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ApplicationStyle style = InheritedAppTheme.of(context).style;
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TitledAppBar(
                showBackarrow: true,
              ),
              Expanded(
                child: Consumer(
                  builder: (context, watch, _) {
                    List<Room>? archivedRooms =
                        watch(archivedRoomsProvider.state);

                    if (archivedRooms == null) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SpinKitThreeBounce(
                            color: style.loadingBarColor,
                            size: 25,
                          ),
                        ],
                      );
                    }

                    if (archivedRooms.isEmpty)
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 50,
                          ),
                          Icon(
                            LineariconsFree.file_empty,
                            color: style.accentColor,
                            size: 50,
                          ),
                          SizedBox(height: 24),
                          Text(
                            'No Archived Rooms',
                            style: TextStyle(
                              color: Colors.white,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    return CustomSlide(
                      duration: Duration(milliseconds: 300),
                      startOffset: Offset(0, 0.4),
                      child: Fader(
                        duration: Duration(milliseconds: 250),
                        child: ImplicitlyAnimatedList<Room>(
                          areItemsTheSame: (a, b) => a.id == b.id,
                          items: archivedRooms,
                          insertDuration: Duration(milliseconds: 200),
                          removeDuration: Duration(milliseconds: 200),
                          removeItemBuilder: (context, animation, room) {
                            return SizeFadeTransition(
                              animation: animation,
                              child: Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Column(
                                  children: [
                                    ChatHeader(
                                      room: room,
                                      archivable: false,
                                    ),
                                    Divider(
                                      thickness: 0.15,
                                      color: style.borderColor,
                                      indent:
                                          MediaQuery.of(context).size.width *
                                              0.15,
                                      endIndent:
                                          MediaQuery.of(context).size.width *
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
                                        archivable: false,
                                      ),
                                    ),
                                    Divider(
                                      thickness: 0.15,
                                      color: style.borderColor,
                                      indent:
                                          MediaQuery.of(context).size.width *
                                              0.15,
                                      endIndent:
                                          MediaQuery.of(context).size.width *
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
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
