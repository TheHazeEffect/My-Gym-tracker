import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/exercise.dart';

class ExerciseViewModel extends ChangeNotifier {
  final Box<Exercise> _exerciseBox = Hive.box<Exercise>('exercises');

  List<Exercise> get exercises => _exerciseBox.values.toList();

  void addExercise(Exercise exercise) {
    _exerciseBox.add(exercise);
    notifyListeners();
  }
}
