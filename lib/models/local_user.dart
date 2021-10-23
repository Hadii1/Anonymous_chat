import 'dart:convert';

class LocalUser {
  final String nickname;
  final String phoneNumber;
  final String id;
  final List<String> blockedContacts;

  LocalUser({
    required this.id,
    required this.phoneNumber,
    this.blockedContacts = const <String>[],
    this.nickname = '',
  });

  copyWith({
    required String nickname,
  }) =>
      LocalUser(
        id: this.id,
        phoneNumber: phoneNumber,
        blockedContacts: this.blockedContacts,
        nickname: nickname,
      );

  bool get isNicknamed => nickname.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'nickname': nickname,
      'blockedContacts': blockedContacts,
      'phoneNumber': phoneNumber,
      'id': id,
    };
  }

  factory LocalUser.newlyCreated({
    required String id,
    required String phoneNumber,
  }) =>
      LocalUser(
        id: id,
        phoneNumber: phoneNumber,
      );

  factory LocalUser.fromMap(Map<String, dynamic> map) {
    return LocalUser(
      nickname: map['nickname'] ?? '',
      phoneNumber: map['phoneNumber'],
      id: map['id'],
      blockedContacts: map['blockedContacts'] == null
          ? []
          : (map['blockedContacts'] as List).cast<String>(),
    );
  }

  String toJson() => json.encode(toMap());

  factory LocalUser.fromJson(String source) =>
      LocalUser.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LocalUser &&
        other.nickname == nickname &&
        other.phoneNumber == phoneNumber &&
        other.id == id;
  }

  @override
  int get hashCode {
    return nickname.hashCode ^ phoneNumber.hashCode ^ id.hashCode;
  }
}
