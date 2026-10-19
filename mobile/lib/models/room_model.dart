class RoomModel {
  final int id;
  final int buildingId;
  final String buildingName;
  final String campusName;
  final String roomNumber;
  final String roomType;
  final int floor;
  final String qrCode;
  final String? description;

  RoomModel({
    required this.id,
    required this.buildingId,
    required this.buildingName,
    required this.campusName,
    required this.roomNumber,
    required this.roomType,
    required this.floor,
    required this.qrCode,
    this.description,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? 0,
      buildingId: json['buildingId'] ?? 0,
      buildingName: json['buildingName'] ?? '',
      campusName: json['campusName'] ?? '',
      roomNumber: json['roomNumber'] ?? '',
      roomType: json['roomType'] ?? 'LectureHall',
      floor: json['floor'] ?? 1,
      qrCode: json['qrCode'] ?? '',
      description: json['description'],
    );
  }

  String get fullLocationText => '$roomNumber - $buildingName ($campusName)';
}
