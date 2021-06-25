import 'dart:io';

class Message {
  final String sender;
  final String recipient;
  // Null if the message is a media message
  final String? content;
  final String id;
  final String type;
  final bool isSenderBlocked;
  // Null if the message is a text message
  final List<File>? mediaFiles;

  // The replied on message id if exists
  final String? replyingOn;
  // Milliseconds since epoch
  final int time;

  bool isRead;
  List<String>? mediaUrls;

  Message({
    required this.sender,
    required this.recipient,
    required this.type,
    required this.isSenderBlocked,
    required this.content,
    required this.time,
    required this.id,
    this.isRead = false,
    this.replyingOn,
    this.mediaUrls,
    this.mediaFiles,
  });

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'recipient': recipient,
      'content': content,
      'time': time,
      'type': type,
      'id': id,
      'replyingOn': replyingOn,
      'isSenderBlocked': isSenderBlocked,
      'media': mediaUrls,
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
      type: map['type'],
      time: map['time'],
      mediaUrls: map['media'] == null ? null : List<String>.from(map['media']),
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
    return 'Message(sender: $sender, recipient: $recipient, content: $content, id: $id, isSenderBlocked: $isSenderBlocked, mediaFiles: $mediaFiles, media: $mediaUrls, replyingOn: $replyingOn, time: $time, isRead: $isRead)';
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
