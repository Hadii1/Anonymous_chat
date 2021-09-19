import 'dart:async';

import 'package:anonymous_chat/database_entities/room_entity.dart';
import 'package:anonymous_chat/interfaces/database_interface.dart';
import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/database_entities/user_entity.dart';
import 'package:anonymous_chat/utilities/custom_exceptions.dart';
import 'package:anonymous_chat/utilities/enums.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:tuple/tuple.dart';

class FirestoreService implements IDatabase {
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
  Future<void> deleteChat({required String roomId}) async {
    QuerySnapshot<Map<String, dynamic>> a =
        await _db.collection('Rooms').doc(roomId).collection('Messages').get();
    for (QueryDocumentSnapshot<Map<String, dynamic>> s in a.docs) {
      await s.reference.delete();
    }
    await _db.collection('Rooms').doc(roomId).delete();
  }

  @override
  Future<void> blockUser({
    required String client,
    required String other,
  }) async {
    await _db
        .collection('Users')
        .doc(client)
        .collection('Blocked Users')
        .doc(other)
        .set({
      'blockingUser': client,
      'blockedUser': other,
    });
  }

  Future<void> unblockUser({
    required String client,
    required String other,
  }) async {
    await _db
        .collection('Users')
        .doc(client)
        .collection('Blocked Users')
        .doc(other)
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
  Stream<List<Tuple2<Map<String, dynamic>, DataChangeType>>> userRooms({
    required String userId,
  }) {
    return _db
        .collection('Rooms')
        .where('participants', arrayContains: userId)
        .snapshots()
        .skip(1)
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) =>
              snapshot.docChanges.map(
            (DocumentChange<Map<String, dynamic>> c) {
              late DataChangeType type;
              switch (c.type) {
                case DocumentChangeType.added:
                  type = DataChangeType.added;
                  break;
                case DocumentChangeType.modified:
                  throw CustomException(
                    INVALID_ROOM_CHANGE_TYPE,
                    details:
                        'User room change type was EDIT, only ADD and REMOVE are granted.',
                  );
                case DocumentChangeType.removed:
                  type = DataChangeType.delete;
                  break;
              }
              return Tuple2(c.doc.data()!, type);
            },
          ).toList(),
        );
  }

  @override
  Stream<List<Tuple2<String, DataChangeType>>> blockingContactsChanges(
      {required String userId}) {
    return _db
        .collectionGroup('Blocked Users')
        .where('blockedUser', isEqualTo: userId)
        .snapshots()
        .skip(1)
        .map(
      (QuerySnapshot<Map<String, dynamic>> querySnapshot) {
        List<Tuple2<String, DataChangeType>> changes = [];

        querySnapshot.docChanges.forEach(
          (DocumentChange<Map<String, dynamic>> documentChange) {
            if (documentChange.type == DocumentChangeType.added) {
              changes.add(Tuple2(documentChange.doc.data()!['blockingUser'],
                  DataChangeType.added));
            } else if (documentChange.type == DocumentChangeType.removed) {
              changes.add(Tuple2(documentChange.doc.data()!['blockingUser'],
                  DataChangeType.delete));
            }
          },
        );

        return changes;
      },
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getUserRooms(
      {required String userId}) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _db
        .collection('Rooms')
        .where('participants', arrayContains: userId)
        .get();
    return querySnapshot.docs.map((e) => e.data()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getMatchingUsers(
      {required List<String> tagsIds}) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _db
        .collection('Users')
        .where('activeTags', arrayContainsAny: tagsIds)
        .get(GetOptions(
          source: Source.server,
        ));

    List<Map<String, dynamic>> usersData = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> doc
        in querySnapshot.docs) {
      usersData.add(doc.data());
    }

    return usersData;
  }

  @override
  Future<Map<String, dynamic>>? getUserData({required String id}) async {
    DocumentSnapshot<Map<String, dynamic>> doc =
        await _db.collection('Users').doc(id).get();
    return doc.data()!;
  }

  @override
  Future<List<Map<String, dynamic>>> getSuggestedTags(
      {required List<String> ids}) async {
    List<Map<String, dynamic>> data = [];
    for (String id in ids) {
      QuerySnapshot<Map<String, dynamic>> query = await _db
          .collectionGroup('Tags')
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      data.addAll(
        query.docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> e) => e.data()),
      );
    }

    return data;
  }

  @override
  Future<void> addNewTag({required Tag tag, required String userId}) async {
    _db.collection('Users').doc(userId).collection('Tags').doc(tag.id).set(
          Tag(
            id: tag.id,
            label: tag.label,
            isActive: true,
          ).toMap(),
        );

    await _db.collection('Users').doc(userId).update(
      {
        'activeTags': FieldValue.arrayUnion([
          tag.id,
        ])
      },
    );
  }

  Stream<List<Map<String, dynamic>>> userTagsChanges({required String userId}) {
    return _db
        .collection('Users')
        .doc(userId)
        .collection('Tags')
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> event) =>
              event.docChanges.map((e) => e.doc.data()!).toList(),
        );
  }

  @override
  Future<void> activateTag({required Tag tag, required String userId}) async {
    await _db
        .collection('Users')
        .doc(userId)
        .collection('Tags')
        .doc(tag.id)
        .set(
          tag.toMap(),
          SetOptions(
            merge: true,
          ),
        );

    await _db.collection('Users').doc(userId).update(
      {
        'activeTags': FieldValue.arrayUnion([
          tag.id,
        ])
      },
    );
  }

  @override
  Future<void> deactivateTag({required Tag tag, required String userId}) async {
    await _db
        .collection('Users')
        .doc(userId)
        .collection('Tags')
        .doc(tag.id)
        .set(
          tag.toMap(),
          SetOptions(
            merge: true,
          ),
        );

    await _db.collection('Users').doc(userId).update(
      {
        'activeTags': FieldValue.arrayRemove(
          [
            tag.id,
          ],
        )
      },
    );
  }

  @override
  Stream<List<Map<String, dynamic>>> roomMessagesUpdates({
    required String roomId,
  }) {
    return _db
        .collection('Rooms')
        .doc(roomId)
        .collection('Messages')
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> event) => event.docChanges
              .where((element) => !element.doc.metadata.isFromCache)
              .where((element) => element.type != DocumentChangeType.removed)
              .map(
                (DocumentChange<Map<String, dynamic>> e) => e.doc.data()!,
              )
              .toList(),
        );
  }

  @override
  Future<List<Map<String, dynamic>>> getAllMessages(
      {required String roomId}) async {
    var a =
        await _db.collection('Rooms').doc(roomId).collection('Messages').get();

    return a.docs.map((e) => e.data()).toList();
  }

  @override
  Future<void> saveNewRoom({required RoomEntity roomEntity}) async {
    await _db.collection('Rooms').doc(roomEntity.id).set(
          roomEntity.toMap(),
        );
  }

  @override
  void markMessageAsRead({required String roomId, required String messageId}) {
    _db
        .collection('Rooms')
        .doc(roomId)
        .collection('Messages')
        .doc(messageId)
        .update(
      {'isRead': true},
    );
  }

  @override
  Future<void> deleteAccount({required userId}) async {
    //  Delete the user rooms
    QuerySnapshot d = await _db
        .collection('Rooms')
        .where('participants', arrayContains: userId)
        .get();
    for (QueryDocumentSnapshot a in d.docs) {
      await a.reference.delete();
    }

    QuerySnapshot<Map<String, dynamic>> k = await _db
        .collection('Users')
        .doc(userId)
        .collection('Blocked Users')
        .get();
    for (QueryDocumentSnapshot a in k.docs) {
      await a.reference.delete();
    }

    //  Delete references where the user is blocked
    QuerySnapshot s = await _db
        .collectionGroup('Blocked Users')
        .where('blocked by', isEqualTo: userId)
        .get();
    for (QueryDocumentSnapshot a in s.docs) {
      await a.reference.delete();
    }

    // Delete the user document
    await _db.collection('Users').doc(userId).delete();
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
  Future<List<String>> getBlockingContacts({required String userId}) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _db
        .collectionGroup('Blocked Users')
        .where('blockedUser', isEqualTo: userId)
        .get();

    return querySnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> e) =>
            e.data()['blockingUser'] as String)
        .toList();
  }
}
