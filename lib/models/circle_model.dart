class CircleModel {
  final int id;
  final String title;
  final String categoryName;
  final String sheikhName;
  final String? sheikhAvatar;
  final String gender; // 'men', 'women', 'children'
  final int maxStudents;
  final int currentStudents;
  final String type; // 'hifz', 'revision', 'maqraa', 'modarasa', 'nooranya'
  final bool isLive;
  final String? roomId;

  CircleModel({
    required this.id,
    required this.title,
    required this.categoryName,
    required this.sheikhName,
    this.sheikhAvatar,
    required this.gender,
    required this.maxStudents,
    required this.currentStudents,
    required this.type,
    this.isLive = false,
    this.roomId,
  });

  factory CircleModel.fromJson(Map<String, dynamic> json) {
    return CircleModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      categoryName: json['category']?['name'] ?? 'حلقات القرآن',
      sheikhName: json['sheikh']?['name'] ?? 'الشيخ',
      sheikhAvatar: json['sheikh']?['avatar'],
      gender: json['gender'] ?? 'men',
      maxStudents: json['max_students'] ?? 10,
      currentStudents: json['current_students_count'] ?? 0,
      type: json['type'] ?? 'hifz',
      isLive: json['is_live'] ?? false,
      roomId: json['room_id'] ?? 'room_${json['id']}',
    );
  }
}
