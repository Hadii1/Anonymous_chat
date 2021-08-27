import 'dart:async';

import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/utilities/enums.dart';

import 'package:tuple/tuple.dart';

abstract class IDatabase {
  Future<void> saveUserData({required User user});

  Future<void> saveNewRoom({required Room room});

  Future<Map<String, dynamic>> getUserData({required String id});

  Future<void> writeMessage({required String roomId, required Message message});

  Future<List<Map<String, dynamic>>> getUserRooms({required String userId});

  Future<List<Map<String, dynamic>>> getAllMessages({required String roomId});

  Stream<List<Tuple2<Map<String, dynamic>, RoomChangeType>>> userRooms({
    required String userId,
  });

  Future<List<Map<String, dynamic>?>> getMatchingUsers(
      {required List<String> tagsIds});

  Future<void> deleteAccount({required String userId});

  Future<List<Map<String, dynamic>>> getSuggestedTags(
      {required List<String> ids});

  Future<void> addNewTag({required Tag tag, required String userId});

  Stream<List<Map<String, dynamic>?>> userTagsChanges({required String userId});

  Stream<List<Map<String, dynamic>>> roomMessagesUpdates(
      {required String roomId});

  Future<void> deactivateTag({required Tag tag, required String userId});

  Future<void> activateTag({required Tag tag, required String userId});

  String getRoomReference();

  String getTagReference();

  String getMessageReference({
    required String roomId,
  });

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

  Stream<List<String>> blockedByStream({required String userId});

  Stream<Map<String, dynamic>> activityStatusStream({required String id});

  Future<void> updateUserStatus(
      {required String userId, required Map<String, dynamic> status});
}
