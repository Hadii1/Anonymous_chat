import 'dart:async';

import 'package:anonymous_chat/database_entities/room_entity.dart';
import 'package:anonymous_chat/models/contact.dart';
import 'package:anonymous_chat/models/local_user.dart';
import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/services.dart/sqlite.dart';
import 'package:anonymous_chat/utilities/enums.dart';

import 'package:tuple/tuple.dart';

abstract class IDatabase<R extends RoomEntity> {
  static IDatabase<OnlineRoomEntity> get onlineDb => FirestoreService();
  static IDatabase<LocalRoomEntity> get offlineDb => SqlitePersistance();

  Future<List<String>> getBlockedContacts({required String userId});

  Future<List<Message>> getAllMessages({required String roomId});

  Stream<List<Tuple2<Map<String, dynamic>, DataChangeType>>> userRoomsChanges({
    required String userId,
  });

  Future<List<Contact>> getMatchingUsers(
      {required List<String> tagsIds, required String userId});

  Future<void> saveNewRoomEntity({required R roomEntity});

  Future<void> writeMessage({required String roomId, required Message message});
  Future<Message?> getMessage(
      {required String messageId, required String roomId});
  Future<void> deleteMessage(String msgId);

  Future<void> markMessageAsRead({
    required String roomId,
    required String messageId,
    bool isRead = true,
  });

  Future<List<R>> getUserRoomsEntities({
    required String userId,
  });

  Future<List<String>> getUserArchivedRooms({required String userId});

  Future<LocalUser?> getUserData({required String id});
  Future<Contact> getContactData({required String contactId, String? userId});

  Future<void> saveUserData({required LocalUser user});
  Future<void> saveContactData({required Contact contact});
  Future<void> saveUserToken(String userId, String token);
  Future<void> saveUserNickname(String nickname, String userId);

  Future<void> archiveChat({required String userId, required String roomId});
  Future<void> unArchiveChat({required String userId, required String roomId});

  Future<void> deleteChat({required String roomId, required String contactId});

  Future<void> blockContact({
    required String userId,
    required String blockedContact,
  });
  Future<void> unblockContact({
    required String userId,
    required String blockedContact,
  });

  Future<bool> isUserBlocked(String contactId, String userId);
  Stream<bool> blockedByContact(String contactId, String userId);

  Future<void> deleteAccount({required String userId});

  Future<List<Map<String, dynamic>>> getUserTags({required String userId});

  Future<List<Map<String, dynamic>>> getTagsById({required List<String> ids});

  Future<void> createNewTag({required UserTag userTag, required String userId});

  // Stream<List<Map<String, dynamic>?>> userTagsChanges({required String userId});

  Stream<Tuple2<Message, DataChangeType>> roomMessagesUpdates(
      {required String roomId});

  Future<void> deactivateTag(
      {required UserTag userTag, required String userId});

  Future<bool> isArchived({required String roomId, required String userId});

  Future<void> activateTag({required UserTag userTag, required String userId});

  Stream<Map<String, dynamic>> activityStatusStream({required String id});

  Future<void> updateUserStatus(
      {required String userId, required Map<String, dynamic> status});
}
