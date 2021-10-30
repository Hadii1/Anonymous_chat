// Copyright 2021 Hadi Hammoud
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:io';

import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/interfaces/prefs_storage_interface.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationsService {
  static final NotificationsService _instance =
      NotificationsService._internal();
  factory NotificationsService() => _instance;
  NotificationsService._internal();

  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static Future<void> init(String? userId) async {
    NotificationSettings settings = await _fcm.getNotificationSettings();

    if (Platform.isIOS &&
        settings.authorizationStatus == AuthorizationStatus.notDetermined)
      settings = await _fcm.requestPermission();

    if (settings.authorizationStatus != AuthorizationStatus.denied)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print(
              'Message also contained a notification: ${message.notification}');
        }
      });

    // P.s: The background message handler which is triggered when a notifcation
    // is received while terminated is added in [main] since it's required to be
    // a top level function not a class method as per firebase docs.
    // see: https://firebase.flutter.dev/docs/messaging/usage/#receiving-messages

    // Update the user's token for receiving notificaitons at each app session.

    if (userId != null) initMessagingTokens(userId);
  }

  static Future<void> initMessagingTokens(String userId) async {
    String? token = await _fcm.getToken();
    if (token != null) IDatabase.onlineDb.saveUserToken(userId, token);
    // Any time the token refreshes, store this in the database too.
    _fcm.onTokenRefresh.listen((String token) {
      String? id = ILocalPrefs.storage.user?.id;
      if (id != null) IDatabase.onlineDb.saveUserToken(id, token);
    });
  }
}
