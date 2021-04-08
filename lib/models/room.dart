import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/user.dart';

class Room {
  final List<Message> messages;
  final List<User> participants;
  final String id;

  Room({
    required this.messages,
    required this.participants,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'messages': messages.map((x) => x.toMap()).toList(),
      'participants': participants.map((User user) => user.toMap()).toList(),
      'id': id,
    };
  }

  factory Room.startChat({
    required String id,
    required List<User> users,
  }) =>
      Room(
        messages: [],
        participants: users,
        id: id,
      );

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      messages:
          List<Message>.from(map['messages']?.map((x) => Message.fromMap(x))),
      participants: (map['participants'] as List<Map<String, dynamic>>)
          .map((Map<String, dynamic> map) => User.fromMap(map))
          .toList(),
      id: map['id'],
    );
  }

  // String toJson() => json.encode(toMap());

  // factory Room.fromJson(String source) => Room.fromMap(json.decode(source));
}
