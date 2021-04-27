import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/providers/user_rooms_provider.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:anonymous_chat/utilities/extrentions.dart';

import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final chattingProvider = ChangeNotifierProvider.family<ChatNotifier, Room>(
  (ref, room) {
    return ChatNotifier(
      ref.read,
      room: room,
    );
  },
);

class ChatNotifier extends ChangeNotifier {
  ChatNotifier(
    this.read, {
    required this.room,
  }) {
    initializeRoom();
  }

  final Room room;
  final Reader read;

  final User _user = LocalStorage().user!;
  final FirestoreService _firestore = FirestoreService();

  late List<Message> allMessages;
  late List<Message> successfullySent;

  late bool _newRoom;

  bool isChatPageOpened = false;

  void initializeRoom() {
    allMessages = room.messages;

    successfullySent = List.from(
      room.messages.where((m) => m.isSent()).toList(),
    );

    _newRoom = allMessages.isEmpty;

    // Either a new message is added or an exisiting
    // message is read by the other recipient

    read(roomMessagesUpdatesChannel(room.id).stream).listen((Message? message) {
      if (message == null) return;

      if (message.isReceived()) {
        if (!allMessages.contains(message)) allMessages.add(message);

        read(chatsSorterProvider).latestActiveChat = room;

        if (isChatPageOpened) {
          message.isRead = true;
          _firestore.markMessageAsRead(roomId: room.id, messageId: message.id);
        }
      } else {
        if (successfullySent.contains(message)) {
          if (message.isRead &&
              !successfullySent.firstWhere((m) => m == message).isRead) {
            allMessages.firstWhere((element) => element == message).isRead =
                true;
          }
        }
      }
      notifyListeners();
    });
  }

  // Mark all messages as read
  void onChatOpened() {
    if (!_newRoom) {
      room.messages
          .where((m) => m.isReceived() && !m.isRead)
          .toList()
          .forEach((e) {
        e.isRead = true;
        _firestore.markMessageAsRead(roomId: room.id, messageId: e.id);
      });

      notifyListeners();
    }
  }

  Future<void> onSendPressed(String msg) async {
    try {
      Message message = Message(
        sender: _user.id,
        recipient: recipient,
        content: msg,
        isRead: false,
        time: DateTime.now().millisecondsSinceEpoch,
        id: _firestore.getMessageReference(roomId: room.id),
      );

      allMessages.add(message);
      notifyListeners();

      if (!_newRoom) {
        read(chatsSorterProvider).latestActiveChat = room;
        await _firestore.writeMessage(roomId: room.id, message: message);
        successfullySent.add(message);
      } else {
        _newRoom = false;

        await _firestore.writeMessage(roomId: room.id, message: message);
        successfullySent.add(message);

        await _firestore.saveNewRoom(
          room: room,
        );

        read(chatsSorterProvider).latestActiveChat = room;
      }

      notifyListeners();
    } on Exception catch (e, s) {
      read(errorsProvider).submitError(
        exception: e,
        stackTrace: s,
        hint: 'onSendPressed in MessageBoxState',
      );

      // Retry opertion
      Future.delayed(
        Duration(seconds: 2),
        () {
          onSendPressed(msg);
        },
      );
    }
  }

  String get recipient =>
      room.participants.firstWhere((String id) => id != _user.id);

  bool isSuccessful(Message message) => successfullySent.contains(message);

  bool isLatestMessage(Message message) =>
      allMessages
          .where(
            (Message m) => message.isReceived()
                ? m.recipient == LocalStorage().user!.id
                : m.recipient != LocalStorage().user!.id,
          )
          .last
          .id ==
      message.id;
}
