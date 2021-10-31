import 'dart:async';

import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/interfaces/prefs_storage_interface.dart';
import 'package:anonymous_chat/mappers/chat_room_mapper.dart';
import 'package:anonymous_chat/mappers/contact_mapper.dart';
import 'package:anonymous_chat/models/chat_room.dart';
import 'package:anonymous_chat/models/contact.dart';
import 'package:anonymous_chat/providers/blocked_contacts_provider.dart';
import 'package:anonymous_chat/providers/chat_provider.dart';
import 'package:anonymous_chat/providers/starting_data_provider.dart';
import 'package:anonymous_chat/providers/user_auth_events_provider.dart';
import 'package:anonymous_chat/syncer/rooms_syncer.dart';
import 'package:anonymous_chat/utilities/enums.dart';
import 'package:anonymous_chat/utilities/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';

final roomsProvider = ChangeNotifierProvider((ref) {
  ref.watch(userAuthEventsProvider);
  return RoomsNotifier(
    ref.watch(startingDataProvider)!,
    ref.read,
  );
});

class RoomsNotifier extends ChangeNotifier {
  late final StreamSubscription<List<Tuple2<ChatRoom, RoomsUpdateType>>>
      _roomChanges;
  final ChatRoomsMapper _roomsMapper = ChatRoomsMapper();
  final Reader read;
  final String _userId = ILocalPrefs.storage.user!.id;
  bool isFirstFetch = true;
  List<ChatRoom> allRooms;

  List<ChatRoom> get unarhcivedRooms =>
      allRooms.where((r) => !r.isArchived).toList();
  List<ChatRoom> get archivedRooms =>
      allRooms.where((r) => r.isArchived).toList();
  List<Contact> get contacts => allRooms.map((e) => e.contact).toList();
  List<Contact> get blockedContacts =>
      contacts.where((c) => c.isBlocked).toList();

  RoomsNotifier(this.allRooms, this.read) {
    // Sort
    allRooms.sort(
      (a, b) => -a.messages.last.time.compareTo(b.messages.last.time),
    );

    // First fetch of online rooms and syncing
    _roomsMapper
        .getUserRooms(userId: _userId, source: GetDataSource.ONLINE)
        .then((List<ChatRoom> onlineRooms) async {
      // We assing the surely up to date rooms from the online databse
      // and silently sync the local database.
      RoomsSyncer()
          .syncRooms(
            onlineRooms,
            allRooms,
            _userId,
            lastSyncDate: ILocalPrefs.storage.lastSyncingDate,
          )
          .then((value) => ILocalPrefs.storage
              .setSyncingDate(DateTime.now().millisecondsSinceEpoch));

      allRooms.clear();
      allRooms = [...onlineRooms];

      isFirstFetch = false;
      notifyListeners();
    });

    // Initialize the room's chat state to handle logic of receiving msgs.
    allRooms.forEach((r) => read(chattingProvider(r)));

    _listenToRoomsChanges();
  }

  set latestActiveChat(ChatRoom room) {
    int index = allRooms.indexOf(room);
    if (index != -1) {
      allRooms.removeAt(index);
      allRooms.insert(0, room);

      notifyListeners();
    }
  }

  void deleteChat({required ChatRoom room}) {
    allRooms.remove(room);
    notifyListeners();
    // When successfully deleted online, this will trigger the rooms
    // listener below and it will be deleted from the local database.
    retry(
      shouldRethrow: false,
      f: () => ChatRoomsMapper().deleteRoom(room, SetDataSource.ONLINE),
    );
  }

