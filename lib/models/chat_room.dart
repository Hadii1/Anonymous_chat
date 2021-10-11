import 'package:anonymous_chat/models/contact.dart';
import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/utilities/general_functions.dart';

import 'package:observable_ish/observable_ish.dart';

class ChatRoom {
  final String id;
  final RxList<Message> messages;
  final Contact contact;
  final bool isArchived;

  ChatRoom({
    required this.contact,
    required this.messages,
    required this.id,
    required this.isArchived,
  });

  factory ChatRoom.startNew(Contact other) {
    return ChatRoom(
      messages: RxList<Message>(),
      id: generateUid(),
      contact: other,
      isArchived: false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatRoom && other.id == id;
  }

  @override
  int get hashCode {
    return messages.hashCode;
  }
}
