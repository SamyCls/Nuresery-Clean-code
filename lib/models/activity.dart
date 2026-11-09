import 'package:flutter/material.dart';

class Activity {
  final String id;
  String className;
  String title;
  DateTime date;
  TimeOfDay start;
  TimeOfDay end;
  String notes;

  Activity({
    required this.id,
    required this.className,
    required this.title,
    required this.date,
    required this.start,
    required this.end,
    this.notes = '',
  });

  Activity copyWith({
    String? id,
    String? className,
    String? title,
    DateTime? date,
    TimeOfDay? start,
    TimeOfDay? end,
    String? notes,
  }) {
    return Activity(
      id: id ?? this.id,
      className: className ?? this.className,
      title: title ?? this.title,
      date: date ?? this.date,
      start: start ?? this.start,
      end: end ?? this.end,
      notes: notes ?? this.notes,
    );
  }
}
