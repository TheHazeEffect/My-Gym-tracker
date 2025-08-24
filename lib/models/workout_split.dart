import 'package:hive/hive.dart';
part 'workout_split.g.dart';

@HiveType(typeId: 2)
class WorkoutSplit {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final List<String> exerciseNames;

  WorkoutSplit({required this.name, this.exerciseNames = const []});

  factory WorkoutSplit.fromJson(Map<String, dynamic> json) => WorkoutSplit(
    name: json['name'],
    exerciseNames: List<String>.from(json['exerciseNames'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'exerciseNames': exerciseNames,
  };
}
