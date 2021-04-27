import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/services.dart/algolia.dart';
import 'package:anonymous_chat/services.dart/authentication.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/utilities/app_navigator.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:anonymous_chat/utilities/theme_widget.dart';
import 'package:anonymous_chat/widgets/error_notification.dart';
import 'package:anonymous_chat/widgets/loading_widget.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

enum AppInitiState {
  userAuthenticatedAndNicknamed,
  userAuthenticated,
  userNotAuthenticated,
}

final appInitialzationProvider =
    FutureProvider.autoDispose<AppInitiState>((ref) async {
  await LocalStorage.initState();
  await Firebase.initializeApp();
  await AlgoliaSearch.init();

  SystemChrome.setSystemUIOverlayStyle(
    LocalStorage().preferedTheme == ThemeState.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark,
  );

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
        ? AppInitiState.userAuthenticatedAndNicknamed
        : AppInitiState.userAuthenticated;
  } else {
    return AppInitiState.userNotAuthenticated;
  }
});

class InitializaitonScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Consumer(
        builder: (context, watch, _) {
          return watch(appInitialzationProvider).when(
            data: (state) {
              return AppTheme(
                child: Stack(
                  children: [
                    AppNavigator(
                      isAuthenticated:
                          state != AppInitiState.userNotAuthenticated,
                      isNicknamed:
                          state == AppInitiState.userAuthenticatedAndNicknamed,
                    ),
                    ErrorNotification(),
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
              context.read(errorsProvider).setError(
                    exception: e,
                    stackTrace: s,
                    hint: 'Error in app initializing',
                  );
              context.refresh(appInitialzationProvider);

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
