import 'dart:async';
import 'dart:io';

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


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:observable_ish/observable_ish.dart';

import 'package:flutter/foundation.dart';

final chattingProvider =
    ChangeNotifierProvider.autoDispose.family<ChatNotifier, Room>(
  (ref, room) {
    return ChatNotifier(
      ref.read,
      room: room,
      isArchived: ref.watch(archivedRoomsProvider)?.contains(room),
      isBlockedByOther: ref.watch(blockedByProvider)!.contains(
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
  final _firestore = FirestoreService();

  late StreamSubscription<Message?> serverMessagesUpdates;
  late StreamSubscription<ListChangeNotification<Message>?>
      localMessagesChanges;

  late RxList<Message> allMessages;
  late List<Message> successfullySent;

  final bool? isArchived;
  final bool isBlockedByOther;

  Message? replyingOn;
  User get other => room.users!.firstWhere((User i) => i != _user);

  bool _isChatPageOpened = false;

  void dispose() {
    super.dispose();
    serverMessagesUpdates.cancel();
    localMessagesChanges.cancel();
  }

  void initializeRoom() {
    successfullySent = List.from(
      room.messages.where((m) => m.isSent()).toList(),
    );

    allMessages = room.messages;

    localMessagesChanges = allMessages.onChange
        .listen((ListChangeNotification<Message> change) async {
      // When a message is sent locally:
      if (change.element != null && change.element!.isSent()) {
        Message message = change.element!;
        if (replyingOn != null) replyingOn = null;
        if (isArchived != null && isArchived!) {
          read(archivedRoomsProvider.notifier)
              .editArchives(room: room, archive: false);
        }

        read(chatsListProvider.notifier).latestActiveChat = room;

        try {
          await _firestore.writeMessage(roomId: room.id, message: message);

          successfullySent.add(message);

          notifyListeners();

          if (allMessages.length == 1) {
            // Room is new
            await _firestore.saveNewRoom(
              room: room,
            );
          }
        } on Exception catch (e, s) {
          read(errorsProvider.notifier).submitError(
            exception: e,
            stackTrace: s,
            hint: 'Error saving msg: ${message.toString()}',
          );
        }
      }
    });

    serverMessagesUpdates =
        read(roomMessagesUpdatesChannel(room.id).stream).listen(
      (Message? update) async {
        if (update == null) return;

        if (update.isReceived()) {
          // A new message is received
          if (update.isSenderBlocked) return;

          if (isArchived != null && isArchived!) {
            read(archivedRoomsProvider.notifier)
                .editArchives(room: room, archive: false);
          }

          if (!allMessages.contains(update)) {
            allMessages.add(update);

            read(chatsListProvider.notifier).latestActiveChat = room;

            if (_isChatPageOpened) {
              update.isRead = true;
              _firestore.markMessageAsRead(
                  roomId: room.id, messageId: update.id);
            }
          }
        } else {
          // A sent message is read
          if (successfullySent.contains(update)) {
            if (update.isRead &&
                !successfullySent.firstWhere((m) => m == update).isRead) {
              allMessages.firstWhere((element) => element == update).isRead =
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
    if (allMessages.isNotEmpty) {
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

  void onMessageLongPress(Message message) {
    replyingOn = message;
    notifyListeners();
  }

  void onCancelReply() {
    replyingOn = null;
    notifyListeners();
  }

  Future<void> onSendPressed({String? text, List<File>? mediafiles}) async {
    Message message = Message(
      isSenderBlocked: isBlockedByOther,
      sender: _user.id,
      recipient: recipient,
      content: text!,
      isRead: false,
      time: DateTime.now().millisecondsSinceEpoch,
      replyingOn: replyingOn?.id,
      id: _firestore.getMessageReference(roomId: room.id),
    );

    allMessages.add(message);
    notifyListeners();
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
