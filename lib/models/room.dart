import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/database_entities/user_entity.dart';
import 'package:anonymous_chat/utilities/general_functions.dart';
import 'package:observable_ish/observable_ish.dart';

class Room {
  final RxList<Message> messages;
  final List<LocalUser> users;
  final String id;

  Room({
    required this.users,
    required this.messages,
    required this.id,
  });

  factory Room.startNew(List<LocalUser> users) {
    return Room(
      messages: RxList<Message>(),
      id: generateUid(),
      users: users,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Room && other.id == id;
  }

  @override
  int get hashCode {
    return messages.hashCode ^ users.hashCode ^ id.hashCode;
  }
}
