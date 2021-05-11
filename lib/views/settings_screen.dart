import 'package:anonymous_chat/providers/auth_provider.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/views/archived_contacts_list.dart';
import 'package:anonymous_chat/views/blocked_contacts_list.dart';
import 'package:anonymous_chat/views/login.dart';
import 'package:anonymous_chat/widgets/titled_app_bar.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  // TODO: change all icons + archive empty icon

  @override
  Widget build(BuildContext context) {
    ApplicationStyle style = InheritedAppTheme.of(context).style;
    return Scaffold(
      backgroundColor: style.backgroundColor,
      appBar: TitledAppBar(
        leading: Material(
          type: MaterialType.transparency,
          child: InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () => Navigator.of(context).pop(),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back_ios,
                  size: 21,
                  color: style.accentColor,
                ),
                Text(
                  'Chats',
                  style: style.bodyText.copyWith(
                    fontSize: 16,
                    color: style.backgroundContrastColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
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
              _SettingTile(
                title: 'Blocked Contacts',
                onTap: () async {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (c) => BlockedContactsScreen(),
                      fullscreenDialog: true,
                    ),
                  );
                },
                icon: Icons.block,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(
                  thickness: 0.15,
                  color: style.borderColor,
                ),
              ),
              _SettingTile(
                title: 'Archived Rooms',
                onTap: () async {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (c) => ArchivedContactsList(),
                      fullscreenDialog: true,
                    ),
                  );
                },
                icon: Icons.block,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(
                  thickness: 0.15,
                  color: style.borderColor,
                ),
              ),
              _SettingTile(
                title: 'Sign Out',
                onTap: () async {
                  bool success =
                      await context.read(authProvider).onSignOutPressed();

                  if (success)
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => LoginScreen(),
                      ),
                      (route) => false,
                    );
                },
                icon: Icons.exit_to_app_rounded,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(
                  thickness: 0.15,
                  color: style.borderColor,
                ),
              ),
              _SettingTile(
                title: 'Delete Account',
                onTap: () async {
                  bool success =
                      await context.read(authProvider).onDeleteAccountPressed();

                  if (success)
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => LoginScreen(),
                      ),
                      (route) => false,
                    );
                },
                icon: Icons.delete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final Function() onTap;
  final IconData icon;

  const _SettingTile({
    required this.title,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    ApplicationStyle style = InheritedAppTheme.of(context).style;
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: style.title3Style,
          ),
          Icon(
            icon,
            color: style.iconColors,
          )
        ],
      ),
    );
  }
}
