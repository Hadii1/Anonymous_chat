import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/models/user.dart';

abstract class IFirestoreService {
  Future<void> saveUserData({required User user});

  Future<Map<String, dynamic>> getUserData({required String id});

  Future<void> writeMessage({required String roomId, required Message message});

  Future<List<Map<String, dynamic>?>> getUserChats({required String userId});

  Future<List<Map<String, dynamic>?>> getMatchingUsers(
      {required List<String> tagsIds});

  Future<List<Map<String, dynamic>>> getSuggestedTags(
      {required List<String> ids});

  Future<void> addNewTag({required Tag tag, required String userId});

  Stream<List<Map<String, dynamic>?>> userTagsChanges({required String userId});

  Stream<List<Map<String, dynamic>>> roomMessages({required String roomId});

  Future<void> onUserDiactivatingTag(
      {required Tag tag, required String userId});

  Future<void> onUserActivatingTag({required Tag tag, required String userId});

  String getReference(String collection);
  // Future<Map<String, dynamic>?> getTagData({required id});
}
