import 'dart:async';

import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatsSorterProvider = StateNotifierProvider.autoDispose(
  (ref) => ChatsSorter(ref.watch(userRoomsProvider).data!.value),
);

class ChatsSorter extends StateNotifier<List<Room>> {
  ChatsSorter(this.rooms) : super(rooms);

  late List<Room> rooms;

  final StreamController<int> _indexCtrl = StreamController.broadcast();

  Stream<int> get changedIndex => _indexCtrl.stream;

  set latestActiveChat(Room room) {
    int index = rooms.indexOf(room);
    if (index != -1) {
      _indexCtrl.sink.add(index);
      rooms.removeAt(index);
      rooms.insert(0, room);

      state = rooms;
    }
  }

  void dispose() {
    super.dispose();
    _indexCtrl.close();
  }
}

// Notifies the sender when a message is received by the recipient
// or when the recipient gets a message
final roomMessagesUpdatesChannel =
    StreamProvider.family<Message?, String>((ref, id) {
  final _firestore = FirestoreService();

  return _firestore
      .roomMessagesUpdates(roomId: id)
      .skip(1)
      .map((List<Map<String, dynamic>> data) {
    assert(data.length <= 1);
    if (data.length == 0) return null;
    Message message = Message.fromMap(data.first);

    return message;
  });
});

final userRoomsProvider = StreamProvider.autoDispose<List<Room>>(
  (ref) async* {
    try {
      ref.onDispose(() {
        print('disposed');
      });

      final _firestore = FirestoreService();
      final _user = LocalStorage().user!;

      List<Room> rooms = [];

      await for (List<Map<String, dynamic>?> data
          in FirestoreService().userRooms(userId: _user.id)) {
        for (Map<String, dynamic>? m in data) {
          Room room = Room.fromFirestoreMap(m!);

          Map<String, dynamic> contactData = await _firestore.getUserData(
            id: room.participants.firstWhere(
              (String id) => id != _user.id,
            ),
          );

          User other = User.fromMap(contactData);
          List<Message> roomMessages = [];

          List<Map<String, dynamic>> messagesData =
              await _firestore.getAllMessages(roomId: room.id);

          for (Map<String, dynamic> m in messagesData) {
            Message message = Message.fromMap(m);

            roomMessages.add(message);
          }

          roomMessages.sort((a, b) => a.time.compareTo(b.time));

          rooms.add(
            Room(
              users: [_user, other],
              id: room.id,
              participants: [_user.id, other.id],
              messages: roomMessages,
            ),
          );
        }
        if (rooms.isNotEmpty) {
          rooms.sort(
            (a, b) => -a.messages.last.time.compareTo(b.messages.last.time),
          );
        }

        yield rooms;
      }
    } on Exception catch (e, s) {
      ref
          .read(errorsProvider)
          .submitError(exception: e, stackTrace: s, hint: 'userRoomsProvider');
    }
  },
);
