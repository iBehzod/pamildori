import 'package:uuid/uuid.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final String color;
  final DateTime createdAt;
  final String? userId;
  
  Project({
    String? id,
    required this.name,
    this.description = '',
    this.color = 'blue',
    DateTime? createdAt,
    this.userId,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now();
  
  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    DateTime? createdAt,
    String? userId,
    bool clearUserId = false,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      userId: clearUserId ? null : (userId ?? this.userId),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }
  
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      color: json['color'] as String? ?? 'blue',
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
      userId: json['userId'] as String?,
    );
  }
} 