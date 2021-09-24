class UserTag {
  final Tag tag;
  final bool isActive;
  final String userId;
  final int? deactivatedAt;
  final int? activatedAt;

  UserTag({
    required this.tag,
    required this.isActive,
    required this.userId,
    required this.deactivatedAt,
    required this.activatedAt,
  });

  UserTag copyWith({
    bool? isActive,
    int? deactivatedAt,
    int? activatedAt,
  }) {
    return UserTag(
      tag: this.tag,
      userId: this.userId,
      isActive: isActive ?? this.isActive,
      deactivatedAt: deactivatedAt ?? this.deactivatedAt,
      activatedAt: activatedAt ?? this.activatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tag': tag.toMap(),
      'isActive': isActive,
      'deactivatedAt': deactivatedAt,
      'activatedAt': activatedAt,
      'userId': userId,
    };
  }

  factory UserTag.fromMap(Map<String, dynamic> map) {
    return UserTag(
      tag: Tag.fromMap(map['tag']),
      userId: map['userId'],
      isActive: map['isActive'],
      deactivatedAt: map['deactivatedAt'],
      activatedAt: map['activatedAt'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserTag &&
        other.tag == tag &&
        other.isActive == isActive &&
        other.deactivatedAt == deactivatedAt &&
        other.activatedAt == activatedAt;
  }

  @override
  int get hashCode {
    return tag.hashCode ^
        isActive.hashCode ^
        deactivatedAt.hashCode ^
        activatedAt.hashCode;
  }
}

class Tag {
  final String label;
  final String id;

  Tag({
    required this.label,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'id': id,
    };
  }

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      label: map['label'],
      id: map['id'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Tag && other.id == id;
  }

  @override
  int get hashCode {
    return label.hashCode ^ id.hashCode;
  }
}
