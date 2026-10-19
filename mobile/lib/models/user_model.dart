class UserModel {
  final int id;
  final String username;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role;
  final String? departmentOrClass;

  UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.departmentOrClass,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? 'Student',
      departmentOrClass: json['departmentOrClass'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'departmentOrClass': departmentOrClass,
    };
  }

  bool get isTechnician => role.toLowerCase() == 'technician';
  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isStudent => role.toLowerCase() == 'student';
  bool get isLecturer => role.toLowerCase() == 'lecturer';
}
