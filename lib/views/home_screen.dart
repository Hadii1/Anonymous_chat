import 'package:anonymous_chat/models/activity_status.dart';
import 'package:anonymous_chat/providers/activity_status_provider.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/views/chats_screen.dart';
import 'package:anonymous_chat/views/settings_screen.dart';
import 'package:anonymous_chat/views/tags_screen.dart';
import 'package:anonymous_chat/widgets/custom_tab_bar.dart';
import 'package:anonymous_chat/widgets/titled_app_bar.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    context
        .read(userActivityStateProvider)
        .set(activityStatus: ActivityStatus.online());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    switch (state) {
      case AppLifecycleState.resumed:
        context
            .read(userActivityStateProvider)
            .set(activityStatus: ActivityStatus.online());
        break;

      case AppLifecycleState.paused:
        context.read(userActivityStateProvider).set(
              activityStatus: ActivityStatus.offline(
                lastSeen: DateTime.now().millisecondsSinceEpoch,
              ),
            );
        break;

      default:
        break;
    }
  }

  @override
  void deactivate() {
    context.read(userActivityStateProvider).set(
          activityStatus: ActivityStatus.offline(
            lastSeen: DateTime.now().millisecondsSinceEpoch,
          ),
        );
    super.deactivate();
  }

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
