import 'dart:convert';

class User {
  final String nickname;
  final String phoneNumber;
  final String id;
  final String country;
  final String gender;

  User({
    required this.nickname,
    required this.phoneNumber,
    required this.id,
    required this.country,
    required this.gender,
  });

  User copyWith({
    String? nickname,
    String? phoneNumber,
    String? id,
    String? country,
    String? gender,
  }) {
    return User(
      nickname: nickname ?? this.nickname,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      id: id ?? this.id,
      country: country ?? this.country,
      gender: gender ?? this.gender,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nickname': nickname,
      'phoneNumber': phoneNumber,
      'id': id,
      'country': country,
      'gender': gender,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      nickname: map['nickname'],
      phoneNumber: map['phoneNumber'],
      id: map['id'],
      country: map['country'],
      gender: map['gender'],
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  @override
  String toString() {
    return 'User(nickname: $nickname, phoneNumber: $phoneNumber, id: $id, country: $country, gender: $gender)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.nickname == nickname &&
        other.phoneNumber == phoneNumber &&
        other.id == id &&
        other.country == country &&
        other.gender == gender;
  }

  @override
  int get hashCode {
    return nickname.hashCode ^
        phoneNumber.hashCode ^
        id.hashCode ^
        country.hashCode ^
        gender.hashCode;
  }
}
