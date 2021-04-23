import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/providers/user_rooms_provider.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';

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
    allMessages = room.messages ?? [];

    successfullySent = List.from(
      room.messages?.where((element) => !isReceived(element)).toList() ?? [],
    );

    _newRoom = allMessages.isEmpty;

    read(newMessageChannel(room.id).stream).listen(
      (Message? msg) {
        if (msg != null) {
          if (isReceived(msg)) {
            allMessages.add(msg);
            read(chatsSorterProvider).latestActiveChat = room;
            if (isChatPageOpened) {
              _firestore.markMessageAsRead(roomId: room.id, messageId: msg.id);
            }
          } else {
            successfullySent.add(msg);
          }

          notifyListeners();
        }
      },
    );

    read(readMessagesChannel(room.id).stream).listen((Message? msg) {
      if (msg != null && isSent(msg)) {
        room.messages!.firstWhere((Message message) => message == msg).isRead =
            msg.isRead;
        notifyListeners();

      }
    });
  }

  // Mark all messages as read
  void onChatOpened() {
    if (!_newRoom) {
      List<Message> unreadMessages =
          room.messages!.where((m) => isReceived(m) && !m.isRead).toList();

      unreadMessages.forEach((m) {
        _firestore.markMessageAsRead(roomId: room.id, messageId: m.id);
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

      if (!_newRoom) {
        read(chatsSorterProvider).latestActiveChat = room;
      }

      notifyListeners();

      if (_newRoom) {
        _newRoom = false;

        await _firestore.writeMessage(roomId: room.id, message: message);

        await _firestore.saveNewRoom(
          room: room,
        );

        read(chatsSorterProvider).latestActiveChat = room;
      } else {
        await _firestore.writeMessage(roomId: room.id, message: message);
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

  bool isReceived(Message message) =>
      message.recipient == LocalStorage().user!.id;

  bool isSent(Message message) => !isReceived(message);

  bool isLatestMessage(Message message) =>
      allMessages
          .where((Message m) => isReceived(message)
              ? m.recipient == LocalStorage().user!.id
              : m.recipient != LocalStorage().user!.id)
          .last
          .id ==
      message.id;
}
