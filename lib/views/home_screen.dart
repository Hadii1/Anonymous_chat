import 'package:anonymous_chat/models/activity_status.dart';
import 'package:anonymous_chat/providers/activity_status_provider.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/views/chats_screen.dart';
import 'package:anonymous_chat/views/settings_screen.dart';
import 'package:anonymous_chat/views/tags_screen.dart';
import 'package:anonymous_chat/widgets/custom_tab_bar.dart';
import 'package:anonymous_chat/widgets/titled_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

class Home extends ConsumerStatefulWidget {
  const Home();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // if(context.read()){}
    WidgetsBinding.instance.addObserver(this);
    ref
        .read(userActivityStateProvider.notifier)
        .set(activityStatus: ActivityStatus.online());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    switch (state) {
      case AppLifecycleState.resumed:
        ref
            .read(userActivityStateProvider.notifier)
            .set(activityStatus: ActivityStatus.online());
        break;

      case AppLifecycleState.paused:
        ref.read(userActivityStateProvider.notifier).set(
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
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void deactivate() {
    if (mounted)
      ref.read(userActivityStateProvider.notifier).set(
            activityStatus: ActivityStatus.offline(
              lastSeen: DateTime.now().millisecondsSinceEpoch,
            ),
          );
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    AppStyle style = AppTheming.of(context).style;
    return Scaffold(
      backgroundColor: style.backgroundColor,
      appBar: TitledAppBar(
        trailing: Material(
          type: MaterialType.transparency,
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => DatabaseList()));
            },
            child: Icon(
              Icons.place,
              size: 24,
              color: style.iconColors,
            ),
          ),
        ),
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
        headers: [
          'Chats',
          'Tags',
        ],
      ),
    );
  }
}
