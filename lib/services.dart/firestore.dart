import 'dart:async';

import 'package:anonymous_chat/database_entities/room_entity.dart';
import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/models/contact.dart';
import 'package:anonymous_chat/models/local_user.dart';
import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/utilities/custom_exceptions.dart';
import 'package:anonymous_chat/utilities/enums.dart';
import 'package:anonymous_chat/utilities/extentions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuple/tuple.dart';

class FirestoreService implements IDatabase<OnlineRoomEntity> {
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() => _instance;

  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<void> writeMessage(
      {required String roomId, required Message message}) async {
    await _db
        .collection('Rooms')
        .doc(roomId)
        .collection('Messages')
        .doc(message.id)
        .set(
          message.toMap(),
        );
  }

  @override
  Future<void> deleteChat(
      {required String roomId, required String contactId}) async {
    QuerySnapshot<Map<String, dynamic>> a =
        await _db.collection('Rooms').doc(roomId).collection('Messages').get();
    for (QueryDocumentSnapshot<Map<String, dynamic>> s in a.docs) {
      await s.reference.delete();
    }
    await _db.collection('Rooms').doc(roomId).delete();
  }

  @override
  Future<void> blockContact({
    required String userId,
    required String blockedContact,
  }) async {
    await _db
        .collection('Users')
        .doc(userId)
        .collection('Blocked Users')
        .doc(blockedContact)
        .set({
      'blockingUser': userId,
      'blockedUser': blockedContact,
    });
  }

  @override
  Future<void> unblockContact({
    required String userId,
    required String blockedContact,
  }) async {
    await _db
        .collection('Users')
        .doc(userId)
        .collection('Blocked Users')
        .doc(blockedContact)
        .delete();
  }

  @override
  Future<void> saveUserData({required LocalUser user, List<Tag>? tags}) async {
    await _db.runTransaction((transaction) async {
      transaction.set(
        _db.collection('Users').doc(user.id),
        user.toMap(),
      );
      if (tags != null) {
        for (Tag tag in tags) {
          transaction.set(
            _db.collection('Users').doc(user.id).collection('Tags').doc(tag.id),
            tag.toMap(),
          );
        }
      }
    });
  }

  @override
  Future<Contact> getContactData(
      {required String contactId, String? userId}) async {
    DocumentSnapshot<Map<String, dynamic>> doc =
        await _db.collection('Users').doc(contactId).get();

    bool isBlocked = (await _db
            .collection('Users')
            .doc(userId)
            .collection('Blocked Users')
            .doc(contactId)
            .get())
        .exists;

    Map<String, dynamic> map = {'isBlocked': isBlocked};
    map.addAll(doc.data()!);

    return Contact.fromMap(map);
  }

  @override
  Future<void> saveContactData({required Contact contact}) {
    throw UnimplementedError();
  }

