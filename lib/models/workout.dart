import 'package:hive/hive.dart';
import 'exercise.dart';
part 'workout.g.dart';

@HiveType(typeId: 0)
class Workout {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final DateTime date;
  @HiveField(2)
  final int duration;
  @HiveField(3)
  final List<Exercise> exercises;

  Workout({
    required this.name,
    required this.date,
    required this.duration,
    required this.exercises,
  });

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
    name: json['name'],
    date: DateTime.parse(json['date']),
    duration: json['duration'],
    exercises: (json['exercises'] as List<dynamic>? ?? [])
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'date': date.toIso8601String(),
    'duration': duration,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };
}
