import 'dart:async';

import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/providers/archived_rooms_provider.dart';
import 'package:anonymous_chat/providers/blocked_contacts_provider.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/providers/user_rooms_provider.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:anonymous_chat/utilities/extrentions.dart';

import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final chattingProvider =
    ChangeNotifierProvider.autoDispose.family<ChatNotifier, Room>(
  (ref, room) {
    return ChatNotifier(
      ref.read,
      room: room,
      isArchived: ref.watch(archivedRoomsProvider.state)?.contains(room),
      isBlockedByOther: ref.watch(blockedByProvider.state)!.contains(
            room.users!.firstWhere(
              (User i) => i != LocalStorage().user,
            ),
          ),
    );
  },
);

class ChatNotifier extends ChangeNotifier {
  ChatNotifier(
    this.read, {
    required this.room,
    required this.isArchived,
    required this.isBlockedByOther,
  }) {
    initializeRoom();
  }

  final Room room;
  final Reader read;

  final User _user = LocalStorage().user!;
  final FirestoreService _firestore = FirestoreService();

  late StreamSubscription<Message?> serverMessageUpdatesSubscription;

  late List<Message> allMessages;
  late List<Message> successfullySent;

  late bool _newRoom;
  final bool? isArchived;
  final bool isBlockedByOther;

  User get other => room.users!.firstWhere((User i) => i != _user);

  bool _isChatPageOpened = false;

  void dispose() {
    super.dispose();
    serverMessageUpdatesSubscription.cancel();
  }

  void initializeRoom() {
    allMessages = room.messages;

    successfullySent = List.from(
      room.messages.where((m) => m.isSent()).toList(),
    );

    _newRoom = allMessages.isEmpty;

    // Either a new message is added or an exisiting
    // message is read by the other recipient
    serverMessageUpdatesSubscription =
        read(roomMessagesUpdatesChannel(room.id).stream).listen(
      (Message? message) {
        if (message == null) return;

        if (message.isReceived()) {
          if (message.isSenderBlocked) return;

          if (isArchived != null && isArchived!) {
            read(archivedRoomsProvider)
                .editArchives(room: room, archive: false);
          }

          if (!allMessages.contains(message)) allMessages.add(message);

          read(chatsListProvider).latestActiveChat = room;

          if (_isChatPageOpened) {
            message.isRead = true;
            _firestore.markMessageAsRead(
                roomId: room.id, messageId: message.id);
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
      },
    );
  }

  // Mark all messages as read
  void onChatOpened() {
    _isChatPageOpened = true;
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

  void onChatClosed() {
    _isChatPageOpened = false;
    // notifyListeners();
  }

  Future<void> onSendPressed(String msg) async {
    try {
      Message message = Message(
        isSenderBlocked: isBlockedByOther,
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
        read(chatsListProvider).latestActiveChat = room;

        await _firestore.writeMessage(roomId: room.id, message: message);

        successfullySent.add(message);

        notifyListeners();

        if (isArchived != null && isArchived!) {
          read(archivedRoomsProvider).editArchives(room: room, archive: false);
        }
      } else {
        _newRoom = false;

        await _firestore.writeMessage(roomId: room.id, message: message);

        successfullySent.add(message);

        notifyListeners();

        await _firestore.saveNewRoom(
          room: room,
        );

        read(chatsListProvider).latestActiveChat = room;
      }
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
