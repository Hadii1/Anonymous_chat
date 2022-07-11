import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/interfaces/prefs_storage_interface.dart';
import 'package:anonymous_chat/interfaces/search_service_interface.dart';
import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/providers/user_auth_events_provider.dart';
import 'package:anonymous_chat/utilities/general_functions.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final userTagsFuture = FutureProvider.autoDispose<List<UserTag>>((ref) async {
  ref.maintainState = true;
  ref.watch(userAuthEventsProvider);

  final db = IDatabase.onlineDb;
  final user = ILocalPrefs.storage.user!;

  List<Map<String, dynamic>> tagsData = await db.getUserTags(userId: user.id);
  List<UserTag> tags = tagsData.map((e) => UserTag.fromMap(e)).toList();

  return tags;
});

final userTagsProvider =
    StateNotifierProvider.autoDispose<UserTagsState, List<UserTag>>((ref) {
  ref.maintainState = true;
  return UserTagsState(ref.watch(userTagsFuture).asData!.value);
});

class UserTagsState extends StateNotifier<List<UserTag>> {
  final db = IDatabase.onlineDb;
  final searchService = ISearchService.searchService;
  final user = ILocalPrefs.storage.user!;

  UserTagsState(List<UserTag> tags) : super(tags);

  void addNewTag(Tag tag) {
    UserTag userTag = UserTag(
      tag: tag,
      isActive: true,
      userId: user.id,
      activatedAt: DateTime.now().millisecondsSinceEpoch,
      deactivatedAt: -1,
    );

    state = [userTag, ...state];
    retry(f: () => db.createNewTag(userTag: userTag, userId: user.id));
    retry(f: () => searchService.addSearchableTag(tag: tag));
  }

  void deactivateTag(Tag tag) {
    int index = state.indexWhere((t) => t.tag.id == tag.id);
    assert(index != -1);

    UserTag newTag = UserTag(
      tag: tag,
      userId: user.id,
      isActive: false,
      deactivatedAt: DateTime.now().millisecondsSinceEpoch,
      activatedAt: -1,
    );

    state[index] = newTag;
    state = [...state];
    retry(
      shouldRethrow: false,
      f: () => db.deactivateTag(userTag: newTag, userId: user.id),
    );
  }

  void activateTag(Tag tag) {
    int index = state.indexWhere((t) => t.tag.id == tag.id);

    UserTag newTag = UserTag(
      tag: tag,
      userId: user.id,
      isActive: true,
      activatedAt: DateTime.now().millisecondsSinceEpoch,
      deactivatedAt: -1,
    );

    if (index == -1) {
      state.add(newTag);
      state = [...state];
    } else {
      state[index] = newTag;
      state = [...state];
    }

    retry(
        shouldRethrow: false,
        f: () => db.activateTag(userTag: newTag, userId: user.id));
  }
}
