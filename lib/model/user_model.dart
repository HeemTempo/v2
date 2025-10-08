import 'dart:convert';

class User {
  final String id;
  final String username;
  final String? token; // For authentication
  final String? role;
  final bool? isStaff;
  final bool? isWardExecutive;
  final bool? isVillageChairman;
  final bool isAnonymous;

  const User({
    required this.id,
    required this.username,
    this.token,
    this.role,
    this.isStaff,
    this.isWardExecutive,
    this.isVillageChairman,
    this.isAnonymous = false,
  });

  /// 🔹 Create a new User object with updated fields
  User copyWith({
    String? id,
    String? username,
    String? token,
    String? role,
    bool? isStaff,
    bool? isWardExecutive,
    bool? isVillageChairman,
    bool? isAnonymous,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      token: token ?? this.token,
      role: role ?? this.role,
      isStaff: isStaff ?? this.isStaff,
      isWardExecutive: isWardExecutive ?? this.isWardExecutive,
      isVillageChairman: isVillageChairman ?? this.isVillageChairman,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  /// 🔹 Serialize minimal data for secure storage
  String toJsonString() => jsonEncode({
        'id': id,
        'username': username,
        'role': role,
        'isStaff': isStaff,
        'isWardExecutive': isWardExecutive,
        'isVillageChairman': isVillageChairman,
      });

  factory User.fromJsonString(String jsonStr) {
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    return User(
      id: data['id'],
      username: data['username'],
      role: data['role'],
      isStaff: data['isStaff'],
      isWardExecutive: data['isWardExecutive'],
      isVillageChairman: data['isVillageChairman'],
      isAnonymous: false,
    );
  }

  /// 🔹 Parse from Register mutation
  factory User.fromRegisterJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      role: json['role'],
      isStaff: json['isStaff'],
      isWardExecutive: json['isWardExecutive'],
      isVillageChairman: json['isVillageChairman'],
      isAnonymous: false,
    );
  }

  /// 🔹 Parse from Login mutation
  factory User.fromLoginJson(Map<String, dynamic> json) {
    final user = json['user'] ?? json;
    return User(
      id: user['id'],
      username: user['username'],
      token: user['token'],
      role: user['role'],
      isStaff: user['isStaff'],
      isWardExecutive: user['isWardExecutive'],
      isVillageChairman: user['isVillageChairman'],
      isAnonymous: false,
    );
  }

  /// 🔹 Parse from Reports or other lightweight queries
  factory User.fromReportJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      isStaff: json['isStaff'],
      isWardExecutive: json['isWardExecutive'],
      isVillageChairman: json['isVillageChairman'],
      isAnonymous: false,
    );
  }

  /// 🔹 Anonymous fallback
  factory User.anonymous() => User(
        id: 'anonymous_${DateTime.now().millisecondsSinceEpoch}',
        username: 'Anonymous',
        isAnonymous: true,
      );
}
