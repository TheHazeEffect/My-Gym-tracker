import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/workout_split.dart';

class WorkoutSplitViewModel extends ChangeNotifier {
  final Box<WorkoutSplit> _splitBox = Hive.box<WorkoutSplit>('splits');

  List<WorkoutSplit> get splits => _splitBox.values.toList();

  void addSplit(WorkoutSplit split) {
    _splitBox.add(split);
    notifyListeners();
  }

  void updateSplit(int index, WorkoutSplit updatedSplit) {
    _splitBox.putAt(index, updatedSplit);
    notifyListeners();
  }

  void deleteSplit(int index) {
    _splitBox.deleteAt(index);
    notifyListeners();
  }
}
