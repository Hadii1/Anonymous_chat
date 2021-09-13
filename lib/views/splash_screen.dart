import 'package:anonymous_chat/interfaces/local_storage_interface.dart';
import 'package:anonymous_chat/database_entities/user_entity.dart';
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

final appInitialzationProvider =
    FutureProvider.autoDispose<UserState>((ref) async {
  await Firebase.initializeApp();
  await SharedPrefs.init();
  await AlgoliaSearch.init();
  await NotificationsService.init();

  // await FirebaseAuthService().signOut();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final storage = ILocalStorage.storage;

  final bool isAuthenticated = FirebaseAuthService().getUser() != null;
  bool isNicknamed = false;

  if (isAuthenticated && storage.user == null) {
    Map<String, dynamic> data = await FirestoreService().getUserData(
      id: FirebaseAuthService().getUser()!.uid,
    );
    User user = User.fromMap(data);
    await storage.setUser(user);
  }

  if (isAuthenticated) {
    isNicknamed = storage.user!.nickname != null;
  }

  if (isAuthenticated) {
    return isNicknamed
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
              context
                  .read(errorsStateProvider.notifier)
                  .set('An error occured. Trying again.');

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
