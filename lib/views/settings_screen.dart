import 'package:anonymous_chat/providers/auth_provider.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/views/about_screen.dart';
import 'package:anonymous_chat/views/archived_contacts_list.dart';
import 'package:anonymous_chat/views/blocked_contacts_list.dart';
import 'package:anonymous_chat/views/login.dart';
import 'package:anonymous_chat/widgets/custom_route.dart';
import 'package:anonymous_chat/widgets/settings_tile.dart';
import 'package:anonymous_chat/widgets/titled_app_bar.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/linearicons_free_icons.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ApplicationStyle style = InheritedAppTheme.of(context).style;
    return Scaffold(
      backgroundColor: style.backgroundColor,
      appBar: TitledAppBar(
        previousPageTitle: 'Chats',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        width: 50,
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
                            LocalStorage()
                                .user!
                                .nickname
                                .substring(0, 1)
                                .toUpperCase(),
                            style: style.chatHeaderLetter,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            LocalStorage().user!.nickname,
                            style: style.title3Style,
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            LocalStorage().user!.email,
                            style: style.bodyText.copyWith(
                              color: style.searchBarHintColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 48,
                  ),
                  SettingTile(
                    title: 'Blocked Contacts',
                    onTap: () async {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (c) => BlockedContactsScreen(),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                    icon: LineariconsFree.warning,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(
                      thickness: 0.15,
                      color: style.borderColor,
                    ),
                  ),
                  SettingTile(
                    title: 'Archived Rooms',
                    onTap: () async {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (c) => ArchivedContactsList(),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                    icon: LineariconsFree.database_1,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(
                      thickness: 0.15,
                      color: style.borderColor,
                    ),
                  ),
                  SettingTile(
                    title: 'Sign Out',
                    onTap: () async {
                      bool success =
                          await context.read(authProvider).onSignOutPressed();

                      if (success)
                        Navigator.of(context).pushAndRemoveUntil(
                          FadingRoute(
                            builder: (_) => LoginScreen(),
                          ),
                          (route) => false,
                        );
                    },
                    icon: LineariconsFree.exit,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(
                      thickness: 0.15,
                      color: style.borderColor,
                    ),
                  ),
                  SettingTile(
                    title: 'Delete Account',
                    onTap: () async {
                      bool success = await context
                          .read(authProvider)
                          .onDeleteAccountPressed();

                      if (success)
                        Navigator.of(context).pushAndRemoveUntil(
                          FadingRoute(
                            builder: (_) => LoginScreen(),
                          ),
                          (route) => false,
                        );
                    },
                    icon: LineariconsFree.trash,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(
                      thickness: 0.15,
                      color: style.borderColor,
                    ),
                  ),
                  SettingTile(
                    title: 'About',
                    onTap: () => Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => AboutScreen(),
                      ),
                    ),
                    icon: LineariconsFree.menu,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
