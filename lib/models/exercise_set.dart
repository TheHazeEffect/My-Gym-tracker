import 'package:hive/hive.dart';
part 'exercise_set.g.dart';

@HiveType(typeId: 5)
class ExerciseSet {
  @HiveField(0)
  final int reps;
  @HiveField(1)
  final double weight;
  @HiveField(2)
  final bool isCompleted;

  ExerciseSet({
    required this.reps,
    required this.weight,
    this.isCompleted = false,
  });

  double get volume => reps * weight;

  factory ExerciseSet.fromJson(Map<String, dynamic> json) => ExerciseSet(
    reps: json['reps'],
    weight: (json['weight'] as num).toDouble(),
    isCompleted: json['isCompleted'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'reps': reps,
    'weight': weight,
    'isCompleted': isCompleted,
  };

  ExerciseSet copyWith({int? reps, double? weight, bool? isCompleted}) {
    return ExerciseSet(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
