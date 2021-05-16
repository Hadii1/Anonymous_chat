import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/providers/tags_provider.dart';
import 'package:anonymous_chat/providers/user_rooms_provider.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';

final suggestedContactsProvider =
    FutureProvider.autoDispose<List<Tuple2<User, List<Tag>>>?>(
  (ref) async {
    List<String> userContacts = [];
    List<Room>? currentRooms = ref.watch(userRoomsProvider.state);
    // This means loading state
    if (currentRooms == null) return null;

    for (Room r in currentRooms) {
      userContacts.addAll(r.participants);
    }

    List<Tuple2<User, List<Tag>>> suggestions = [];

    List<Tag> selectedTags = ref
        .watch(userTagsProvider(LocalStorage().user!.id).state)
        .where((t) => t.isActive)
        .toList();

    if (selectedTags.isEmpty) return [];

    List<Map<String, dynamic>> data = await FirestoreService().getMatchingUsers(
      tagsIds: selectedTags.map((e) => e.id).toList(),
    );

    for (Map<String, dynamic> map in data) {
      User user = User.fromMap(map);
      suggestions.add(
        Tuple2(
          user,
          selectedTags
              .where((Tag t) => user.activeTags.contains(t.id))
              .toList(),
        ),
      );
    }

    suggestions.removeWhere(
      (Tuple2<User, List<Tag>> t) =>
          t.item1.id == LocalStorage().user!.id ||
          userContacts.contains(t.item1.id),
    );

    return suggestions;
  },
);
