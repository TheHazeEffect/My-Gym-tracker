import 'package:hive/hive.dart';
part 'personal_record.g.dart';

@HiveType(typeId: 3)
class PersonalRecord {
  @HiveField(0)
  final String exerciseName;
  @HiveField(1)
  final double maxWeight;
  @HiveField(2)
  final int maxReps;
  @HiveField(3)
  final double totalVolume;
  @HiveField(4)
  final DateTime achievedDate;

  PersonalRecord({
    required this.exerciseName,
    required this.maxWeight,
    required this.maxReps,
    required this.totalVolume,
    required this.achievedDate,
  });

  factory PersonalRecord.fromJson(Map<String, dynamic> json) => PersonalRecord(
    exerciseName: json['exerciseName'],
    maxWeight: (json['maxWeight'] as num).toDouble(),
    maxReps: json['maxReps'],
    totalVolume: (json['totalVolume'] as num).toDouble(),
    achievedDate: DateTime.parse(json['achievedDate']),
  );

  Map<String, dynamic> toJson() => {
    'exerciseName': exerciseName,
    'maxWeight': maxWeight,
    'maxReps': maxReps,
    'totalVolume': totalVolume,
    'achievedDate': achievedDate.toIso8601String(),
  };
}
