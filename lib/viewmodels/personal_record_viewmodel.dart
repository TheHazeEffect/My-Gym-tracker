import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/personal_record.dart';

class PersonalRecordViewModel extends ChangeNotifier {
  final Box<PersonalRecord> _recordBox = Hive.box<PersonalRecord>('records');

  List<PersonalRecord> get records => _recordBox.values.toList();

  PersonalRecord? getRecordForExercise(String exerciseName) {
    try {
      return _recordBox.values.firstWhere(
        (record) => record.exerciseName == exerciseName,
      );
    } catch (e) {
      return null;
    }
  }

  void updateRecord(PersonalRecord record) {
    final existingIndex = _recordBox.values.toList().indexWhere(
      (r) => r.exerciseName == record.exerciseName,
    );

    if (existingIndex >= 0) {
      _recordBox.putAt(existingIndex, record);
    } else {
      _recordBox.add(record);
    }
    notifyListeners();
  }

  void deleteRecord(String exerciseName) {
    final recordsToDelete = <int>[];
    for (int i = 0; i < _recordBox.length; i++) {
      if (_recordBox.getAt(i)?.exerciseName == exerciseName) {
        recordsToDelete.add(i);
      }
    }

    for (int i = recordsToDelete.length - 1; i >= 0; i--) {
      _recordBox.deleteAt(recordsToDelete[i]);
    }
    notifyListeners();
  }
}
