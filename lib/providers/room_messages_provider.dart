import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final roomMessagesProvider =
    StateNotifierProvider.autoDispose.family<RoomMessages, String>(
  (ref, roomId) => RoomMessages(roomId: roomId),
);

class RoomMessages extends StateNotifier<List<Message>?> {
  final String roomId;
  RoomMessages({
    required this.roomId,
  }) : super(null) {
    final firestore = FirestoreService();

    firestore
        .roomMessages(roomId: roomId)
        .listen((List<Map<String, dynamic>?> data) {
      List<Message> messages = [];
      for (Map<String, dynamic>? map in data) {
        Message message = Message.fromMap(map!);
        messages.add(message);
        state = messages;
      }
    });
  }
}
