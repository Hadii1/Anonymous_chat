import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final userTagsProvider = StateNotifierProvider((_) => UserTagsState());

class UserTagsState extends StateNotifier<List<Tag>> {
  UserTagsState() : super(LocalStorage().user!.tags) {
    final firestore = FirestoreService();
    final storage = LocalStorage();

    firestore
        .userTagsChanges(userId: storage.user!.id)
        .listen((List<Map<String, dynamic>?> data) {
      List<Tag> tags = [];
      for (Map<String, dynamic>? map in data) {
        Tag tag = Tag.fromMap(map!);
        tags.add(tag);
        state = tags;
      }
    });
  }
}
