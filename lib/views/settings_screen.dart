import 'dart:io';

import 'package:anonymous_chat/interfaces/auth_interface.dart';
import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/interfaces/prefs_storage_interface.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/providers/user_auth_events_provider.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/views/about_screen.dart';
import 'package:anonymous_chat/views/archived_contacts_list.dart';
import 'package:anonymous_chat/views/blocked_contacts_list.dart';
import 'package:anonymous_chat/views/login_screen.dart';
import 'package:anonymous_chat/widgets/custom_route.dart';
import 'package:anonymous_chat/widgets/settings_tile.dart';
import 'package:anonymous_chat/widgets/titled_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fluttericon/linearicons_free_icons.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Settings extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppStyle style = AppTheming.of(context).style;
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
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 0.2,
                            color: style.accentColor,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 0.2,
                                color: style.borderColor,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                ILocalPrefs.storage.user!.nickname
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: style.chatHeaderLetter,
                                textAlign: TextAlign.center,
                              ),
                            ),
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
                            ILocalPrefs.storage.user!.nickname,
                            style: style.title3Style,
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            ILocalPrefs.storage.user!.phoneNumber,
                            style: style.title3Style,
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
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
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
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Divider(
                      thickness: 0.15,
                      color: style.borderColor,
                    ),
                  ),
                  SettingTile(
                    title: 'Sign Out',
                    onTap: () => _onSignOutPressed(context, ref),
                    icon: LineariconsFree.exit,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Divider(
                      thickness: 0.15,
                      color: style.borderColor,
                    ),
                  ),
                  SettingTile(
                    title: 'Delete Account',
                    onTap: () => _onDeleteAccountPressed(context, ref),
                    icon: LineariconsFree.trash,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
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

  void _onDeleteAccountPressed(BuildContext context, WidgetRef ref) async {
    try {
      final userId = ILocalPrefs.storage.user!.id;

      await IDatabase.onlineDb.deleteAccount(userId: userId);
      await IAuth.auth.signOut();
      await ref.read(userAuthEventsProvider.notifier).onLogout(userId);

      Navigator.of(context).pushAndRemoveUntil(
        FadingRoute(
          builder: (_) => LoginScreen(),
        ),
        (route) => false,
      );
    } on Exception catch (e) {
      ref.read(errorsStateProvider.notifier).set(
            e is SocketException
                ? 'Bad internet connection. Try again please.'
                : 'Something went wrong. Try again please.',
          );
    }
  }

  Future<void> _onSignOutPressed(BuildContext context, WidgetRef ref) async {
    try {
      final userId = ILocalPrefs.storage.user!.id;

      await IAuth.auth.signOut();
      await ref.read(userAuthEventsProvider.notifier).onLogout(userId);

      Navigator.of(context).pushAndRemoveUntil(
          FadingRoute(builder: (_) => LoginScreen()), (route) => false);
    } on Exception catch (e) {
      ref.read(errorsStateProvider.notifier).set(
            e is SocketException
                ? 'Bad internet connection. Try again please.'
                : 'Something went wrong. Try again please.',
          );
    }
  }
}
