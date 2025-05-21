class User {
  final String id;
  final String email;
  final String displayName;
  final String name;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.name,
    this.photoUrl,
    required this.createdAt,
    required this.lastLoginAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'name': name,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
    );
  }

  /// Creates a copy of the user with updated fields
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? name,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
  
  /// Returns initials for avatar
  String get initials {
    final nameParts = displayName.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  /// Checks if user account is new (less than 24 hours)
  bool get isNewAccount {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }
}