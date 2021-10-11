import 'dart:async';

import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/interfaces/local_storage_interface.dart';
import 'package:anonymous_chat/mappers/chat_room_mapper.dart';
import 'package:anonymous_chat/models/chat_room.dart';
import 'package:anonymous_chat/providers/archived_rooms_provider.dart';
import 'package:anonymous_chat/providers/errors_provider.dart';
import 'package:anonymous_chat/providers/user_auth_events_provider.dart';
import 'package:anonymous_chat/utilities/enums.dart';
import 'package:anonymous_chat/utilities/general_functions.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';

final chatsListProvider =
    StateNotifierProvider<ChatsListNotifier, List<ChatRoom>?>((ref) {
  ref.watch(userAuthEventsProvider);
  return ChatsListNotifier(
    rooms: ref.watch(userRoomsProvider),
    archivedRooms: ref.watch(archivedRoomsProvider),
    errorNotifier: ref.read(errorsStateProvider.notifier),
  );
});

class ChatsListNotifier extends StateNotifier<List<ChatRoom>?> {
  final ErrorsNotifier errorNotifier;
  final List<ChatRoom>? rooms;
  final List<String>? archivedRooms;

  ChatsListNotifier({
    required this.rooms,
    required this.archivedRooms,
    required this.errorNotifier,
  }) : super(rooms) {
    if (archivedRooms == null || rooms == null) return;

    List<ChatRoom> temp = List.from(rooms!);

    temp.sort(
      (a, b) => -a.messages.last.time.compareTo(b.messages.last.time),
    );

    if (archivedRooms!.isNotEmpty) {
      temp.removeWhere(
        (ChatRoom room) => archivedRooms!.contains(room.id),
      );
    }
    state = List.from(temp);
  }

  set latestActiveChat(ChatRoom room) {
    int index = state!.indexOf(room);
    if (index != -1) {
      state!.removeAt(index);
      state!.insert(0, room);

      state = state;
    }
  }

  void deleteChat({required String roomId}) {
    state!.removeWhere((ChatRoom room) => room.id == roomId);
    state = state;
    retry(f: () => IDatabase.onlineDb.deleteChat(roomId: roomId));
  }
}

final localUserRoomsFuture =
    FutureProvider.autoDispose<List<ChatRoom>?>((ref) async {
  ref.maintainState = true;
  ref.watch(userAuthEventsProvider);

  final ChatRoomsMapper roomsMapper = ChatRoomsMapper();
  final user = ILocalPrefs.storage.user!;

  try {
    List<ChatRoom> rooms = await retry<List<ChatRoom>>(
      f: () async => await roomsMapper.getUserRooms(userId: user.id),
    );
    return rooms;
  } on Exception catch (e) {
    print(e);
    return null;
  }
});

final userRoomsProvider =
    StateNotifierProvider<UserRoomsChangesNotifier, List<ChatRoom>?>((ref) {
  ref.watch(userAuthEventsProvider);

  return UserRoomsChangesNotifier();
});

class UserRoomsChangesNotifier extends StateNotifier<List<ChatRoom>?> {
  UserRoomsChangesNotifier() : super(null) {
    init();
  }

  final ChatRoomsMapper roomsMapper = ChatRoomsMapper();
  final String userId = ILocalPrefs.storage.user!.id;

  List<ChatRoom> _rooms = [];

  late StreamSubscription<List<Tuple2<ChatRoom, RoomsServerUpdateType>>>
      roomChangesListener;

  set rooms(List<ChatRoom> rooms) => state = rooms;

  void init() {
    roomChangesListener = roomsMapper
        .roomsServerUpdates()
        .listen((List<Tuple2<ChatRoom, RoomsServerUpdateType>> event) {
      for (var update in event) {
        switch (update.item2) {
          case RoomsServerUpdateType.ROOM_DELETED:
            _rooms.remove(update.item1);
            state = _rooms;
            break;
          case RoomsServerUpdateType.ROOM_ADDED:
            if (_rooms.contains(update.item1)) break;
            _rooms.insert(0, update.item1);
            state = _rooms;
            break;
        }
      }
    });
  }

  void dispose() {
    super.dispose();
    roomChangesListener.cancel();
  }
}
