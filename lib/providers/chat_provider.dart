import 'dart:async';
import 'dart:io';

import 'package:anonymous_chat/interfaces/local_storage_interface.dart';
import 'package:anonymous_chat/mappers/chat_room_mapper.dart';
import 'package:anonymous_chat/mappers/message_mapper.dart';
import 'package:anonymous_chat/models/chat_room.dart';
import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/providers/archived_rooms_provider.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/providers/user_rooms_provider.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:anonymous_chat/utilities/enums.dart';
import 'package:anonymous_chat/utilities/general_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:observable_ish/observable_ish.dart';
import 'package:tuple/tuple.dart';

final chattingProvider = ChangeNotifierProvider.family<ChatNotifier, ChatRoom>(
  (ref, room) {
    return ChatNotifier(
      ref.read,
      room: room,
      isArchived: ref.watch(archivedRoomsProvider)!.contains(room.id),
    );
  },
);

class ChatNotifier extends ChangeNotifier {
  ChatNotifier(
    this.read, {
    required this.room,
    required this.isArchived,
  }) {
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

  bool isArchived;

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
      if (change.element != null && change.element!.isSent(userId)) {
        Message message = change.element!;
        if (replyingOn != null) {
          replyingOn = null;
          notifyListeners();
        }

        read(chatsListProvider.notifier).latestActiveChat = room;

        try {
          await retry(
            f: () =>
                messagesMapper.writeMessage(roomId: room.id, message: message),
          );

          successfullySent.add(message);

          notifyListeners();

          if (allMessages.length == 1) {
            // Room is new
            await retry(
              f: () => roomsMapper.saveUserRoom(room: room, userId: userId),
            );
          }

          if (isArchived) {
            read(archivedRoomsProvider.notifier).editArchives(
              roomId: room.id,
              archive: false,
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
        messagesMapper.serverMessagesUpdates(roomId: room.id).listen(
      (Tuple2<Message, MessageServeUpdateType>? update) async {
        if (update == null) {
          return;
        }
        switch (update.item2) {
          case MessageServeUpdateType.MESSAGE_READ:
            Message message = update.item1;

            assert(message.isSent(userId));
            assert(!allMessages.contains(message));
            assert(message.isRead == true);

            int i = allMessages.indexWhere((m) => m.id == message.id);
            assert(i != -1);
            allMessages[i] = message;
            notifyListeners();
            break;

          case MessageServeUpdateType.MESSAGE_RECIEVED:
            Message message = update.item1;

            if (_isChatPageOpened) {
              message = message.markAsRead();
              messagesMapper.markMessageAsRead(
                messageId: message.id,
                roomId: room.id,
                source: SetDataSource.ONLINE,
              );
              messagesMapper.writeMessage(
                roomId: room.id,
                message: message,
                source: SetDataSource.LOCAL,
              );
            }

            assert(message.isReceived(userId));

            if (isArchived) {
              read(archivedRoomsProvider.notifier).editArchives(
                roomId: room.id,
                archive: false,
              );
            }

            allMessages.add(message);
            read(chatsListProvider.notifier).latestActiveChat = room;
            notifyListeners();
            break;
        }
      },
    );
  }

  // Mark all messages as read
  void onChatOpened() {
    _isChatPageOpened = true;
    if (allMessages.isNotEmpty) {
      List<Message> newlyRead = room.messages
          .where((m) => m.isReceived(userId) && !m.isRead)
          .toList();

      for (Message message in newlyRead) {
        Message m = message.markAsRead();
        allMessages[allMessages.indexWhere((m) => m.id == message.id)] = m;
        messagesMapper.markMessageAsRead(messageId: m.id, roomId: room.id);
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
    );

    allMessages.add(message);
    notifyListeners();
  }

  bool isSuccessful(Message message) => successfullySent.contains(message);

  bool isLatestMessage(Message message) =>
      allMessages
          .where(
            (Message m) => message.isReceived(userId)
                ? m.recipient == SharedPrefs().user!.id
                : m.recipient != SharedPrefs().user!.id,
          )
          .last
          .id ==
      message.id;
}
