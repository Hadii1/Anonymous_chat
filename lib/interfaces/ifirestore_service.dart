import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/models/user.dart';
import 'package:anonymous_chat/utilities/enums.dart';
import 'package:tuple/tuple.dart';

abstract class IFirestoreService {
  Future<void> saveUserData({required User user});

  Future<void> saveNewRoom({required Room room});

  Future<Map<String, dynamic>> getUserData({required String id});

  Future<void> writeMessage({required String roomId, required Message message});

  Future<List<Map<String, dynamic>>> getUserRooms({required String userId});

  Future<List<Map<String, dynamic>>> getAllMessages({required String roomId});

  Stream<List<Tuple2<Map<String, dynamic>?, RoomChangeType>>> userRooms(
      {required String userId});

  Future<List<Map<String, dynamic>?>> getMatchingUsers(
      {required List<String> tagsIds});

  Future<void> deleteAccount({required String userId});

  Future<List<Map<String, dynamic>>> getSuggestedTags(
      {required List<String> ids});

  Future<void> addNewTag({required Tag tag, required String userId});

  Stream<List<Map<String, dynamic>?>> userTagsChanges({required String userId});

  Stream<List<Map<String, dynamic>>> roomMessagesUpdates(
      {required String roomId});

  Future<void> onUserDiactivatingTag(
      {required Tag tag, required String userId});

  Future<void> onUserActivatingTag({required Tag tag, required String userId});

  String getRoomReference();

  String getTagReference();

  String getMessageReference({
    required String roomId,
  });

  void markMessageAsRead({required String roomId, required String messageId});
}
