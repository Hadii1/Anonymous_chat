import 'dart:async';

import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/providers/archived_rooms_provider.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';
import 'package:anonymous_chat/utilities/enums.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';

final chatsListProvider = StateNotifierProvider.autoDispose(
  (ref) => ChatsListNotifier(
    rooms: ref.watch(userRoomsProvider.state),
    archivedRooms: ref.watch(archivedRoomsProvider.state),
    errorNotifier: ref.read(errorsProvider),
  ),
);

class ChatsListNotifier extends StateNotifier<List<Room>?> {
  ChatsListNotifier({
    required this.rooms,
    required this.archivedRooms,
    required this.errorNotifier,
  }) : super(rooms) {
    if (rooms != null) {
      chatsList = List.from(rooms!);

      chatsList.sort(
        (a, b) => -a.messages.last.time.compareTo(b.messages.last.time),
      );

      if (archivedRooms != null && archivedRooms!.isNotEmpty) {
        chatsList.removeWhere(
          (Room room) => archivedRooms!.contains(room),
        );
      }
      state = chatsList;
    }
  }

  List<Room> chatsList = [];

  final ErrorNotifier errorNotifier;
  final List<Room>? rooms;
  final List<Room>? archivedRooms;

  set latestActiveChat(Room room) {
    int index = chatsList.indexOf(room);
    if (index != -1) {
      chatsList.removeAt(index);
      chatsList.insert(0, room);

      state = chatsList;
    }
  }

  void deleteChat({required String roomId}) {
    try {
      FirestoreService().deleteChat(roomId: roomId);
      // rooms.removeWhere((element) => element.id == roomId);
      chatsList.removeWhere((element) => element.id == roomId);
      state = rooms;
    } on Exception catch (e, s) {
      Future.delayed(Duration(seconds: 2))
          .then((value) => deleteChat(roomId: roomId));

      errorNotifier.submitError(exception: e, stackTrace: s);
    }
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

class UserRoomsNotifier extends StateNotifier<List<Room>?> {
  UserRoomsNotifier(this._errorNotifier) : super(null) {
    init();
  }

  final _firestore = FirestoreService();
  final _user = LocalStorage().user!;
  final ErrorNotifier _errorNotifier;

  List<Room> _rooms = [];

  late StreamSubscription<List<Tuple2<Map<String, dynamic>, RoomChangeType>>>
      roomChangesStreamSubscription;

  void init() {
    roomChangesStreamSubscription =
        _firestore.userRooms(userId: _user.id).listen((data) async {
      for (Tuple2<Map<String, dynamic>, RoomChangeType> m in data) {
        try {
          await _handleRoomsChange(m);
        } on Exception catch (e, s) {
          _errorNotifier.submitError(exception: e, stackTrace: s);

          Future.delayed(Duration(seconds: 2))
              .then((_) => _handleRoomsChange(m));
        }
      }

      state = _rooms;
    });
  }

  Future<void> _handleRoomsChange(
      Tuple2<Map<String, dynamic>, RoomChangeType> change) async {
    if (change.item2 == RoomChangeType.delete) {
      Room room = Room.fromFirestoreMap(change.item1);
      _rooms.remove(room);
    } else {
      Room room = Room.fromFirestoreMap(change.item1);

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
        if (!message.isSenderBlocked) {
          roomMessages.add(message);
        }
      }

      roomMessages.sort((a, b) => a.time.compareTo(b.time));

      _rooms.add(
        Room(
          users: [_user, other],
          id: room.id,
          participants: [_user.id, other.id],
          messages: roomMessages,
        ),
      );
    }
  }

  void dispose() {
    super.dispose();
    roomChangesStreamSubscription.cancel();
  }
}

final userRoomsProvider =
    StateNotifierProvider((ref) => UserRoomsNotifier(ref.read(errorsProvider)));
