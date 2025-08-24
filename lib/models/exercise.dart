import 'package:hive/hive.dart';
import 'exercise_set.dart';
part 'exercise.g.dart';

@HiveType(typeId: 1)
class Exercise {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final List<ExerciseSet> sets;
  @HiveField(2)
  final String? primaryMuscleGroup;
  @HiveField(3)
  final String? secondaryMuscleGroup;
  @HiveField(4)
  final String? tertiaryMuscleGroup;

  Exercise({
    required this.name,
    required this.sets,
    this.primaryMuscleGroup,
    this.secondaryMuscleGroup,
    this.tertiaryMuscleGroup,
  });

  double get volume => sets.fold(0.0, (sum, set) => sum + set.volume);

  ExerciseSet? get maxWeightSet {
    if (sets.isEmpty) return null;
    return sets.reduce((a, b) => a.weight > b.weight ? a : b);
  }

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    name: json['name'],
    sets:
        (json['sets'] as List<dynamic>?)
            ?.map((e) => ExerciseSet.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    primaryMuscleGroup: json['primaryMuscleGroup'],
    secondaryMuscleGroup: json['secondaryMuscleGroup'],
    tertiaryMuscleGroup: json['tertiaryMuscleGroup'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'sets': sets.map((e) => e.toJson()).toList(),
    'primaryMuscleGroup': primaryMuscleGroup,
    'secondaryMuscleGroup': secondaryMuscleGroup,
    'tertiaryMuscleGroup': tertiaryMuscleGroup,
  };
}
