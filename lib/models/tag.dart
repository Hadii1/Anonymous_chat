import 'dart:convert';

class Tag {
  final String label;
  final String id;
  final bool isActive;

  Tag({
    required this.label,
    required this.id,
    required this.isActive,
  });

  Tag copyWith({
    String? label,
    String? id,
    List<String>? activeUsers,
    List<String>? allUsers,
    bool? isActive,
  }) {
    return Tag(
      label: label ?? this.label,
      id: id ?? this.id,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'id': id,
      'isActive': isActive,
    };
  }

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      label: map['label'],
      id: map['id'],
      isActive: map['isActive'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Tag.fromJson(String source) => Tag.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Tag(label: $label, id: $id, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Tag && other.id == id;
  }

  @override
  int get hashCode {
    return label.hashCode ^ id.hashCode ^ isActive.hashCode;
  }
}
