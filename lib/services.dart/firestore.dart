import 'package:anonymous_chat/interfaces/ifirestore_service.dart';
import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/models/user.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService implements IFirestoreService {
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
        .add(message.toMap());
  }

  @override
  Future<void> saveUserData({required User user}) async {
    await _db.runTransaction((transaction) async {
      transaction.set(
        _db.collection('Users').doc(user.id),
        user.toFirestoreMap(),
      );

      for (Tag tag in user.tags) {
        transaction.set(
          _db.collection('Users').doc(user.id).collection('Tags').doc(tag.id),
          tag.toMap(),
        );
      }
    });
  }

  Future<List<Map<String, dynamic>?>> getUserChats(
      {required String userId}) async {
    QuerySnapshot data = await _db
        .collection('Rooms')
        .where('Participants', arrayContains: userId)
        .get();

    return data.docs.map((QueryDocumentSnapshot e) => e.data()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getMatchingUsers(
      {required List<String> tagsIds}) async {
    QuerySnapshot querySnapshot = await _db
        .collection('Users')
        .where('activeTags', arrayContainsAny: tagsIds)
        .get();

    List<Map<String, dynamic>> usersData = [];

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      usersData.add(doc.data()!);
    }

    return usersData;
  }

  @override
  Future<Map<String, dynamic>> getUserData({required String id}) async {
    DocumentSnapshot doc = await _db.collection('Users').doc(id).get();
    return doc.data()!;
  }

  @override
  Future<List<Map<String, dynamic>>> getSuggestedTags(
      {required List<String> ids}) async {
    List<Map<String, dynamic>> data = [];
    for (String id in ids) {
      var query = await _db
          .collectionGroup('Tags')
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      data.addAll(
        query.docs.map((QueryDocumentSnapshot e) => e.data()!),
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
          (QuerySnapshot event) =>
              event.docs.map((QueryDocumentSnapshot e) => e.data()!).toList(),
        );
  }

  @override
  Future<void> onUserActivatingTag(
      {required Tag tag, required String userId}) async {
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
  Future<void> onUserDiactivatingTag(
      {required Tag tag, required String userId}) async {
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
  String getReference(String collection) => _db.collection(collection).doc().id;

  @override
  Stream<List<Map<String, dynamic>>> roomMessages({required String roomId}) {
    return _db
        .collection('Rooms')
        .doc('id')
        .collection('Messages')
        .snapshots()
        .map(
          (QuerySnapshot event) =>
              event.docs.map((QueryDocumentSnapshot e) => e.data()!).toList(),
        );
  }
}
