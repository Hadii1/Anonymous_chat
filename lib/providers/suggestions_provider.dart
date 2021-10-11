import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/interfaces/local_storage_interface.dart';
import 'package:anonymous_chat/models/chat_room.dart';
import 'package:anonymous_chat/models/contact.dart';
import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/providers/tags_provider.dart';
import 'package:anonymous_chat/providers/user_auth_events_provider.dart';
import 'package:anonymous_chat/providers/user_rooms_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';

final userContactsProvider = Provider<List<Contact>?>((ref) {
  ref.watch(userAuthEventsProvider);
  List<ChatRoom>? userRooms = ref.watch(userRoomsProvider);
  if (userRooms == null) return null;
  return userRooms.map((r) => r.contact).toList();
});

final suggestedContactsProvider =
    FutureProvider.autoDispose<List<Tuple2<Contact, List<Tag>>>?>(
  (ref) async {
    List<String>? userContacts =
        ref.watch(userContactsProvider)?.map((e) => e.id).toList();

    if (userContacts == null) return null;

    final String userId = ILocalPrefs.storage.user!.id;

    List<UserTag> selectedTags =
        ref.watch(userTagsProvider)!.where((UserTag t) => t.isActive).toList();

    if (selectedTags.isEmpty) {
      return [];
    }

    List<Tuple2<Contact, List<Tag>>> suggestions = [];

    List<Contact> contacts = await IDatabase.onlineDb.getMatchingUsers(
      tagsIds: selectedTags.map((e) => e.tag.id).toList(),
    );

    for (Contact contact in contacts) {
      suggestions.add(
        Tuple2(
          contact,
          selectedTags
              .where((UserTag t) => selectedTags.contains(t.tag.id))
              .map((e) => e.tag)
              .toList(),
        ),
      );
    }

    suggestions.removeWhere(
      (Tuple2<Contact, List<Tag>> t) =>
          t.item1.id == userId || userContacts.contains(t.item1.id),
    );

    return suggestions;
  },
);
