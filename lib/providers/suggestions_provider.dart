import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/interfaces/local_storage_interface.dart';
import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/database_entities/user_entity.dart';
import 'package:anonymous_chat/providers/tags_provider.dart';
import 'package:anonymous_chat/providers/user_rooms_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';

final userContactsProvider =
    StateNotifierProvider<UserContactsNotifer, List<LocalUser>?>(
  (ref) => UserContactsNotifer(
    userRooms: ref.watch(userRoomsProvider),
  ),
);

class UserContactsNotifer extends StateNotifier<List<LocalUser>?> {
  final List<Room>? userRooms;

  UserContactsNotifer({required this.userRooms})
      : super(
          userRooms == null
              ? null
              : userRooms
                  .map((r) => r.users.firstWhere(
                      (u) => u.id != ILocalStorage.storage.user!.id))
                  .toList(),
        );

  void removeContact(LocalUser user) {
    if (state != null) {
      state!.remove(user);
      state = state;
    }
  }

  void addContact(LocalUser user) {
    if (state != null) {
      state!.add(user);
      state = state;
    }
  }
}

final suggestedContactsProvider =
    FutureProvider.autoDispose<List<Tuple2<LocalUser, List<Tag>>>?>(
  (ref) async {
    List<String>? userContacts =
        ref.watch(userContactsProvider)?.map((e) => e.id).toList();

    if (userContacts == null) return null;

    final String userId = ILocalStorage.storage.user!.id;

    List<Tag> selectedTags = ref
        .watch(userTagsProvider(userId))
        .where((Tag t) => t.isActive)
        .toList();

    if (selectedTags.isEmpty) {
      return [];
    }

    List<Tuple2<LocalUser, List<Tag>>> suggestions = [];

    List<Map<String, dynamic>> data =
        await IDatabase.databseService.getMatchingUsers(
      tagsIds: selectedTags.map((e) => e.id).toList(),
    );

    for (Map<String, dynamic> map in data) {
      LocalUser user = LocalUser.fromMap(map);
      suggestions.add(
        Tuple2(
          user,
          selectedTags.where((Tag t) => selectedTags.contains(t.id)).toList(),
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
