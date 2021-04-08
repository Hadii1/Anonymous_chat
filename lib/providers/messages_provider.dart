import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/services.dart/firestore.dart';
import 'package:anonymous_chat/services.dart/local_storage.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final messagesProvider = FutureProvider.autoDispose<List<Room>>(
  (ref) async {
    ref.maintainState = true;

    List<Map<String, dynamic>?> data =
        await FirestoreService().getUserChats(userId: LocalStorage().user!.id);

    data.removeWhere((Map<String, dynamic>? element) => element == null);

    return data.map((Map<String, dynamic>? d) => Room.fromMap(d!)).toList();
  },
);
