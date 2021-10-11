class Message {
  final String id;
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
  }) =>
      Message(
        isRead: false,
        content: content,
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
      sender: this.sender,
      recipient: this.recipient,
      content: this.content,
      replyingOn: this.replyingOn,
      time: this.time,
      isRead: true,
    );
  }
}
