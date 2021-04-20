import 'dart:async';

import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final latestActiveChatProvider = StateNotifierProvider(
  (ref) => LatestActiveChat(),
);

class LatestActiveChat extends StateNotifier<Room?> {
  LatestActiveChat() : super(null);

  final StreamController<Room> _latestRoomCtrl = StreamController();

  set currentState(Room room) {
    state = room;
    _latestRoomCtrl.add(room);
  }

  Stream<Room> get mostRecentRoom => _latestRoomCtrl.stream;
}

final newMessageChannel = StreamProvider.family<Message, String>((ref, id) {
  final _firestore = FirestoreService();

  return _firestore
      .roomMessagesStream(roomId: id)
      .skip(1)
      .map((List<Map<String, dynamic>> data) {
    if (data.length != 1) print(data.length);
    assert(data.length <= 1);

    Message message = Message.fromMap(data.first);

    return message;
  });
});

final userRoomsProvider = StreamProvider<List<Room>>(
  (ref) async* {
    final _firestore = FirestoreService();
    final _user = LocalStorage().user;

    List<Room> rooms = [];

    if (_user == null) {
      yield [];
    }

    await for (List<Map<String, dynamic>?> data
        in FirestoreService().userRooms(userId: _user!.id)) {
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

      rooms.sort(
        (a, b) => -a.messages!.last.time.compareTo(b.messages!.last.time),
      );

      yield rooms;
    }
  },
);
