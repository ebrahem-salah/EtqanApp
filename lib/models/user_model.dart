enum UserRole { student, sheikh, supervisor, parent }

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final String? avatar;
  final double walletBalance;
  final String? quranHifzAmount; // مقدار الحفظ

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.avatar,
    this.walletBalance = 0.0,
    this.quranHifzAmount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    UserRole parsedRole = UserRole.student;
    final roleStr = json['role']?.toString().toLowerCase();
    if (roleStr == 'sheikh' || roleStr == 'teacher') {
      parsedRole = UserRole.sheikh;
    } else if (roleStr == 'supervisor') {
      parsedRole = UserRole.supervisor;
    } else if (roleStr == 'parent') {
      parsedRole = UserRole.parent;
    }

    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: parsedRole,
      avatar: json['avatar'],
      walletBalance: (json['wallet_balance'] ?? 0).toDouble(),
      quranHifzAmount: json['quran_hifz_amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'avatar': avatar,
      'wallet_balance': walletBalance,
      'quran_hifz_amount': quranHifzAmount,
    };
  }
}
