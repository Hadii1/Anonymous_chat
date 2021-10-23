abstract class RoomEntity {
  final String id;

  RoomEntity(this.id);

  // RoomEntity fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toMap();
}

class LocalRoomEntity implements RoomEntity {
  final String id;
  final String contact;
  final bool isArchived;

  LocalRoomEntity({
    required this.id,
    required this.contact,
    required this.isArchived,
  });

  static LocalRoomEntity fromMap(Map<String, dynamic> map) => LocalRoomEntity(
        id: map['id'],
        contact: map['contact'],
        isArchived: map['isArchived'] == 0 ? false : true,
      );

  @override
  Map<String, dynamic> toMap() => {
        'id': this.id,
        'contact': this.contact,
        'isArchived': this.isArchived,
      };
}

class OnlineRoomEntity implements RoomEntity {
  final String id;
  final List<String> participiants;

  OnlineRoomEntity({
    required this.id,
    required this.participiants,
  });

  static OnlineRoomEntity fromMap(Map<String, dynamic> map) => OnlineRoomEntity(
        id: map['id'],
        participiants: (map['participiants'] as List).cast<String>(),
      );

  @override
  Map<String, dynamic> toMap() => {
        'id': this.id,
        'participiants': this.participiants,
      };
}
