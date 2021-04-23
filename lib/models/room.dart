import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/models/user.dart';

class Room {
  final List<Message>? messages;
  final List<String> participants;
  final List<User>? users;
  final String id;

  Room({
    this.messages,
    this.users,
    required this.participants,
    required this.id,
  });

  // Room copyWith({
  //   List<Message>? messages,
  //   List<String>? participants,
  //   String? id,
  //   List<User>? users,
  // }) {
  //   return Room(
  //     messages: messages ?? this.messages,
  //     users: users ?? this.users,
  //     participants: participants ?? this.participants,
  //     id: id ?? this.id,
  //   );
  // }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'participants': participants,
      'id': id,
    };
  }

  factory Room.fromFirestoreMap(Map<String, dynamic> map) {
    return Room(
      participants: List<String>.from(map['participants']),
      id: map['id'],
    );
  }

  @override
  String toString() {
    return 'Room(messages: $messages, participants: $participants, users: $users, id: $id)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Room && other.id == id;
  }

  @override
  int get hashCode {
    return messages.hashCode ^
        participants.hashCode ^
        users.hashCode ^
        id.hashCode;
  }
}
