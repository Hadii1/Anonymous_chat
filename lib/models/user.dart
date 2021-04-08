import 'dart:convert';

import 'package:anonymous_chat/models/room.dart';
import 'package:anonymous_chat/models/tag.dart';

class User {
  final String nickname;
  final String email;
  final String id;
  List<Room> rooms;
  List<Tag> tags;
  // This is a utility array to store the user active tag ids for easier querying
  List<String> activeTags;

  User({
    required this.nickname,
    required this.email,
    required this.id,
    this.activeTags = const [],
    this.rooms = const [],
    this.tags = const [],
  });

  User copyWith({
    String? nickname,
    String? email,
    String? id,
    List<Room>? rooms,
    List<Tag>? tags,
    List<String>? activeTags,
  }) {
    return User(
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      id: id ?? this.id,
      rooms: rooms ?? this.rooms,
      tags: tags ?? this.tags,
      activeTags: activeTags ?? this.activeTags,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'nickname': nickname,
      'email': email,
      'id': id,
      'activeTags': activeTags,
    };
  }

  factory User.fromFirestoreMap(Map<String, dynamic> map) {
    return User(
      nickname: map['nickname'],
      email: map['email'],
      id: map['id'],
      activeTags: List<String>.from(map['activeTags'] ??= []),
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  @override
  String toString() {
    return 'User(nickname: $nickname, email: $email, id: $id, rooms: $rooms, tags: $tags, activeTags: $activeTags)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User && other.id == this.id;
  }

  @override
  int get hashCode {
    return nickname.hashCode ^
        email.hashCode ^
        id.hashCode ^
        rooms.hashCode ^
        tags.hashCode;
  }

  Map<String, dynamic> toMap() {
    return {
      'nickname': nickname,
      'email': email,
      'activeTags': activeTags,
      'id': id,
      'rooms': rooms.map((x) => x.toMap()).toList(),
      'tags': tags.map((x) => x.toMap()).toList(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      nickname: map['nickname'],
      email: map['email'],
      id: map['id'],
      activeTags:
          map['activeTags'] == null ? [] : List<String>.from(map['activeTags']),
      rooms: map['rooms'] == null
          ? []
          : List<Room>.from(map['rooms']?.map((x) => Room.fromMap(x))),
      tags: map['tags'] == null
          ? []
          : List<Tag>.from(map['tags']?.map((x) => Tag.fromMap(x))),
    );
  }
}
