import 'user_model.dart';

class AuthData {
  final String token;
  final User user;
  final DateTime expiresAt;

  AuthData({
    required this.token,
    required this.user,
    required this.expiresAt,
  });

  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
} 