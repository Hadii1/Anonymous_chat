import 'dart:convert';
import 'package:flutter/foundation.dart';

class User {
  final String nickname;
  final String email;
  final String id;
  final List<String> activeTags;

  User({
    required this.nickname,
    required this.email,
    required this.id,
    required this.activeTags,
  });

  User copyWith({
    String? nickname,
    String? email,
    String? id,
    List<String>? activeTags,
  }) {
    return User(
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      id: id ?? this.id,
      activeTags: activeTags ?? this.activeTags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nickname': nickname,
      'email': email,
      'id': id,
      'activeTags': activeTags,
    };
  }

  factory User.fromUser(User user) {
    return User(
        nickname: user.nickname,
        email: user.email,
        id: user.id,
        activeTags: user.activeTags);
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      nickname: map['nickname'],
      email: map['email'],
      id: map['id'],
      activeTags: List<String>.from(map['activeTags']),
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  @override
  String toString() {
    return 'FirestoreUser(nickname: $nickname, email: $email, id: $id, activeTags: $activeTags)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.nickname == nickname &&
        other.email == email &&
        other.id == id &&
        listEquals(other.activeTags, activeTags);
  }

  @override
  int get hashCode {
    return nickname.hashCode ^
        email.hashCode ^
        id.hashCode ^
        activeTags.hashCode;
  }
}
