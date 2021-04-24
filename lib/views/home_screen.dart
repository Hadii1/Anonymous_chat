import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/views/chats_screen.dart';
import 'package:anonymous_chat/views/settings_screen.dart';
import 'package:anonymous_chat/views/tags_screen.dart';
import 'package:anonymous_chat/widgets/custom_tab_bar.dart';
import 'package:anonymous_chat/widgets/titled_app_bar.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    ApplicationStyle style = InheritedAppTheme.of(context).style;
    return Scaffold(
      backgroundColor: style.backgroundColor,
      appBar: TitledAppBar(
        leading: Material(
          type: MaterialType.transparency,
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) => Settings(),
                ),
              );
            },
            child: Icon(
              Icons.settings,
              size: 24,
              color: style.iconColors,
            ),
          ),
        ),
      ),
      body: CustomTabBar(
        children: [
          ChatsScreen(),
          TagsScreen(),
        ],
        headers: ['Chats', 'Tags'],
      ),
    );
  }
}
