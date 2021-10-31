import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/interfaces/prefs_storage_interface.dart';
import 'package:anonymous_chat/models/contact.dart';
import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/providers/tags_provider.dart';
import 'package:anonymous_chat/providers/user_rooms_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final suggestedContactsProvider = FutureProvider.autoDispose<List<Contact>?>(
  (ref) async {
    List<Contact> userContacts = ref.watch(roomsProvider).contacts;

    final String userId = ILocalPrefs.storage.user!.id;

    List<UserTag> selectedTags =
        ref.watch(userTagsProvider).where((UserTag t) => t.isActive).toList();

    if (selectedTags.isEmpty) {
      return [];
    }

    List<Contact> suggestions = [];

    List<Contact> contacts = await IDatabase.onlineDb.getMatchingUsers(
      tagsIds: selectedTags.map((e) => e.tag.id).toList(),
      userId: userId,
    );

    for (Contact contact in contacts) {
      if (!suggestions.map((c) => c).contains(contact))
        suggestions.add(
          contact,
        );
    }

    suggestions.removeWhere((Contact c) =>
        c.id == userId || userContacts.contains(c) || c.isBlocked);

    return suggestions;
  },
);