  void toggleBlock({ChatRoom? room, Contact? contact, required bool block}) {
    assert((room != null) ^ (contact != null));

    Contact blockedContact = contact ?? room!.contact;

    int index;
    if (room != null) {
      index = allRooms.indexOf(room);
    } else {
      index = allRooms.indexWhere((r) => r.contact.id == contact!.id);
    }
    if (index != -1) {
      ChatRoom selectedRoom = allRooms[index];
      allRooms[index] =
          block ? selectedRoom.blockContact() : selectedRoom.unBlockContact();
      retry(
        shouldRethrow: false,
        f: () => ContactMapper().toggleContactBlock(
          contact: blockedContact,
          block: block,
          userId: _userId,
          source: SetDataSource.LOCAL,
        ),
      );
    }

    retry(
      shouldRethrow: false,
      f: () => ContactMapper().toggleContactBlock(
        contact: blockedContact,
        block: block,
        userId: _userId,
        source: SetDataSource.ONLINE,
      ),
    );

    read(blockedContactsProvider.notifier)
        .toggleBlock(block: block, contact: blockedContact);

    notifyListeners();
  }

  void editArchives({required ChatRoom room, required bool archive}) {
    int index = allRooms.indexOf(room);
    assert(index != -1);
    allRooms[index] = archive ? room.archive() : room.unArchive();
    notifyListeners();
    read(roomArhivingState(room.id).notifier).archived = archive;
    retry(
      shouldRethrow: false,
      f: () => ChatRoomsMapper().editArchives(
        roomId: room.id,
        archive: archive,
        userId: _userId,
      ),
    );
  }

  void _listenToRoomsChanges() {
    _roomChanges = _roomsMapper
        .roomsServerUpdates(_userId)
        .listen((List<Tuple2<ChatRoom, RoomsUpdateType>> event) {
      for (var update in event) {
        switch (update.item2) {
          case RoomsUpdateType.ROOM_DELETED:
            allRooms.remove(update.item1);
            read(roomExistanceState(update.item1.id).notifier).deleted = false;
            notifyListeners();
            retry(
              shouldRethrow: false,
              f: () =>
                  _roomsMapper.deleteRoom(update.item1, SetDataSource.LOCAL),
            );
            break;
          case RoomsUpdateType.ROOM_ADDED:
            if (allRooms.contains(update.item1)) break;
            _roomsMapper.saveUserRoom(
              room: update.item1,
              userId: _userId,
              source: SetDataSource.LOCAL,
            );

            allRooms.insert(0, update.item1);
            notifyListeners();
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    _roomChanges.cancel();
    super.dispose();
  }
}

final roomArhivingState =
    StateNotifierProvider.family<RoomArchiveState, bool, String>(
  (ref, String roomId) => RoomArchiveState(
    ref
        .read(startingDataProvider)!
        .where((room) => room.isArchived)
        .where((room) => room.id == roomId)
        .isNotEmpty,
  ),
);

class RoomArchiveState extends StateNotifier<bool> {
  RoomArchiveState(bool state) : super(state);
  set archived(bool value) => state = value;
}

// This is to watch if the other contacts deleted the room
// while this user is viewing it.
// The state is only watched in the corresponding room screen.
final roomExistanceState =
    StateNotifierProvider.family<RoomExistanceState, bool, String>(
  (ref, String roomId) => RoomExistanceState(),
);

class RoomExistanceState extends StateNotifier<bool> {
  RoomExistanceState() : super(true);
  set deleted(bool value) => state = value;
}

// To watch if the contact is blocked by the other user.
// The state is only watched in the corresponding room screen.
final userBlockedState =
    StateNotifierProvider.family<UserBlockedNotifier, bool?, String>(
  (ref, String contactId) =>
      UserBlockedNotifier(contactId, ref.watch(userAuthEventsProvider)!.id),
);

class UserBlockedNotifier extends StateNotifier<bool?> {
  final String contactId;
  final String userId;
  late final StreamSubscription<bool> listener;
  UserBlockedNotifier(this.contactId, this.userId) : super(null) {
    IDatabase.onlineDb
        .isUserBlocked(contactId, userId)
        .then((bool value) => state = value);

    _setListener();
  }

  void _setListener() {
    listener = IDatabase.onlineDb
        .blockedByContact(contactId, userId)
        .listen((bool value) {
      if (state != value) {
        state = value;
      }
    });
  }

  @override
  dispose() {
    listener.cancel();
    super.dispose();
  }
}
