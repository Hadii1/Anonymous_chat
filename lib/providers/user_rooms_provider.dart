import 'dart:async';

import 'package:anonymous_chat/database_entities/room_entity.dart';
import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/interfaces/local_storage_interface.dart';
import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/database_entities/user_entity.dart';
import 'package:anonymous_chat/providers/archived_rooms_provider.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/utilities/enums.dart';
import 'package:anonymous_chat/utilities/general_functions.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:observable_ish/observable_ish.dart';
import 'package:tuple/tuple.dart';

final chatsListProvider =
    StateNotifierProvider.autoDispose<ChatsListNotifier, List<Room>?>(
  (ref) => ChatsListNotifier(
    rooms: ref.watch(userRoomsProvider),
    archivedRooms: ref.watch(archivedRoomsProvider),
    errorNotifier: ref.read(errorsStateProvider.notifier),
  ),
);

class ChatsListNotifier extends StateNotifier<List<Room>?> {
  final ErrorsNotifier errorNotifier;
  final List<Room>? rooms;
  final List<Room>? archivedRooms;

  ChatsListNotifier({
    required this.rooms,
    required this.archivedRooms,
    required this.errorNotifier,
  }) : super(rooms) {
    if (rooms != null) {
      state = List.from(rooms!);

      state!.sort(
        (a, b) => -a.messages.last.time.compareTo(b.messages.last.time),
      );

      if (archivedRooms != null && archivedRooms!.isNotEmpty) {
        state!.removeWhere(
          (Room room) => archivedRooms!.contains(room),
        );
      }
      state = state;
    }
  }

  set latestActiveChat(Room room) {
    int index = state!.indexOf(room);
    if (index != -1) {
      state!.removeAt(index);
      state!.insert(0, room);

      state = state;
    }
  }

  void deleteChat({required String roomId}) {
    try {
      state!.removeWhere((element) => element.id == roomId);
      state = rooms;
      retry(f: () => IDatabase.databseService.deleteChat(roomId: roomId));
    } on Exception catch (e, _) {
      Future.delayed(Duration(seconds: 2))
          .then((value) => deleteChat(roomId: roomId));
    }
  }
}

// Message updates to this room.
// Either a new  message is recieved
// or a sent message is read
// by the other side

final roomMessagesUpdatesChannel =
    StreamProvider.family<Message?, String>((ref, roomId) {
  final IDatabase db = IDatabase.databseService;

  return db
      .roomMessagesUpdates(roomId: roomId)
      .skip(1)
      .map((List<Map<String, dynamic>> data) {
    assert(data.length <= 1);
    if (data.length == 0) return null;
    Message message = Message.fromMap(data.first);
    return message;
  });
});

final userRoomsProvider = StateNotifierProvider<UserRoomsNotifier, List<Room>?>(
  (ref) => UserRoomsNotifier(),
);

class UserRoomsNotifier extends StateNotifier<List<Room>?> {
  UserRoomsNotifier() : super(null) {
    init();
  }

  final db = IDatabase.databseService;
  final user = ILocalStorage.storage.user!;

  List<Room> _rooms = [];

  late StreamSubscription<List<Tuple2<Map<String, dynamic>, RoomChangeType>>>
      roomChangesListener;

  void init() {
    roomChangesListener = db.userRooms(userId: user.id).listen((data) async {
      for (Tuple2<Map<String, dynamic>, RoomChangeType> m in data) {
        try {
          await _handleRoomsChange(m);
        } on Exception catch (e, _) {
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
      RoomEntity roomEntity = RoomEntity.fromMap(change.item1);
      _rooms.removeWhere((r) => r.id == roomEntity.id);
    } else {
      // A new room is added here.
      RoomEntity roomEntity = RoomEntity.fromMap(change.item1);
      Map<String, dynamic> otherData = await db.getUserData(
        id: roomEntity.users.firstWhere(
          (String id) => id != user.id,
        ),
      );

      User other = User.fromMap(otherData);
      RxList<Message> roomMessages = RxList();

      List<Map<String, dynamic>> messagesData =
          await db.getAllMessages(roomId: roomEntity.id);

      for (Map<String, dynamic> m in messagesData) {
        Message message = Message.fromMap(m);
        assert(message.isSenderBlocked == false);
      }

      roomMessages.sort((a, b) => a.time.compareTo(b.time));

      _rooms.add(
        Room(
          users: [user, other],
          messages: roomMessages,
          id: roomEntity.id,
        ),
      );
    }
  }

  void dispose() {
    super.dispose();
    roomChangesListener.cancel();
  }
}
