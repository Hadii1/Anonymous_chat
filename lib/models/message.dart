import 'dart:convert';

class Message {
  final String sender;
  final String recipient;
  final String content;
  final String id;
  // Milliseconds since epoch
  final int time;

  Message({
    required this.sender,
    required this.recipient,
    required this.content,
    required this.time,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'recipient': recipient,
      'content': content,
      'time': time,
      'id': id,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      sender: map['sender'],
      id: map['id'],
      recipient: map['recipient'],
      content: map['content'],
      time: map['time'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Message && other.id == id;
  }

  @override
  int get hashCode {
    return sender.hashCode ^
        recipient.hashCode ^
        content.hashCode ^
        id.hashCode ^
        time.hashCode;
  }

  @override
  String toString() {
    return content;
  }
}
