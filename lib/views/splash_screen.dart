import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/services.dart/algolia.dart';
import 'package:anonymous_chat/services.dart/authentication.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/services.dart/push_notificaitons.dart';
import 'package:anonymous_chat/utilities/app_navigator.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:anonymous_chat/utilities/enums.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/widgets/error_notification.dart';
import 'package:anonymous_chat/widgets/loading_widget.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:sentry_flutter/sentry_flutter.dart';

final appInitialzationProvider =
    FutureProvider.autoDispose<UserState>((ref) async {
  await Firebase.initializeApp();
  await LocalStorage.init();
  await AlgoliaSearch.init();
  await NotificationsService.init();
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://0f054bcf09524b3781154f1c3daab510@o538575.ingest.sentry.io/5786123';
    },
  );

  // await AuthService().signOut();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final bool _isAuthenticated = AuthService().isAuthenticated();
  late bool _isNicknamed;

  if (_isAuthenticated && LocalStorage().user == null) {
    Map<String, dynamic> data = await FirestoreService().getUserData(
      id: AuthService().userId()!,
    );
    User user = User.fromMap(data);
    await LocalStorage().setUser(user);
  }

  if (_isAuthenticated) {
    _isNicknamed = LocalStorage().user!.nickname.isNotEmpty;
  } else {
    _isNicknamed = false;
  }

  if (_isAuthenticated) {
    return _isNicknamed
        ? UserState.userAuthenticatedAndNicknamed
        : UserState.userAuthenticated;
  } else {
    return UserState.userNotAuthenticated;
  }
});

class InitializaitonScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Consumer(
        builder: (context, watch, _) {
          return watch(appInitialzationProvider).when(
            data: (UserState state) {
              return AppTheme(
                child: Stack(
                  children: [
                    AppNavigator(
                      isAuthenticated: state != UserState.userNotAuthenticated,
                      isNicknamed:
                          state == UserState.userAuthenticatedAndNicknamed,
                    ),
                    NotificationWidget(),
                    LoadingWidget(),
                  ],
                ),
              );
            },
            loading: () => Container(
              color: Colors.white,
              child: Center(
                child: SpinKitThreeBounce(
                  size: 25,
                  color: Color(0xff008080),
                ),
              ),
            ),
            error: (e, s) {
              context.read(errorsProvider.notifier).setError(
                    exception: e,
                    stackTrace: s,
                    hint: 'Error in app initializing',
                  );

              Future.delayed(Duration(seconds: 2))
                  .then((_) => context.refresh(appInitialzationProvider));

              return Container(
                color: Colors.white,
                child: Center(
                  child: SpinKitThreeBounce(
                    size: 25,
                    color: Color(0xff008080),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
