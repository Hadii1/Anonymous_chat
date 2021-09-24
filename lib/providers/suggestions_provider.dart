import 'package:anonymous_chat/interfaces/online_database_interface.dart';
import 'package:anonymous_chat/interfaces/local_storage_interface.dart';
import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/database_entities/user_entity.dart';
import 'package:anonymous_chat/providers/tags_provider.dart';
import 'package:anonymous_chat/providers/user_auth_events_provider.dart';
import 'package:anonymous_chat/providers/user_rooms_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';

final userContactsProvider = Provider<List<LocalUser>?>((ref) {
  ref.watch(userAuthEventsProvider);
  List<Room>? userRooms = ref.watch(userRoomsProvider);
  if (userRooms == null) return null;
  return userRooms
      .map((r) =>
          r.users.firstWhere((u) => u.id != ILocalStorage.storage.user!.id))
      .toList();
});

final suggestedContactsProvider =
    FutureProvider.autoDispose<List<Tuple2<LocalUser, List<Tag>>>?>(
  (ref) async {
    List<String>? userContacts =
        ref.watch(userContactsProvider)?.map((e) => e.id).toList();

    if (userContacts == null) return null;

    final String userId = ILocalStorage.storage.user!.id;

    List<UserTag> selectedTags =
        ref.watch(userTagsProvider)!.where((UserTag t) => t.isActive).toList();

    if (selectedTags.isEmpty) {
      return [];
    }

    List<Tuple2<LocalUser, List<Tag>>> suggestions = [];

    List<Map<String, dynamic>> data =
        await IDatabase.db.getMatchingUsers(
      tagsIds: selectedTags.map((e) => e.tag.id).toList(),
    );

    for (Map<String, dynamic> map in data) {
      LocalUser user = LocalUser.fromMap(map);
      suggestions.add(
        Tuple2(
          user,
          selectedTags
              .where((UserTag t) => selectedTags.contains(t.tag.id))
              .map((e) => e.tag)
              .toList(),
        ),
      );
    }

    suggestions.removeWhere(
      (Tuple2<LocalUser, List<Tag>> t) =>
          t.item1.id == userId || userContacts.contains(t.item1.id),
    );

    return suggestions;
  },
);
