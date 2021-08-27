class Message {
  final String sender;
  final String recipient;
  final String content;
  final String id;

  final bool isSenderBlocked;

  // The replied on message id if exists
  final String? replyingOn;
  // Milliseconds since epoch
  final int time;

  bool isRead;

  Message({
    required this.sender,
    required this.recipient,
    required this.isSenderBlocked,
    required this.content,
    required this.time,
    required this.id,
    this.isRead = false,
    this.replyingOn,
  });

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'recipient': recipient,
      'content': content,
      'time': time,
      'id': id,
      'replyingOn': replyingOn,
      'isSenderBlocked': isSenderBlocked,
      'isRead': isRead,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      sender: map['sender'],
      id: map['id'],
      recipient: map['recipient'],
      replyingOn: map['replyingOn'],
      content: map['content'],
      time: map['time'],
      isSenderBlocked: map['isSenderBlocked'],
      isRead: map['isRead'] ?? false,
    );
  }

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
    return 'Message(sender: $sender, recipient: $recipient, content: $content, id: $id, isSenderBlocked: $isSenderBlocked, replyingOn: $replyingOn, time: $time, isRead: $isRead)';
  }
}

class MessageType {
  static const String TEXT_ON_TEXT = 'text on text';
  static const String TEXT_ON_MEDIA = 'text on media';
  static const String MEDIA_ON_TEXT = 'media on text';
  static const String MEDIA_ON_MEDIA = 'media on media';
  static const String TEXT_ONLY = 'text only';
  static const String MEDIA_ONLY = 'media only';
}