  @override
  Stream<List<Tuple2<Map<String, dynamic>, DataChangeType>>> userRoomsChanges({
    required String userId,
  }) {
    return _db
        .collection('Rooms')
        .where('participiants', arrayContains: userId)
        .snapshots()
        .skip(1)
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) =>
              snapshot.docChanges.map(
            (DocumentChange<Map<String, dynamic>> c) {
              late DataChangeType type;
              switch (c.type) {
                case DocumentChangeType.added:
                  type = DataChangeType.ADDED;
                  break;
                case DocumentChangeType.modified:
                  throw CustomException(
                    INVALID_ROOM_CHANGE_TYPE,
                    details:
                        'User room change type was EDIT, only ADD and REMOVE are permitted.',
                  );
                case DocumentChangeType.removed:
                  type = DataChangeType.DELETED;
                  break;
              }
              return Tuple2(c.doc.data()!, type);
            },
          ).toList(),
        );
  }

  @override
  Future<List<OnlineRoomEntity>> getUserRoomsEntities(
      {required String userId}) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _db
        .collection('Rooms')
        .where('participiants', arrayContains: userId)
        .get();

    return querySnapshot.docs
        .map((e) => OnlineRoomEntity.fromMap(e.data()))
        .toList()
        .cast<OnlineRoomEntity>();
  }

  @override
  Future<LocalUser?> getUserData({required String id}) async {
    DocumentSnapshot<Map<String, dynamic>> doc =
        await _db.collection('Users').doc(id).get();
    return doc.data() == null ? null : LocalUser.fromMap(doc.data()!);
  }

  @override
  Future<List<Contact>> getMatchingUsers(
      {required List<String> tagsIds, required String userId}) async {
    List<String> contacts = [];
    List<Map<String, dynamic>> contactsData = [];

    for (String id in tagsIds) {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _db
          .collection('Tags')
          .doc(id)
          .collection('Tag Users')
          .where('isActive', isEqualTo: true)
          .get();

      contacts.addAll(querySnapshot.docs.map((e) => e.id));
    }

    List<String> blockedContacts = await getBlockedContacts(userId: userId);

    for (String id in contacts) {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await _db.collection('Users').doc(id).get();
      if (documentSnapshot.data() == null) continue;

      bool isBlocked = blockedContacts.contains(id);
      Map<String, dynamic> map = {'isBlocked': isBlocked};
      map.addAll(documentSnapshot.data()!);
      contactsData.add(map);
    }

    return contactsData.map((e) => Contact.fromMap(e)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getTagsById(
      {required List<String> ids}) async {
    List<Map<String, dynamic>> data = [];
    for (String id in ids) {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await _db.collection('Tags').doc(id).get();
      if (documentSnapshot.data() != null) data.add(documentSnapshot.data()!);
    }

    return data;
  }

  @override
  Future<List<Map<String, dynamic>>> getUserTags(
      {required String userId}) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _db
        .collectionGroup('Tag Users')
        .where('userId', isEqualTo: userId)
        .get();

    return querySnapshot.docs.map((d) => d.data()).toList();
  }

  @override
  Future<void> createNewTag({
    required String userId,
    required UserTag userTag,
  }) async {
    await _db.collection('Tags').doc(userTag.tag.id).set(userTag.tag.toMap());

    await _db
        .collection('Tags')
        .doc(userTag.tag.id)
        .collection('Tag Users')
        .doc(userId)
        .set(
          userTag.toMap(),
        );
  }

  @override
  Future<void> activateTag(
      {required UserTag userTag, required String userId}) async {
    _db
        .collection('Tags')
        .doc(userTag.tag.id)
        .collection('Tag Users')
        .doc(userId)
        .set(
          userTag.toMap(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> deactivateTag(
      {required UserTag userTag, required String userId}) async {
    _db
        .collection('Tags')
        .doc(userTag.tag.id)
        .collection('Tag Users')
        .doc(userId)
        .set(
          userTag.toMap(),
          SetOptions(merge: true),
        );
  }

  @override
  Stream<Tuple2<Message, DataChangeType>> roomMessagesUpdates({
    required String roomId,
  }) {
    return Stream.castFrom<Tuple2<Message, DataChangeType>?,
            Tuple2<Message, DataChangeType>>(
        _db
            .collection('Rooms')
            .doc(roomId)
            .collection('Messages')
            .snapshots()
            .skip(1)
            .map((QuerySnapshot<Map<String, dynamic>> event) {
      List<Tuple2<Message, DataChangeType>> a = event.docChanges
          .where(
        (element) =>
            !element.doc.metadata.isFromCache &&
            element.type != DocumentChangeType.removed,
      )
          .map(
        (DocumentChange<Map<String, dynamic>> e) {
          return Tuple2(
              Message.fromMap(
                e.doc.data()!,
              ),
              e.type.changeType());
        },
      ).toList();
      return a.isEmpty ? null : a.first;
    }).where((event) => event != null));
  }

  @override
  Future<List<Message>> getAllMessages({required String roomId}) async {
    var a = await _db
        .collection('Rooms')
        .doc(roomId)
        .collection('Messages')
        .orderBy('time')
        .get();

    return a.docs.map((e) => Message.fromMap(e.data())).toList();
  }

  @override
  Future<void> saveNewRoomEntity({required RoomEntity roomEntity}) async {
    await _db.collection('Rooms').doc(roomEntity.id).set(
          roomEntity.toMap(),
        );
  }

  @override
  Future<void> markMessageAsRead({
    required String roomId,
    required String messageId,
    bool isRead = true,
  }) async {
    await _db
        .collection('Rooms')
        .doc(roomId)
        .collection('Messages')
        .doc(messageId)
        .update(
      {'isRead': isRead},
    );
  }

  @override
  Future<void> deleteAccount({required userId}) async {
    QuerySnapshot d = await _db
        .collection('Rooms')
        .where('participiants', arrayContains: userId)
        .get();
    for (QueryDocumentSnapshot s in d.docs) {
      await s.reference.delete();
    }

    QuerySnapshot<Map<String, dynamic>> k = await _db
        .collection('Users')
        .doc(userId)
        .collection('Blocked Users')
        .get();
    for (QueryDocumentSnapshot s in k.docs) {
      await s.reference.delete();
    }

    QuerySnapshot<Map<String, dynamic>> g = await _db
        .collectionGroup('Tag Users')
        .where('userId', isEqualTo: userId)
        .get();
    for (QueryDocumentSnapshot s in g.docs) {
      await s.reference.delete();
    }

    await _db.collection('Users').doc(userId).delete();
  }

  @override
  Future<bool> isArchived(
      {required String roomId, required String userId}) async {
    DocumentSnapshot<Map<String, dynamic>> a = await _db
        .collection('Users')
        .doc(userId)
        .collection('Archived Rooms')
        .doc(roomId)
        .get();

    return a.exists;
  }

  @override
  Future<void> archiveChat(
          {required String userId, required String roomId}) async =>
      await _db
          .collection('Users')
          .doc(userId)
          .collection('Archived Rooms')
          .doc(roomId)
          .set({});

  @override
  Future<void> unArchiveChat(
          {required String userId, required String roomId}) async =>
      await _db
          .collection('Users')
          .doc(userId)
          .collection('Archived Rooms')
          .doc(roomId)
          .delete();

  @override
  Stream<Map<String, dynamic>> activityStatusStream({required String id}) {
    return _db.collection('Users').doc(id).snapshots().map(
          (DocumentSnapshot<Map<String, dynamic>> event) =>
              event.data()!['activityStatus'],
        );
  }

  @override
  Future<void> updateUserStatus(
      {required String userId, required Map<String, dynamic> status}) async {
    return _db
        .collection('Users')
        .doc(userId)
        .set({'activityStatus': status}, SetOptions(merge: true));
  }

  @override
  Future<List<String>> getUserArchivedRooms({required String userId}) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _db
        .collection('Users')
        .doc(userId)
        .collection('Archived Rooms')
        .get();
    return querySnapshot.docs.map((e) => e.id).toList();
  }

  @override
  Future<List<String>> getBlockedContacts({required String userId}) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _db
        .collection('Users')
        .doc(userId)
        .collection('Blocked Users')
        .get();
    return querySnapshot.docs.map((e) => e.id).toList();
  }

  @override
  Future<bool> isUserBlocked(String contactId, String userId) async {
    DocumentSnapshot<Map<String, dynamic>> d = await _db
        .collection('Users')
        .doc(contactId)
        .collection('Blocked Users')
        .doc(userId)
        .get();
    return d.exists;
  }

  @override
  Stream<bool> blockedByContact(String contactId, String userId) {
    return _db
        .collection('Users')
        .doc(contactId)
        .collection('Blocked Users')
        .snapshots()
        .skip(1)
        .where(
            (event) => event.docChanges.map((e) => e.doc.id).contains(userId))
        .map((QuerySnapshot<Map<String, dynamic>> event) =>
            event.docChanges.first.type == DocumentChangeType.added);
  }

  @override
  Future<Message?> getMessage(
      {required String messageId, required String roomId}) async {
    DocumentSnapshot<Map<String, dynamic>> d = await _db
        .collection('Rooms')
        .doc(roomId)
        .collection('Messages')
        .doc(messageId)
        .get();
    if (d.data() == null) return null;
    return Message.fromMap(d.data()!);
  }

  @override
  Future<void> deleteMessage(String msgId) {
    throw UnimplementedError();
  }

  @override
  Future<void> saveUserToken(String userId, String token) async {
    await _db.collection('Users').doc(userId).set(
        {
          'tokens': FieldValue.arrayUnion([token]),
        },
        SetOptions(
          mergeFields: ['tokens'],
        ));
  }

  @override
  Future<void> saveUserNickname(String nickname, String userId) async {
    await _db.collection('Users').doc(userId).update({'nickname': nickname});
  }
}
