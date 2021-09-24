import 'dart:async';

import 'package:anonymous_chat/interfaces/chat_persistance_interface.dart';
import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/database_entities/user_entity.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/utilities/enums.dart';

import 'package:tuple/tuple.dart';

abstract class IDatabase implements DataRepository {
  static IDatabase get db => FirestoreService();

  Future<void> saveUserData({required LocalUser user});

  Future<Map<String, dynamic>>? getUserData({required String id});

  Future<List<String>> getBlockedContacts({required String userId});

  Future<List<String>> getBlockingContacts({required String userId});

  Future<List<Map<String, dynamic>>> getAllMessages({required String roomId});

  Stream<List<Tuple2<Map<String, dynamic>, DataChangeType>>> userRoomsChanges({
    required String userId,
  });

  void markMessageAsRead({required String roomId, required String messageId});

  Future<List<Map<String, dynamic>>> getMatchingUsers(
      {required List<String> tagsIds});

  Future<void> deleteAccount({required String userId});

  Future<List<Map<String, dynamic>>> getUserTags({required String userId});

  Future<List<Map<String, dynamic>>> getTagsById({required List<String> ids});

  Future<void> createNewTag({required UserTag userTag, required String userId});

  // Stream<List<Map<String, dynamic>?>> userTagsChanges({required String userId});

  Stream<Tuple2<Map<String, dynamic>, DataChangeType>> roomMessagesUpdates(
      {required String roomId});

  Future<void> deactivateTag(
      {required UserTag userTag, required String userId});

  Future<void> activateTag({required UserTag userTag, required String userId});

  Future<void> deleteChat({required String roomId});

  Future<void> blockUser({
    required String client,
    required String other,
  });

  Future<void> unblockUser({
    required String client,
    required String other,
  });

  Future<void> archiveChat({required String userId, required String roomId});

  Future<void> unArchiveChat({required String userId, required String roomId});

  Stream<List<Tuple2<String, DataChangeType>>> blockingContactsChanges(
      {required String userId});

  Stream<Map<String, dynamic>> activityStatusStream({required String id});

  Future<void> updateUserStatus(
      {required String userId, required Map<String, dynamic> status});
}
