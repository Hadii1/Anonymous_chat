import 'package:anonymous_chat/utilities/enums.dart';
import 'package:anonymous_chat/views/home_screen.dart';
import 'package:anonymous_chat/views/login_screen.dart';
import 'package:anonymous_chat/views/nickname_screen.dart';
import 'package:flutter/cupertino.dart';

class AppNavigator extends StatelessWidget {
  final UserState userState;
  const AppNavigator({
    required this.userState,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      observers: [
        HeroController(),
      ],
      onGenerateRoute: (settings) {
        return CupertinoPageRoute(
          builder: (c) {
            switch (settings.name) {
              default:
                switch (userState) {
                  case UserState.AUTHENTICATETD_AND_NICKNAMED:
                    return Home();
                  case UserState.NOT_AUTHENTICATTED:
                    return LoginScreen();
                  case UserState.AUTHENTICATED_NOT_NICKNAMED:
                    return NameScreen();
                }
            }
          },
        );
      },
    );
  }
}
