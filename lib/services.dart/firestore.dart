import 'package:anonymous_chat/interfaces/ifirestore_service.dart';
import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/room.dart';
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
        .doc(message.id)
        .set(
          message.toMap(),
        );
  }

  // Future<Map<String, dynamic>> getRoom(String id) async {
  //   DocumentSnapshot a = await _db.collection('Rooms').doc(id).get();
  //   return a.data()!;
  // }

  @override
  Future<void> saveUserData({required User user, List<Tag>? tags}) async {
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
  Stream<List<Map<String, dynamic>?>> userRooms({required String userId}) {
    return _db
        .collection('Rooms')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map(
          (QuerySnapshot q) => q.docChanges
              .where((element) => !element.doc.metadata.isFromCache)
              .map((DocumentChange e) => e.doc.data()!)
              .toList(),
        );
  }

  @override
  Future<List<Map<String, dynamic>>> getUserRooms(
      {required String userId}) async {
    var a = await _db
        .collection('Rooms')
        .where('participants', arrayContains: userId)
        .get();
    return a.docs.map((e) => e.data()!).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getMatchingUsers(
      {required List<String> tagsIds}) async {
    QuerySnapshot querySnapshot = await _db
        .collection('Users')
        .where('activeTags', arrayContainsAny: tagsIds)
        .get(GetOptions(
          source: Source.server,
        ));

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
              event.docChanges.map((e) => e.doc.data()!).toList(),
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
  Stream<List<Map<String, dynamic>>> roomMessagesUpdates(
      {required String roomId}) {
    return _db
        .collection('Rooms')
        .doc(roomId)
        .collection('Messages')
        .snapshots()
        .map(
          (QuerySnapshot event) => event.docChanges
              .where((element) => !element.doc.metadata.isFromCache)
              .map((DocumentChange e) => e.doc.data()!)
              .toList(),
        );
  }

  @override
  Future<List<Map<String, dynamic>>> getAllMessages(
      {required String roomId}) async {
    var a =
        await _db.collection('Rooms').doc(roomId).collection('Messages').get();

    return a.docs.map((e) => e.data()!).toList();
  }

  @override
  Future<void> saveNewRoom({required Room room}) async {
    await _db.collection('Rooms').doc(room.id).set(
          room.toFirestoreMap(),
        );
  }

  @override
  String getRoomReference() => _db.collection('Rooms').doc().id;

  @override
  String getMessageReference({
    required String roomId,
  }) =>
      _db.collection('Rooms').doc(roomId).collection('Messages').doc().id;

  @override
  String getTagReference() => _db.collection('Tags').doc().id;

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

  Future<void> deleteAccount({required userId}) async {
    await _db.collection('Users').doc(userId).delete();
  }
}
