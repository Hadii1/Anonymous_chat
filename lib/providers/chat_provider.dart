import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/providers/user_rooms_provider.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';

import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final chattingProvider =
    ChangeNotifierProvider.family<ChatNotifier, Room>((ref, room) {
  return ChatNotifier(
    ref.read,
    room: room,
  );
});

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

  late bool newRoom;

  void initializeRoom() {
    allMessages = List.from(room.messages ?? []);

    successfullySent = List.from(
      room.messages?.where((element) => !isReceived(element)).toList() ?? [],
    );

    newRoom = allMessages.isEmpty;

    if (newRoom) {}

    read(newMessageChannel(room.id).stream).listen(
      (Message msg) {
        if (isReceived(msg)) {
          allMessages.add(msg);
          read(latestActiveChatProvider).currentState = room;
        } else {
          successfullySent.add(msg);
        }

        notifyListeners();
      },
    );
  }

  Future<void> onSendPressed(String msg) async {
    try {
      Message message = Message(
        sender: _user.id,
        recipient: recipient,
        content: msg,
        time: DateTime.now().millisecondsSinceEpoch,
        id: _firestore.getMessageReference(roomId: room.id),
      );

      allMessages.add(message);

      read(latestActiveChatProvider).currentState = room;

      notifyListeners();

      if (newRoom) {
        newRoom = false;

        await _firestore.writeMessage(roomId: room.id, message: message);

        await _firestore.saveNewRoom(
          room: room,
        );
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

  bool isLatestMessage(Message message) =>
      allMessages
          .where((Message m) => isReceived(message)
              ? m.recipient == LocalStorage().user!.id
              : m.recipient != LocalStorage().user!.id)
          .last
          .id ==
      message.id;
}
