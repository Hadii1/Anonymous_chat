// Copyright 2021 Hadi Hammoud
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:anonymous_chat/models/message.dart';

abstract class MessageEntity {
  final String id;
  final String sender;
  final String recipient;
  final String content;
  // The replied on message id if exists
  final String? replyingOn;
  // Milliseconds since epoch
  final int time;

  final bool isRead;

  MessageEntity(this.id, this.sender, this.recipient, this.content,
      this.replyingOn, this.time, this.isRead);

  Map<String, dynamic> toMap();

  Message toModel();
}

class LocalMessageEntity implements MessageEntity {
  final String id;
  final String sender;
  final String recipient;
  final String content;
  final String? replyingOn;
  final int time;
  final bool isRead;
  final String roomId;

  LocalMessageEntity({
    required this.id,
    required this.sender,
    required this.recipient,
    required this.content,
    required this.replyingOn,
    required this.time,
    required this.isRead,
    required this.roomId,
  });

  factory LocalMessageEntity.fromMessageModel(Message message, String roomId) =>
      LocalMessageEntity(
        id: message.id,
        sender: message.sender,
        recipient: message.recipient,
        content: message.content,
        replyingOn: message.replyingOn,
        time: message.time,
        isRead: message.isRead,
        roomId: roomId,
      );

  @override
  Message toModel() => Message(
        sender: this.sender,
        recipient: this.recipient,
        content: this.content,
        time: this.time,
        id: this.id,
        isRead: this.isRead,
        replyingOn: this.replyingOn,
      );

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'sender': sender,
        'recipient': recipient,
        'content': content,
        'replyingOn': replyingOn,
        'time': time,
        'isRead': isRead,
        'roomId': roomId,
      };

  static LocalMessageEntity fromMap(Map<String, dynamic> map) =>
      LocalMessageEntity(
        id: map['id'],
        sender: map['sender'],
        recipient: map['recipient'],
        content: map['content'],
        replyingOn: map['replyingOn'],
        time: map['time'],
        isRead: map['isRead'],
        roomId: map['roomId'],
      );
}

class OnlineMessageEntity implements MessageEntity {
  final String id;
  final String sender;
  final String recipient;
  final String content;
  final String? replyingOn;
  final int time;
  final bool isRead;

  OnlineMessageEntity({
    required this.id,
    required this.sender,
    required this.recipient,
    required this.content,
    required this.replyingOn,
    required this.time,
    required this.isRead,
  });

  factory OnlineMessageEntity.fromMessageModel(
          Message message, String roomId) =>
      OnlineMessageEntity(
        id: message.id,
        sender: message.sender,
        recipient: message.recipient,
        content: message.content,
        replyingOn: message.replyingOn,
        time: message.time,
        isRead: message.isRead,
      );

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'sender': sender,
        'recipient': recipient,
        'content': content,
        'replyingOn': replyingOn,
        'time': time,
        'isRead': isRead,
      };

  static OnlineMessageEntity fromMap(Map<String, dynamic> map) =>
      OnlineMessageEntity(
        id: map['id'],
        sender: map['sender'],
        recipient: map['recipient'],
        content: map['content'],
        replyingOn: map['replyingOn'],
        time: map['time'],
        isRead: map['isRead'],
      );

  @override
  Message toModel() => Message(
        sender: this.sender,
        recipient: this.recipient,
        content: this.content,
        time: this.time,
        id: this.id,
        isRead: this.isRead,
        replyingOn: this.replyingOn,
      );
}
