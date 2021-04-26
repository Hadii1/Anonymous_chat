import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final userTagsProvider = StateNotifierProvider.family<TagsState, String>(
    (ref, id) => TagsState(userId: id));

class TagsState extends StateNotifier<List<Tag>> {
  final String userId;
  final firestore = FirestoreService();

  TagsState({required this.userId}) : super([]) {
    firestore
        .userTagsChanges(userId: userId)
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
