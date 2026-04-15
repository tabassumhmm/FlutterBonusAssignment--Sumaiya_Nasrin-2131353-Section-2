import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

TaskModel taskModelFromJson(String str) =>
    TaskModel.fromJson(json.decode(str) as Map<String, dynamic>);

String taskModelToJson(TaskModel data) => json.encode(data.toJson());

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String assignedTo;
  final String phoneNumber;
  final String password;
  final DateTime? createdAt;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.phoneNumber,
    required this.password,
    this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      assignedTo: json['assignedTo'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      password: json['password'] as String? ?? '',
      createdAt: _dateTimeFromJson(json['createdAt']),
    );
  }

  factory TaskModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};

    return TaskModel.fromJson({...data, 'id': data['id'] ?? doc.id});
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'phoneNumber': phoneNumber,
      'password': password,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? assignedTo,
    String? phoneNumber,
    String? password,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get detailsText {
    return 'Assigned to: $assignedTo\n'
        'Phone: $phoneNumber\n'
        'Description: $description\n\n'
        'Task Password: $password';
  }

  String get createdAtLabel {
    if (createdAt == null) {
      return 'Pending timestamp';
    }

    final value = createdAt!;
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$month-$day $hour:$minute';
  }

  static DateTime? _dateTimeFromJson(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}
