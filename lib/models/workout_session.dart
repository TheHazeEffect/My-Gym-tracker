import 'package:hive/hive.dart';
import 'exercise.dart';
part 'workout_session.g.dart';

@HiveType(typeId: 4)
class WorkoutSession {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final DateTime startTime;
  @HiveField(2)
  final DateTime? endTime;
  @HiveField(3)
  final List<Exercise> exercises;
  @HiveField(4)
  final bool isCompleted;

  WorkoutSession({
    required this.id,
    required this.startTime,
    this.endTime,
    this.exercises = const [],
    this.isCompleted = false,
  });

  Duration? get duration => endTime?.difference(startTime);

  double get totalVolume =>
      exercises.fold(0, (sum, exercise) => sum + exercise.volume);

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
    id: json['id'],
    startTime: DateTime.parse(json['startTime']),
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    exercises: (json['exercises'] as List<dynamic>? ?? [])
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList(),
    isCompleted: json['isCompleted'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'isCompleted': isCompleted,
  };
}
