import 'dart:convert';

class User {
  final String nickname;
  final String email;
  final String id;
  final List<String> activeTags;
  final List<String> blockedUsers;

  User({
    required this.nickname,
    required this.email,
    required this.id,
    required this.blockedUsers,
    required this.activeTags,
  });

  User copyWith({
    String? nickname,
    String? email,
    String? id,
    List<String>? activeTags,
    List<String>? blockedUsers,
  }) {
    return User(
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      id: id ?? this.id,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      activeTags: activeTags ?? this.activeTags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nickname': nickname,
      'email': email,
      'id': id,
      'activeTags': activeTags,
      'blockedUsers': blockedUsers,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      nickname: map['nickname'],
      email: map['email'],
      id: map['id'],
      blockedUsers: List<String>.from(map['blockedUsers']),
      activeTags: List<String>.from(map['activeTags']),
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User && other.id == id;
  }

  @override
  int get hashCode {
    return nickname.hashCode ^
        email.hashCode ^
        id.hashCode ^
        activeTags.hashCode;
  }
}
