class User {
  final String id;
  final String name;
  final String email;
  final String authMethod;
  final String? googleId;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.authMethod,
    this.googleId,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      authMethod: json['authMethod'] ?? 'local',
      googleId: json['googleId'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'authMethod': authMethod,
      'googleId': googleId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}