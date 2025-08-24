import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/workout.dart';

class WorkoutViewModel extends ChangeNotifier {
  final Box<Workout> _workoutBox = Hive.box<Workout>('workouts');

  List<Workout> get workouts => _workoutBox.values.toList();

  void addWorkout(Workout workout) {
    _workoutBox.add(workout);
    notifyListeners();
  }

  void updateWorkout(int index, Workout updatedWorkout) {
    _workoutBox.putAt(index, updatedWorkout);
    notifyListeners();
  }
}
