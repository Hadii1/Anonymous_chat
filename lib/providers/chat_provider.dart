import 'dart:async';
import 'dart:io';

import 'package:anonymous_chat/database_entities/room_entity.dart';
import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/interfaces/local_storage_interface.dart';
import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/database_entities/user_entity.dart';
import 'package:anonymous_chat/providers/archived_rooms_provider.dart';
import 'package:anonymous_chat/providers/blocked_contacts_provider.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/providers/user_rooms_provider.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:anonymous_chat/utilities/extrentions.dart';
import 'package:anonymous_chat/utilities/general_functions.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:observable_ish/observable_ish.dart';

import 'package:flutter/foundation.dart';

final chattingProvider = ChangeNotifierProvider.family<ChatNotifier, Room>(
  (ref, room) {
    return ChatNotifier(
      ref.read,
      room: room,
      isArchived: ref.watch(archivedRoomsProvider)!.contains(room),
      isBlockedByOther: ref.watch(blockedByProvider)!.contains(
            room.users.firstWhere(
              (User i) => i != ILocalStorage.storage.user!,
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

  final User _user = ILocalStorage.storage.user!;
  final IDatabase _db = IDatabase.databseService;

  late StreamSubscription<Message?> serverMessagesUpdates;
  late StreamSubscription<ListChangeNotification<Message>?>
      localMessagesChanges;

  late RxList<Message> allMessages;
  late List<Message> successfullySent;

  final bool isArchived;
  final bool isBlockedByOther;

  Message? replyingOn;
  User get other => room.users.firstWhere((User i) => i != _user);

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
        if (isArchived) {
          read(archivedRoomsProvider.notifier)
              .editArchives(room: room, archive: false);
        }

        read(chatsListProvider.notifier).latestActiveChat = room;

        try {
          await retry(
              f: () => _db.writeMessage(roomId: room.id, message: message));

          successfullySent.add(message);

          notifyListeners();

          if (allMessages.length == 1) {
            // Room is new
            await retry(
              f: () => _db.saveNewRoom(
                roomEntity: RoomEntity(
                  id: room.id,
                  users: room.users.map((e) => e.id).toList(),
                ),
              ),
            );
          }
        } on Exception catch (e, _) {
          read(errorsStateProvider.notifier).set(e is SocketException
              ? 'Bad internet connection.'
              : 'Unknown error');
        }
      }
    });

    serverMessagesUpdates =
        read(roomMessagesUpdatesChannel(room.id).stream).listen(
      (Message? message) async {
        if (message == null) return;

        if (message.isReceived()) {
          // A new message is received
          if (message.isSenderBlocked) return;

          if (isArchived) {
            read(archivedRoomsProvider.notifier)
                .editArchives(room: room, archive: false);
          }

          assert(!allMessages.contains(message));

          allMessages.add(message);

          read(chatsListProvider.notifier).latestActiveChat = room;

          if (_isChatPageOpened) {
            message.isRead = true;
            _db.markMessageAsRead(
              roomId: room.id,
              messageId: message.id,
            );
          }
        } else {
          // A sent message is read
          int index = successfullySent.indexWhere((e) => e == message);
          assert(index != -1);
          assert(successfullySent[index].isRead == false);
          assert(message.isRead == true);

          allMessages.firstWhere((m) => m == message).isRead = true;
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
          .forEach((Message e) {
        e.isRead = true;
        _db.markMessageAsRead(roomId: room.id, messageId: e.id);
      });

      notifyListeners();
    }
  }

  void onChatClosed() {
    _isChatPageOpened = false;
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
      id: generateUid(),
    );

    allMessages.add(message);
    notifyListeners();
  }

  String get recipient =>
      room.users.firstWhere((User user) => user.id != _user.id).id;

  bool isSuccessful(Message message) => successfullySent.contains(message);

  bool isLatestMessage(Message message) =>
      allMessages
          .where(
            (Message m) => message.isReceived()
                ? m.recipient == SharedPrefs().user!.id
                : m.recipient != SharedPrefs().user!.id,
          )
          .last
          .id ==
      message.id;
}
