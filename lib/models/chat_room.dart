import 'package:observable_ish/observable_ish.dart';

import 'package:anonymous_chat/models/contact.dart';
import 'package:anonymous_chat/models/message.dart';
import 'package:anonymous_chat/utilities/general_functions.dart';

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
    // if (other is ChatRoom && this.messages.length != other.messages.length)
    //   return false;

    // for (int i = 0; i < this.messages.length; i++) {
    //   if (other is ChatRoom &&
    //       this.messages[i].isRead != other.messages[i].isRead) {
    //     return false;
    //   }
    // }
  }

  // bool isDifferent(ChatRoom oldRoom) {
  //   if (oldRoom.id != this.id) {
  //     return true;
  //   } else if (oldRoom.messages.length != this.messages.length) {
  //     return true;
  //   } else {
  //     for (int i = 0; i < this.messages.length; i++) {
  //       if (this.messages[i].isRead != oldRoom.messages[i].isRead) {
  //         return true;
  //       }
  //     }
  //   }
  //   return false;
  // }

  @override
  int get hashCode {
    return messages.hashCode;
  }

  ChatRoom archive() {
    return ChatRoom(
      id: id,
      messages: messages,
      contact: contact,
      isArchived: true,
    );
  }

  ChatRoom unArchive() {
    return ChatRoom(
      id: id,
      messages: messages,
      contact: contact,
      isArchived: false,
    );
  }

  ChatRoom blockContact() {
    return ChatRoom(
      id: id,
      messages: messages,
      contact: contact.block(),
      isArchived: isArchived,
    );
  }

  ChatRoom unBlockContact() {
    return ChatRoom(
      id: id,
      messages: messages,
      contact: contact.unBlock(),
      isArchived: isArchived,
    );
  }
}
