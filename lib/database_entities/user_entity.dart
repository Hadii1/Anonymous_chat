import 'dart:convert';

class LocalUser {
  final String nickname;
  final String phoneNumber;
  final String id;
  final int dob;
  final String gender;

  LocalUser({
    required this.id,
    required this.phoneNumber,
    this.dob = -1,
    this.nickname = '',
    this.gender = '',
  });

  static bool isDataComplete(Map<String, dynamic> map) =>
      map['gender'] != '' && map['dob'] != -1 && map['nickname'] != '';

  static bool isProfileComplete(LocalUser user) =>
      user.gender.isNotEmpty && user.dob != -1 && user.nickname.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'nickname': nickname,
      'phoneNumber': phoneNumber,
      'id': id,
      'gender': gender,
      'dob': dob,
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
      dob: map['dob'] ?? '',
      phoneNumber: map['phoneNumber'],
      id: map['id'],
      gender: map['gender'] ?? '',
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
        other.id == id &&
        other.gender == gender;
  }

  @override
  int get hashCode {
    return nickname.hashCode ^
        phoneNumber.hashCode ^
        id.hashCode ^
        gender.hashCode;
  }
}
