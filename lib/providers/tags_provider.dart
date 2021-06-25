import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final userTagsProvider =
    StateNotifierProvider.family<TagsState, List<Tag>, String>(
        (ref, id) => TagsState(userId: id));

class TagsState extends StateNotifier<List<Tag>> {
  final String userId;
  final firestore = FirestoreService();

  List<Tag> tags = [];

  bool _firstFetch = true;

  TagsState({required this.userId}) : super([]) {
    firestore
        .userTagsChanges(userId: userId)
        .listen((List<Map<String, dynamic>?> data) {
      for (Map<String, dynamic>? map in data) {
        Tag tag = Tag.fromMap(map!);
        if (tags.contains(tag)) {
          tags[tags.indexOf(tag)] = tag;
        } else {
          tags.insert(0, tag);
        }
      }

      if (_firstFetch) {
        _firstFetch = false;
        tags.sort((a, b) {
          if (a.isActive && b.isActive)
            return -1;
          else if (a.isActive && !b.isActive)
            return -1;
          else
            return 1;
        });
      }

      state = tags;
    });
  }
}
