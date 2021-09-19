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
  final List<String>? archivedRooms;

  ChatsListNotifier({
    required this.rooms,
    required this.archivedRooms,
    required this.errorNotifier,
  }) : super(rooms) {
    if (archivedRooms == null || rooms == null) return;

    state = List.from(rooms!);

    state!.sort(
      (a, b) => -a.messages.last.time.compareTo(b.messages.last.time),
    );

    if (archivedRooms!.isNotEmpty) {
      state!.removeWhere(
        (Room room) => archivedRooms!.contains(room),
      );
    }
    state = state;
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
    state!.removeWhere((element) => element.id == roomId);
    state = rooms;
    retry(f: () => IDatabase.databseService.deleteChat(roomId: roomId));
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

final userRoomsFuture = FutureProvider.autoDispose<List<Room>>((ref) async {
  ref.maintainState = true;

  final db = IDatabase.databseService;
  final user = ILocalStorage.storage.user!;

  List<Room> temp = [];

  List<Map<String, dynamic>> data = await db.getUserRooms(userId: user.id);
  List<RoomEntity> roomEntities =
      data.map((Map<String, dynamic> e) => RoomEntity.fromMap(e)).toList();

  for (RoomEntity entity in roomEntities) {
    // Get contact data
    Map<String, dynamic>? otherData = await db.getUserData(
      id: entity.users.firstWhere(
        (String id) => id != user.id,
      ),
    );

    if (otherData != null) {
      LocalUser other = LocalUser.fromMap(otherData);

      // Prepare msgs
      RxList<Message> roomMessages = RxList();
      List<Map<String, dynamic>> messagesData =
          await db.getAllMessages(roomId: entity.id);
      for (Map<String, dynamic> m in messagesData) {
        Message message = Message.fromMap(m);
        assert(message.isSenderBlocked == false);
      }
      roomMessages.sort((a, b) => a.time.compareTo(b.time));
      temp.add(
        Room(id: entity.id, messages: roomMessages, users: [
          user,
          other,
        ]),
      );
    }
  }
  ref.read(userRoomsProvider.notifier).rooms = temp;
  return temp;
});

final userRoomsProvider =
    StateNotifierProvider<UserRoomsChangesNotifier, List<Room>?>(
  (ref) => UserRoomsChangesNotifier(),
);

class UserRoomsChangesNotifier extends StateNotifier<List<Room>?> {
  UserRoomsChangesNotifier() : super(null) {
    init();
  }

  final db = IDatabase.databseService;
  final user = ILocalStorage.storage.user!;

  List<Room> _rooms = [];

  late StreamSubscription<List<Tuple2<Map<String, dynamic>, DataChangeType>>>
      roomChangesListener;

  set rooms(List<Room> rooms) => state = rooms;

  void init() {
    roomChangesListener = db.userRooms(userId: user.id).listen((data) async {
      for (Tuple2<Map<String, dynamic>, DataChangeType> m in data) {
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
      Tuple2<Map<String, dynamic>, DataChangeType> change) async {
    if (change.item2 == DataChangeType.delete) {
      RoomEntity roomEntity = RoomEntity.fromMap(change.item1);
      _rooms.removeWhere((r) => r.id == roomEntity.id);
    } else {
      // A new room is added here.
      RoomEntity roomEntity = RoomEntity.fromMap(change.item1);

      // Get contact data
      Map<String, dynamic>? otherData = await db.getUserData(
        id: roomEntity.users.firstWhere(
          (String id) => id != user.id,
        ),
      );

      if (otherData != null) {
        LocalUser other = LocalUser.fromMap(otherData);

        // Prepare msgs
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
  }

  void dispose() {
    super.dispose();
    roomChangesListener.cancel();
  }
}
