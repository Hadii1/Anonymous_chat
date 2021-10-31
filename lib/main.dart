import 'dart:convert';

import 'package:anonymous_chat/database_entities/room_entity.dart';
import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/interfaces/prefs_storage_interface.dart';
import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/services.dart/shared_preferences.dart';
import 'package:anonymous_chat/services.dart/sqlite.dart';
import 'package:anonymous_chat/views/splash_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage rm) async {
  // This is when the user receives a msgs whilst the app is terminated.
  // we  sync any the received msgs to the local databse of the device here.
  print("Handling a background message: ${rm.messageId}");

  await SqlitePersistance.init();
  await SharedPrefs.init();

  final localDatabse = IDatabase.offlineDb;
  final userId = ILocalPrefs.storage.user?.id;

  if (userId == null) return;

  Message message = Message.fromMap(jsonDecode(rm.data['message']));
  assert(message.isReceived(userId));
  List<LocalRoomEntity> rooms =
      await localDatabse.getUserRoomsEntities(userId: userId);
  bool isNewRoom = !rooms.map((r) => r.id).contains(message.roomId);
  if (isNewRoom) {
    localDatabse.saveNewRoomEntity(
      roomEntity: LocalRoomEntity(
          id: message.roomId, contact: message.sender, isArchived: false),
    );

    localDatabse.writeMessage(roomId: message.roomId, message: message);
  } else {
    // Only save if the msg is not saved
    Message? s = await localDatabse.getMessage(
        messageId: message.id, roomId: message.roomId);
    if (s == null)
      localDatabse.writeMessage(roomId: message.roomId, message: message);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    ProviderScope(
      child: SplashScreen(),
    ),
  );
}
