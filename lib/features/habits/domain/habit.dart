import 'package:flutter/material.dart';

class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.color,
    required this.plantedDays,
  });

  final String id;
  final String name;
  final Color color;
  final Set<DateTime> plantedDays;

  Habit copyWith({String? name, Color? color, Set<DateTime>? plantedDays}) {
    return Habit(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      plantedDays: plantedDays ?? this.plantedDays,
    );
  }
}
