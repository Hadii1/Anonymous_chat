import 'package:anonymous_chat/providers/initial_settings_providers.dart';
import 'package:anonymous_chat/utilities/app_navigator.dart';
import 'package:anonymous_chat/utilities/enums.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/views/notification_handler.dart';
import 'package:anonymous_chat/widgets/error_notification.dart';
import 'package:anonymous_chat/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Consumer(
        builder: (context, ref, _) {
          return ref.watch(appInitialzationProvider).when(
                data: (UserState state) {
                  // return Center(
                  //   child: Image.asset('assets/icons/splash.png'),
                  // );
                  return AppTheme(
                    child: Stack(
                      children: [
                        // This is a chat widget which only appears when a notification is pressed
                        // and shows it's corresponding chat room.
                        NotificationsHandler(),
                        AppNavigator(userState: state),
                        NotificationWidget(),
                        LoadingWidget(),
                      ],
                    ),
                  );
                },
                loading: () => Center(
                  child: Image.asset('assets/icons/splash.png'),
                ),
                error: (e, s) {
                  Future.delayed(Duration(seconds: 2))
                      .then((_) => ref.refresh(appInitialzationProvider));

                  return Center(
                    child: Image.asset('assets/icons/splash.png'),
                  );
                },
              );
        },
      ),
    );
  }
}
