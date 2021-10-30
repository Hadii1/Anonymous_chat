class Message {
  final String id;
  final String roomId;
  final String sender;
  final String recipient;
  final String content;
  // The replied on message id if exists
  final String? replyingOn;
  // Milliseconds since epoch
  final int time;

  final bool isRead;

  Message({
    required this.sender,
    required this.roomId,
    required this.recipient,
    required this.content,
    required this.time,
    required this.id,
    required this.isRead,
    this.replyingOn,
  });

  factory Message.create({
    required sender,
    required recipient,
    required content,
    required time,
    required id,
    required replyingOn,
    required roomId,
  }) =>
      Message(
        isRead: false,
        content: content,
        roomId: roomId,
        id: id,
        recipient: recipient,
        sender: sender,
        time: time,
        replyingOn: replyingOn,
      );

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
    return 'Message(sender: $sender, recipient: $recipient, content: $content, id: $id,replyingOn: $replyingOn, time: $time, isRead: $isRead)';
  }

  bool isReceived(String userId) => sender != userId;
  bool isSent(String userId) => !isReceived(userId);

  Message markAsRead() {
    return Message(
      id: this.id,
      roomId: this.roomId,
      sender: this.sender,
      recipient: this.recipient,
      content: this.content,
      replyingOn: this.replyingOn,
      time: this.time,
      isRead: true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomId': roomId,
      'sender': sender,
      'recipient': recipient,
      'content': content,
      'replyingOn': replyingOn,
      'time': time,
      'isRead': isRead,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      roomId: map['roomId'],
      sender: map['sender'],
      recipient: map['recipient'],
      content: map['content'],
      replyingOn: map['replyingOn'] != null ? map['replyingOn'] : null,
      time: map['time'],
      isRead: (map['isRead'] is bool)
          ? map['isRead']
          : map['isRead'] == 0
              ? false
              : true,
    );
  }
}
