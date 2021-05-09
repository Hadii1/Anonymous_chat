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

import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/providers/blocked_contacts_provider.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/widgets/animated_widgets.dart';
import 'package:anonymous_chat/widgets/titled_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';

class BlockedContactsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ApplicationStyle style = InheritedAppTheme.of(context).style;
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitledAppBar(
                showBackarrow: true,
              ),
              Expanded(
                child: Consumer(
                  builder: (context, watch, _) {
                    List<User> blockedUsers =
                        watch(blockedContactsProvider.state)!;
                    // TODO: empty state
                    if (blockedUsers.isEmpty) return SizedBox.shrink();
                    return CustomSlide(
                      duration: Duration(milliseconds: 300),
                      startOffset: Offset(0, 0.4),
                      child: Fader(
                        duration: Duration(milliseconds: 250),
                        child: ImplicitlyAnimatedList<User>(
                          areItemsTheSame: (a, b) => a.id == b.id,
                          items: blockedUsers,
                          insertDuration: Duration(milliseconds: 200),
                          removeDuration: Duration(milliseconds: 200),
                          removeItemBuilder: (context, animation, user) {
                            return SizeFadeTransition(
                              animation: animation,
                              child: Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Column(
                                  children: [
                                    _BlockedUserHeader(
                                      user: user,
                                      onRemove: (_) {},
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
                          itemBuilder: (context, animation, user, index) {
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
                                      child: _BlockedUserHeader(
                                        user: user,
                                        onRemove: (User user) {
                                          context
                                              .read(blockedContactsProvider)
                                              .toggleBlock(
                                                other: user,
                                                block: !blockedUsers
                                                    .contains(user),
                                              );
                                        },
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
                    // },
                    // loading: () => Center(
                    //   child: SpinKitThreeBounce(
                    //     color: style.loadingBarColor,
                    //     size: 25,
                    //   ),
                    // ),
                    // error: (e, s) {
                    //   context.refresh(blockedByContactsProvider);
                    //   context
                    //       .read(errorsProvider)
                    //       .submitError(exception: e, stackTrace: s);
                    //   return Center(
                    //     child: SpinKitThreeBounce(
                    //       color: style.loadingBarColor,
                    //       size: 25,
                    //     ),
                    //   );
                    // },
                  },
                ),
              ),
            ],
          ),
        ));
  }
}

class _BlockedUserHeader extends StatelessWidget {
  final User user;
  final Function(User) onRemove;

  const _BlockedUserHeader({
    required this.user,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    ApplicationStyle style = InheritedAppTheme.of(context).style;
    return Row(
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 250),
          alignment: Alignment.centerLeft,
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            border: Border.all(
              width: 0.2,
              color: style.borderColor,
            ),
          ),
          child: Center(
            child: Text(
              user.nickname.substring(0, 1).toUpperCase(),
              style: style.chatHeaderLetter,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(
          width: 12,
        ),
        Material(
          type: MaterialType.transparency,
          child: Text(
            user.nickname,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkResponse(
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                radius: 10,
                splashColor: style.accentColor,
                onTap: () => onRemove(user),
                child: Icon(
                  Icons.cancel,
                  color: Colors.white.withOpacity(0.3),
                  size: 24,
                ),
              ),
              SizedBox(
                width: 24,
              ),
            ],
          ),
        )
      ],
    );
  }
}
