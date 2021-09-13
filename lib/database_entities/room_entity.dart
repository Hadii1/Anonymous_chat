class RoomEntity {
  final String id;
  final List<String> users;

  RoomEntity({
    required this.id,
    required this.users,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'users': users,
    };
  }

  factory RoomEntity.fromMap(Map<String, dynamic> map) {
    return RoomEntity(
      id: map['id'],
      users: List<String>.from(map['users']),
    );
  }
}
