class User {
  final String id;
  final String username;
  final String? accessToken;
  final String? refreshToken;
  final String? role;
  final bool? isStaff;
  final bool? isWardExecutive;
  final bool isAnonymous;


  User({
    required this.id,
    required this.username,
    this.accessToken,
    this.refreshToken,
    this.role,
    this.isStaff,
    this.isWardExecutive,
    this.isAnonymous = false,
  });

  factory User.fromReportJson(Map<String, dynamic> json) {
    if (json['id'] == null || json['username'] == null) {
      print("User.fromReportJson Error: Missing 'id' or 'username'. Data: $json");
      throw FormatException("User JSON from report is missing 'id' or 'username'.");
    }
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      isStaff: json['isStaff'] as bool?,
      isWardExecutive: json['isSuperuser'] as bool?,
      isAnonymous: false,
      // accessToken, refreshToken, role will be null as they are not expected from report.user
    );
  }

  factory User.fromLoginJson(Map<String, dynamic> json) {
    final user = json['user'];
    return User(
      id:user['id'],
      username: user['username'],
      accessToken: user['accessToken'],
      refreshToken: user['refreshToken'],
      isStaff: user['isStaff'],
      isWardExecutive: user['isWardExecutive'],
      isAnonymous: false,
    );
  }

  factory User.fromRegisterJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      role: json['role'],
      isStaff: json['isStaff'],
      isWardExecutive: json['isSuperuser'],
      isAnonymous: false,
    );
  }

  factory User.anonymous() {
    return User(
      id: 'anonymous_${DateTime.now().millisecondsSinceEpoch}',
      username: 'Anonymous',
      isAnonymous: true,
    );
  }

}
