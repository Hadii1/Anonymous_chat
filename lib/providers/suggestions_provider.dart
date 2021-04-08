import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/providers/user_provider.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final suggestedContactsProvider = FutureProvider.autoDispose<List<User>>(
  (ref) async {
    List<Tag> selectedTags = ref.watch(userTagsProvider.state);
    List<User> users = [];

    if (selectedTags.isEmpty) return [];

    List<Map<String, dynamic>> data = await FirestoreService().getMatchingUsers(
      tagsIds: selectedTags.map((e) => e.id).toList(),
    );

    for (Map<String, dynamic> map in data) {
      User user = User.fromFirestoreMap(map);
      users.add(user);
    }

    users.removeWhere((element) => element.id == LocalStorage().user!.id);

    return users;
  },
);
