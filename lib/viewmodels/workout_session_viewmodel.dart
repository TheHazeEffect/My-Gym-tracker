import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/workout_session.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';
import '../models/personal_record.dart';

class WorkoutSessionViewModel extends ChangeNotifier {
  final Box<WorkoutSession> _sessionBox = Hive.box<WorkoutSession>('sessions');
  final Box<PersonalRecord> _recordBox = Hive.box<PersonalRecord>('records');
  WorkoutSession? _currentSession;

  WorkoutSession? get currentSession => _currentSession;
  List<WorkoutSession> get completedSessions =>
      _sessionBox.values.where((session) => session.isCompleted).toList();

  // Get all unique exercises from history
  List<String> get historicalExercises {
    final exerciseNames = <String>{};
    for (var session in _sessionBox.values) {
      for (var exercise in session.exercises) {
        exerciseNames.add(exercise.name);
      }
    }
    return exerciseNames.toList()..sort();
  }

  // Get exercise progression data for charts
  List<Exercise> getExerciseHistory(String exerciseName) {
    final exerciseHistory = <Exercise>[];
    final sortedSessions =
        _sessionBox.values.where((session) => session.isCompleted).toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));

    for (var session in sortedSessions) {
      for (var exercise in session.exercises) {
        if (exercise.name == exerciseName) {
          exerciseHistory.add(exercise);
        }
      }
    }
    return exerciseHistory;
  }

  void startWorkout() {
    _currentSession = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
    );
    notifyListeners();
  }

  void addExerciseToCurrentWorkout(Exercise exercise) {
    if (_currentSession != null) {
      final updatedExercises = [..._currentSession!.exercises, exercise];
      _currentSession = WorkoutSession(
        id: _currentSession!.id,
        startTime: _currentSession!.startTime,
        exercises: updatedExercises,
      );
      notifyListeners();
    }
  }

  void updateExerciseInCurrentWorkout(
    int exerciseIndex,
    Exercise updatedExercise,
  ) {
    if (_currentSession != null &&
        exerciseIndex < _currentSession!.exercises.length) {
      final updatedExercises = List<Exercise>.from(_currentSession!.exercises);
      updatedExercises[exerciseIndex] = updatedExercise;
      _currentSession = WorkoutSession(
        id: _currentSession!.id,
        startTime: _currentSession!.startTime,
        exercises: updatedExercises,
      );
      notifyListeners();
    }
  }

  void completeWorkout() {
    if (_currentSession != null) {
      final completedSession = WorkoutSession(
        id: _currentSession!.id,
        startTime: _currentSession!.startTime,
        endTime: DateTime.now(),
        exercises: _currentSession!.exercises,
        isCompleted: true,
      );
      _sessionBox.add(completedSession);

      // Update personal records
      _updatePersonalRecords(_currentSession!.exercises);

      _currentSession = null;
      notifyListeners();
    }
  }

  void updateCompletedSession(WorkoutSession updatedSession) {
    // Find the session in the box and update it
    for (int i = 0; i < _sessionBox.length; i++) {
      final session = _sessionBox.getAt(i);
      if (session != null && session.id == updatedSession.id) {
        _sessionBox.putAt(i, updatedSession);

        // Update personal records based on the updated session
        _updatePersonalRecords(updatedSession.exercises);

        notifyListeners();
        break;
      }
    }
  }

  void _updatePersonalRecords(List<Exercise> exercises) {
    for (var exercise in exercises) {
      if (exercise.sets.isEmpty) continue;

      final maxWeightSet = exercise.maxWeightSet;
      if (maxWeightSet == null) continue;

      // Check if we already have a record for this exercise
      PersonalRecord? existingRecord;
      for (var record in _recordBox.values) {
        if (record.exerciseName == exercise.name) {
          existingRecord = record;
          break;
        }
      }

      if (existingRecord == null) {
        // Create new record
        final newRecord = PersonalRecord(
          exerciseName: exercise.name,
          maxWeight: maxWeightSet.weight,
          maxReps: maxWeightSet.reps,
          totalVolume: exercise.volume,
          achievedDate: DateTime.now(),
        );
        _recordBox.add(newRecord);
      } else {
        // Update existing record if new bests achieved
        bool shouldUpdate = false;
        double maxWeight = existingRecord.maxWeight;
        int maxReps = existingRecord.maxReps;
        double totalVolume = existingRecord.totalVolume;
        DateTime achievedDate = existingRecord.achievedDate;

        if (maxWeightSet.weight > existingRecord.maxWeight) {
          maxWeight = maxWeightSet.weight;
          achievedDate = DateTime.now();
          shouldUpdate = true;
        }
        if (maxWeightSet.reps > existingRecord.maxReps) {
          maxReps = maxWeightSet.reps;
          achievedDate = DateTime.now();
          shouldUpdate = true;
        }
        if (exercise.volume > existingRecord.totalVolume) {
          totalVolume = exercise.volume;
          achievedDate = DateTime.now();
          shouldUpdate = true;
        }

        if (shouldUpdate) {
          final updatedRecord = PersonalRecord(
            exerciseName: exercise.name,
            maxWeight: maxWeight,
            maxReps: maxReps,
            totalVolume: totalVolume,
            achievedDate: achievedDate,
          );

          // Find and replace the record
          for (int i = 0; i < _recordBox.length; i++) {
            final record = _recordBox.getAt(i);
            if (record?.exerciseName == exercise.name) {
              _recordBox.putAt(i, updatedRecord);
              break;
            }
          }
        }
      }
    }
  }

  void cancelWorkout() {
    _currentSession = null;
    notifyListeners();
  }

  // Method to add dummy data simulating natural progression over time
  void addDummyData() {
    // Clear existing data first
    _sessionBox.clear();
    _recordBox.clear();

    if (kDebugMode) {
      debugPrint('DEBUG: Creating progressive dummy workouts based on user data...');
    }
    final now = DateTime.now();

    List<WorkoutSession> sessions = [];

    // Bench Press progression over 16 weeks (from your data)
    final benchProgressions = [
      [40.0, 45.0, 50.0], // Week 1-4: 40-50kg max
      [45.0, 50.0, 52.5], // Week 5-8: 45-52.5kg max
      [47.5, 52.5, 55.0], // Week 9-12: 47.5-55kg max
      [50.0, 55.0, 65.0], // Week 13-16: 50-65kg max (current)
    ];

    // Lat Pulldown progression (from your data: 55kg, 59kg, 64kg, 68kg)
    final latProgressions = [
      [45.0, 50.0, 55.0], // Week 1-4: 45-55kg max
      [50.0, 55.0, 59.0], // Week 5-8: 50-59kg max
      [55.0, 59.0, 64.0], // Week 9-12: 55-64kg max
      [59.0, 64.0, 68.0], // Week 13-16: 59-68kg max (current)
    ];

    // Barbell Squat progression
    final squatProgressions = [
      [60.0, 65.0, 70.0], // Week 1-4: 60-70kg max
      [65.0, 70.0, 75.0], // Week 5-8: 65-75kg max
      [70.0, 75.0, 80.0], // Week 9-12: 70-80kg max
      [75.0, 80.0, 90.0], // Week 13-16: 75-90kg max (current)
    ];

    // Create 16 weeks of progressive workouts
    for (int week = 0; week < 4; week++) {
      for (int day = 0; day < 4; day++) {
        final daysAgo =
            (3 - week) * 7 + (3 - day) * 2; // More recent = less days ago
        final sessionDate = now.subtract(Duration(days: daysAgo));

        // Cycle through Push/Pull/Legs
        final workoutType = day % 3;

        if (workoutType == 0) {
          // Push Day
          sessions.add(
            WorkoutSession(
              id: 'push_week${week + 1}_day${day + 1}',
              startTime: sessionDate,
              endTime: sessionDate.add(const Duration(hours: 1, minutes: 20)),
              exercises: [
                Exercise(
                  name: 'Bench Press',
                  sets: [
                    ExerciseSet(reps: 12, weight: benchProgressions[week][0]),
                    ExerciseSet(reps: 10, weight: benchProgressions[week][1]),
                    ExerciseSet(reps: 8, weight: benchProgressions[week][2]),
                  ],
                  primaryMuscleGroup: 'Chest',
                ),
                Exercise(
                  name: 'Overhead Press',
                  sets: [
                    ExerciseSet(reps: 12, weight: 12.5 + (week * 2.5)),
                    ExerciseSet(reps: 10, weight: 15.0 + (week * 2.5)),
                    ExerciseSet(reps: 8, weight: 17.5 + (week * 2.5)),
                  ],
                  primaryMuscleGroup: 'Shoulders',
                ),
                Exercise(
                  name: 'Incline Dumbbell Press',
                  sets: [
                    ExerciseSet(reps: 12, weight: 15.0 + (week * 2.5)),
                    ExerciseSet(reps: 10, weight: 17.5 + (week * 2.5)),
                    ExerciseSet(reps: 8, weight: 20.0 + (week * 2.5)),
                  ],
                  primaryMuscleGroup: 'Chest',
                  secondaryMuscleGroup: 'Shoulders',
                ),
                Exercise(
                  name: 'Incline Machine Press',
                  sets: [
                    ExerciseSet(
                      reps: 12,
                      weight: 35.0 + (week * 5.0),
                    ), // Machine weight progression
                    ExerciseSet(reps: 10, weight: 40.0 + (week * 5.0)),
                    ExerciseSet(reps: 8, weight: 45.0 + (week * 5.0)),
                  ],
                  primaryMuscleGroup: 'Chest',
                  secondaryMuscleGroup: 'Shoulders',
                  tertiaryMuscleGroup: 'Triceps',
                ),
                Exercise(
                  name: 'Lateral Raises',
                  sets: [
                    ExerciseSet(reps: 15, weight: 7.0 + (week * 1.0)),
                    ExerciseSet(reps: 12, weight: 9.0 + (week * 1.0)),
                    ExerciseSet(reps: 10, weight: 10.0 + (week * 1.0)),
                  ],
                  primaryMuscleGroup: 'Shoulders',
                ),
                Exercise(
                  name: 'Tricep Pulldowns',
                  sets: [
                    ExerciseSet(reps: 12, weight: 20.0 + (week * 3.0)),
                    ExerciseSet(reps: 10, weight: 25.0 + (week * 3.0)),
                    ExerciseSet(reps: 8, weight: 30.0 + (week * 3.0)),
                  ],
                  primaryMuscleGroup: 'Triceps',
                ),
                Exercise(
                  name: 'Dips',
                  sets: [
                    ExerciseSet(
                      reps: 12,
                      weight: 0.0 + (week * 2.5),
                    ), // Bodyweight progression
                    ExerciseSet(reps: 10, weight: 0.0 + (week * 2.5)),
                    ExerciseSet(reps: 8, weight: 0.0 + (week * 2.5)),
                  ],
                  primaryMuscleGroup: 'Triceps',
                  secondaryMuscleGroup: 'Chest',
                  tertiaryMuscleGroup: 'Shoulders',
                ),
              ],
              isCompleted: true,
            ),
          );
        } else if (workoutType == 1) {
          // Pull Day
          sessions.add(
            WorkoutSession(
              id: 'pull_week${week + 1}_day${day + 1}',
              startTime: sessionDate,
              endTime: sessionDate.add(const Duration(hours: 1, minutes: 25)),
              exercises: [
                Exercise(
                  name: 'Lat Pulldowns',
                  sets: [
                    ExerciseSet(reps: 12, weight: latProgressions[week][0]),
                    ExerciseSet(reps: 10, weight: latProgressions[week][1]),
                    ExerciseSet(reps: 8, weight: latProgressions[week][2]),
                  ],
                  primaryMuscleGroup: 'Lats',
                ),
                Exercise(
                  name: 'Barbell Rows',
                  sets: [
                    ExerciseSet(reps: 10, weight: 50.0 + (week * 5.0)),
                    ExerciseSet(reps: 8, weight: 55.0 + (week * 5.0)),
                    ExerciseSet(reps: 6, weight: 60.0 + (week * 5.0)),
                  ],
                  primaryMuscleGroup: 'Lats',
                  secondaryMuscleGroup: 'Rhomboids',
                ),
                Exercise(
                  name: 'Barbell Curls',
                  sets: [
                    ExerciseSet(reps: 10, weight: 20.0 + (week * 3.5)),
                    ExerciseSet(reps: 8, weight: 25.0 + (week * 3.5)),
                    ExerciseSet(reps: 6, weight: 30.0 + (week * 3.5)),
                  ],
                  primaryMuscleGroup: 'Biceps',
                ),
                Exercise(
                  name: 'Face Pulls',
                  sets: [
                    ExerciseSet(reps: 15, weight: 30.0 + (week * 4.0)),
                    ExerciseSet(reps: 12, weight: 35.0 + (week * 4.0)),
                    ExerciseSet(reps: 10, weight: 40.0 + (week * 4.0)),
                  ],
                  primaryMuscleGroup: 'Rear Delts',
                ),
                Exercise(
                  name: 'Dumbbell Rows',
                  sets: [
                    ExerciseSet(reps: 12, weight: 20.0 + (week * 2.5)),
                    ExerciseSet(reps: 10, weight: 22.5 + (week * 2.5)),
                    ExerciseSet(reps: 8, weight: 25.0 + (week * 2.5)),
                  ],
                  primaryMuscleGroup: 'Lats',
                  secondaryMuscleGroup: 'Rhomboids',
                ),
              ],
              isCompleted: true,
            ),
          );
        } else {
          // Leg Day
          sessions.add(
            WorkoutSession(
              id: 'legs_week${week + 1}_day${day + 1}',
              startTime: sessionDate,
              endTime: sessionDate.add(const Duration(hours: 1, minutes: 40)),
              exercises: [
                Exercise(
                  name: 'Barbell Squat',
                  sets: [
                    ExerciseSet(reps: 12, weight: squatProgressions[week][0]),
                    ExerciseSet(reps: 10, weight: squatProgressions[week][1]),
                    ExerciseSet(reps: 8, weight: squatProgressions[week][2]),
                  ],
                  primaryMuscleGroup: 'Quadriceps',
                  secondaryMuscleGroup: 'Glutes',
                ),
                Exercise(
                  name: 'Romanian Deadlift',
                  sets: [
                    ExerciseSet(reps: 12, weight: 60.0 + (week * 7.5)),
                    ExerciseSet(reps: 10, weight: 70.0 + (week * 7.5)),
                    ExerciseSet(reps: 8, weight: 80.0 + (week * 7.5)),
                  ],
                  primaryMuscleGroup: 'Hamstrings',
                  secondaryMuscleGroup: 'Glutes',
                ),
                Exercise(
                  name: 'Leg Press',
                  sets: [
                    ExerciseSet(reps: 15, weight: 90.0 + (week * 12.5)),
                    ExerciseSet(reps: 12, weight: 110.0 + (week * 12.5)),
                    ExerciseSet(reps: 10, weight: 130.0 + (week * 12.5)),
                  ],
                  primaryMuscleGroup: 'Quadriceps',
                ),
                Exercise(
                  name: 'Leg Curls',
                  sets: [
                    ExerciseSet(reps: 12, weight: 30.0 + (week * 4.0)),
                    ExerciseSet(reps: 10, weight: 35.0 + (week * 4.0)),
                    ExerciseSet(reps: 8, weight: 40.0 + (week * 4.0)),
                  ],
                  primaryMuscleGroup: 'Hamstrings',
                ),
                Exercise(
                  name: 'Calf Raises',
                  sets: [
                    ExerciseSet(reps: 20, weight: 20.0 + (week * 2.5)),
                    ExerciseSet(reps: 18, weight: 22.5 + (week * 2.5)),
                    ExerciseSet(reps: 15, weight: 25.0 + (week * 2.5)),
                  ],
                  primaryMuscleGroup: 'Calves',
                ),
                Exercise(
                  name: 'Bulgarian Split Squats',
                  sets: [
                    ExerciseSet(
                      reps: 12,
                      weight: 15.0 + (week * 2.5),
                    ), // Bodyweight + dumbbells
                    ExerciseSet(reps: 10, weight: 17.5 + (week * 2.5)),
                    ExerciseSet(reps: 8, weight: 20.0 + (week * 2.5)),
                  ],
                  primaryMuscleGroup: 'Quadriceps',
                  secondaryMuscleGroup: 'Glutes',
                  tertiaryMuscleGroup: 'Core',
                ),
              ],
              isCompleted: true,
            ),
          );
        }
      }
    }

    // Add all sessions to the box
    if (kDebugMode) {
      debugPrint('DEBUG: Adding ${sessions.length} progressive sessions to box...');
    }
    for (final session in sessions) {
      _sessionBox.add(session);
      _updatePersonalRecords(session.exercises);
    }

    if (kDebugMode) {
      debugPrint(
        'DEBUG: Sessions added. Total completed sessions: ${completedSessions.length}',
      );
      debugPrint('DEBUG: Historical exercises: ${historicalExercises.length}');
      debugPrint(
        'DEBUG: Personal records updated. Total records: ${_recordBox.length}',
      );
    }

    notifyListeners();
  }

  // Method to clear all data (for testing purposes)
  void clearAllData() {
    _sessionBox.clear();
    _recordBox.clear();
    _currentSession = null;
    notifyListeners();
  }
}
