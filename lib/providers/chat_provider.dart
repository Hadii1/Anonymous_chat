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
  late Message lastMessage;

  late bool _newRoom;

  bool isChatPageOpened = false;

  void initializeRoom() {
    allMessages = room.messages;

    successfullySent = List.from(
      room.messages.where((m) => m.isSent()).toList(),
    );

    if (allMessages.isNotEmpty) {
      lastMessage = allMessages.last;
    }

    _newRoom = allMessages.isEmpty;

    read(newMessageChannel(room.id).stream).listen(
      (Message? msg) {
        if (msg != null) {
          lastMessage = msg;
          if (msg.isReceived()) {
            allMessages.add(msg);
            read(chatsSorterProvider).latestActiveChat = room;

            if (isChatPageOpened) {
              msg.isRead = true;
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
      if (msg != null && msg.isSent()) {
        Message current =
            room.messages.firstWhere((Message message) => message == msg);
        current.isRead = msg.isRead;

        notifyListeners();
      }
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

      if (!_newRoom) {
        read(chatsSorterProvider).latestActiveChat = room;
        _firestore.writeMessage(roomId: room.id, message: message);
      } else {
        _newRoom = false;

        await _firestore.writeMessage(roomId: room.id, message: message);

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
