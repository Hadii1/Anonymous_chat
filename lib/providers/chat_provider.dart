import 'dart:async';
import 'dart:io';

import 'package:anonymous_chat/interfaces/prefs_storage_interface.dart';
import 'package:anonymous_chat/mappers/chat_room_mapper.dart';
import 'package:anonymous_chat/mappers/message_mapper.dart';
import 'package:anonymous_chat/models/chat_room.dart';
import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/providers/user_auth_events_provider.dart';
import 'package:anonymous_chat/providers/user_rooms_provider.dart';
import 'package:anonymous_chat/utilities/enums.dart';
import 'package:anonymous_chat/utilities/general_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:observable_ish/observable_ish.dart';
import 'package:tuple/tuple.dart';

final chattingProvider = ChangeNotifierProvider.family<ChatNotifier, ChatRoom>(
  (ref, room) {
    ref.watch(userAuthEventsProvider);
    return ChatNotifier(
      ref.read,
      room,
      ref.watch(roomArhivingState(room.id)),
    );
  },
);

class ChatNotifier extends ChangeNotifier {
  ChatNotifier(
    this.read,
    this.room,
    this.isArchived,
  ) {
    initializeRoom();
  }

  final ChatRoom room;
  final Reader read;

  final String userId = ILocalPrefs.storage.user!.id;
  final ChatRoomsMapper roomsMapper = ChatRoomsMapper();
  final MessageMapper messagesMapper = MessageMapper();

  late StreamSubscription<Tuple2<Message, MessageServeUpdateType>?>
      serverMessagesUpdates;
  late StreamSubscription<ListChangeNotification<Message>?>
      localMessagesChanges;

  late RxList<Message> allMessages;
  late List<Message> successfullySent;

  final bool isArchived;

  Message? replyingOn;

  bool _isChatPageOpened = false;

  void dispose() {
    super.dispose();
    serverMessagesUpdates.cancel();
    localMessagesChanges.cancel();
  }

  void initializeRoom() {
    successfullySent = List.from(
      room.messages.where((m) => m.isSent(userId)).toList(),
    );

    allMessages = room.messages;

    localMessagesChanges = allMessages.onChange
        .listen((ListChangeNotification<Message> change) async {
      // When a message is sent locally:
      if (change.element != null &&
          change.op == ListChangeOp.add &&
          change.element!.isSent(userId)) {
        Message message = change.element!;
        if (replyingOn != null) {
          replyingOn = null;
          notifyListeners();
        }

        read(roomsProvider).latestActiveChat = room;

        try {
          if (allMessages.length == 1) {
            // Room is new. This will trigger the room changes listener in [roomsProvider]
            // and the room + msgs will be saved LOCALLY there so we don't do it here.
            await retry(
              f: () => roomsMapper.saveUserRoom(
                  room: room, userId: userId, source: SetDataSource.ONLINE),
            );
            successfullySent.add(message);
          } else {
            await retry(
              f: () => messagesMapper.writeMessage(
                roomId: room.id,
                message: message,
                source: SetDataSource.ONLINE,
              ),
            );
            successfullySent.add(message);
            messagesMapper.writeMessage(
              roomId: room.id,
              message: message,
              source: SetDataSource.LOCAL,
            );
          }

          notifyListeners();

          if (isArchived) {
            read(roomsProvider.notifier).editArchives(
              room: room,
              archive: false,
            );
          }
        } on Exception catch (e, _) {
          read(errorsStateProvider.notifier).set(
            e is SocketException ? 'Bad internet connection.' : 'Unknown error',
          );
        }
      }
    });

    serverMessagesUpdates = messagesMapper
        .serverMessagesUpdates(roomId: room.id, userId: userId)
        .listen(
      (Tuple2<Message, MessageServeUpdateType>? update) async {
        if (update == null) {
          return;
        }
        switch (update.item2) {
          case MessageServeUpdateType.MESSAGE_READ:
            Message message = update.item1;
            assert(message.isSent(userId));
            assert(allMessages.contains(message));
            assert(successfullySent.contains(message));
            assert(message.isRead == true);
            int i = allMessages.indexWhere((m) => m.id == message.id);
            allMessages[i] = message;
            notifyListeners();
            break;

          case MessageServeUpdateType.MESSAGE_RECEIVED:
            Message message = update.item1;
            assert(message.isReceived(userId));
            if (_isChatPageOpened) {
              message = message.markAsRead();
              messagesMapper.editReadStatus(
                messageId: message.id,
                roomId: room.id,
                source: SetDataSource.ONLINE,
              );
            }
            messagesMapper.writeMessage(
              roomId: room.id,
              message: message,
              source: SetDataSource.LOCAL,
            );

            if (isArchived) {
              read(roomsProvider.notifier).editArchives(
                room: room,
                archive: false,
              );
            }

            allMessages.add(message);
            read(roomsProvider.notifier).latestActiveChat = room;
            notifyListeners();
            break;
        }
      },
    );
  }

  // Mark all received messages as read
  void onChatOpened() {
    _isChatPageOpened = true;
    if (allMessages.isNotEmpty) {
      List<int> msgsToUpdate = [];
      for (int i = 0; i < allMessages.length; i++) {
        Message message = allMessages[i];
        if (message.isReceived(userId) && !message.isRead) {
          messagesMapper.editReadStatus(messageId: message.id, roomId: room.id);

          msgsToUpdate.add(i);
        }
      }
      for (int i in msgsToUpdate) {
        Message message = allMessages[i].markAsRead();
        allMessages[i] = message;
      }

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

  Future<void> onSendPressed(String text) async {
    Message message = Message.create(
      sender: userId,
      recipient: room.contact.id,
      content: text,
      time: DateTime.now().millisecondsSinceEpoch,
      replyingOn: replyingOn?.id,
      id: generateUid(),
      roomId: room.id,
    );

    allMessages.add(message);
    notifyListeners();
  }

  bool isSuccessful(Message message) => successfullySent.contains(message);

  bool isLatestMessage(Message message) => allMessages.last.id == message.id;
}
