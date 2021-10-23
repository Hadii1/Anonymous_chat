import 'dart:async';

import 'package:anonymous_chat/interfaces/prefs_storage_interface.dart';
import 'package:anonymous_chat/mappers/chat_room_mapper.dart';
import 'package:anonymous_chat/mappers/contact_mapper.dart';
import 'package:anonymous_chat/models/chat_room.dart';
import 'package:anonymous_chat/models/contact.dart';
import 'package:anonymous_chat/providers/starting_data_provider.dart';
import 'package:anonymous_chat/syncer/rooms_syncer.dart';
import 'package:anonymous_chat/utilities/enums.dart';
import 'package:anonymous_chat/utilities/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';

final roomsProvider = ChangeNotifierProvider(
  (ref) => RoomsNotifier(
    ref.watch(startingDataProvider)!,
  ),
);

class RoomsNotifier extends ChangeNotifier {
  late final StreamSubscription<List<Tuple2<ChatRoom, RoomsUpdateType>>>
      _roomChanges;
  final ChatRoomsMapper _roomsMapper = ChatRoomsMapper();
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

  RoomsNotifier(this.allRooms) {
    // Sort
    List<ChatRoom> temp = List.from(allRooms.where((r) => !r.isArchived));
    temp.sort(
      (a, b) => -a.messages.last.time.compareTo(b.messages.last.time),
    );
    allRooms = [...temp];

    // First fetch of online rooms and syncing
    _roomsMapper
        .getUserRooms(userId: _userId, source: GetDataSource.ONLINE)
        .then((List<ChatRoom> onlineRooms) async {
      bool modified = false;
      if (allRooms.isNotEmpty) {
        modified = await RoomsSyncer().syncRooms(onlineRooms, allRooms);
      }
      if (modified) {
        allRooms = [...onlineRooms];
      }
      isFirstFetch = false;
      notifyListeners();
    });
    _listenToChanges();
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
    retry(
      shouldRethrow: false,
      f: () => ChatRoomsMapper().deleteRoom(room, SetDataSource.BOTH),
    );
  }

  void toggleBlock({ChatRoom? room, Contact? contact, required bool block}) {
    assert((room == null && contact == null) == false);
    int index;
    if (contact == null) {
      index = allRooms.indexOf(room!);
    } else {
      index = allRooms.indexWhere((r) => r.contact == contact);
    }
    ChatRoom selectedRoom = allRooms[index];

    assert(index != -1);
    allRooms[index] =
        block ? selectedRoom.blockContact() : selectedRoom.unBlockContact();
    notifyListeners();
    retry(
      shouldRethrow: false,
      f: () => ContactMapper().toggleContactBlock(
        contact: selectedRoom.contact,
        block: block,
        userId: _userId,
      ),
    );
  }

  void editArchives({required ChatRoom room, required bool archive}) {
    int index = allRooms.indexOf(room);
    assert(index != -1);
    allRooms[index] = archive ? room.archive() : room.unArchive();
    notifyListeners();
    retry(
      shouldRethrow: false,
      f: () => ChatRoomsMapper().editArchives(
        roomId: room.id,
        archive: archive,
        userId: _userId,
      ),
    );
  }

  void _listenToChanges() {
    _roomChanges = _roomsMapper
        .roomsServerUpdates()
        .listen((List<Tuple2<ChatRoom, RoomsUpdateType>> event) {
      print(event);
      for (var update in event) {
        switch (update.item2) {
          case RoomsUpdateType.ROOM_DELETED:
            allRooms.remove(update.item1);
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

            allRooms.add(update.item1);
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
