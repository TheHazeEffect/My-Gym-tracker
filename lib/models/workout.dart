import 'package:hive/hive.dart';
part 'workout.g.dart';

@HiveType(typeId: 0)
class Workout {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final DateTime date;
  @HiveField(2)
  final int duration;

  Workout({required this.name, required this.date, required this.duration});

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
        name: json['name'],
        date: DateTime.parse(json['date']),
        duration: json['duration'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'date': date.toIso8601String(),
        'duration': duration,
      };
}
