import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/models/user.dart';

abstract class IFirestoreService {
  Future<void> saveUserData({required User user});

  Future<void> saveNewRoom({required Room room});

  Future<Map<String, dynamic>> getUserData({required String id});

  Future<void> writeMessage({required String roomId, required Message message});

  Future<List<Map<String, dynamic>>> getUserRooms({required String userId});

  Future<List<Map<String, dynamic>>> getAllMessages({required String roomId});

  Stream<List<Map<String, dynamic>?>> userRooms({required String userId});

  Future<List<Map<String, dynamic>?>> getMatchingUsers(
      {required List<String> tagsIds});

  Future<List<Map<String, dynamic>>> getSuggestedTags(
      {required List<String> ids});

  Future<void> addNewTag({required Tag tag, required String userId});

  Stream<List<Map<String, dynamic>?>> userTagsChanges({required String userId});

  Stream<List<Map<String, dynamic>>> roomMessagesStream(
      {required String roomId});

  Stream<List<Map<String, dynamic>>> roomMessagesReadStatus(
      {required String roomId});

  Future<void> onUserDiactivatingTag(
      {required Tag tag, required String userId});

  Future<void> onUserActivatingTag({required Tag tag, required String userId});

  Stream<Map<String, dynamic>> roomLatestMessage({required String roomId});

  String getRoomReference();

  String getTagReference();

  String getMessageReference({
    required String roomId,
  });

  void markMessageAsRead({required String roomId, required String messageId});
}
