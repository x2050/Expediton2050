import 'package:flutter/material.dart';

/// A documentary expedition that groups field records under one mission.
class Mission {
  const Mission({
    required this.id,
    required this.title,
    required this.region,
    required this.description,
    required this.status,
    required this.accentValue,
  });

  final String id;
  final String title;
  final String region;
  final String description;
  final String status;
  final int accentValue;

  Color get accentColor => Color(accentValue);

  factory Mission.fromMap(Map<String, Object?> map) => Mission(
        id: map['id']! as String,
        title: map['title']! as String,
        region: map['region']! as String,
        description: map['description']! as String,
        status: map['status']! as String,
        accentValue: map['accent_value']! as int,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'region': region,
        'description': description,
        'status': status,
        'accent_value': accentValue,
      };
}
