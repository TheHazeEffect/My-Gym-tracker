import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/workout.dart';
import 'models/exercise.dart';
import 'models/exercise_set.dart';
import 'models/workout_split.dart';
import 'models/personal_record.dart';
import 'models/workout_session.dart';
import 'viewmodels/workout_viewmodel.dart';
import 'viewmodels/workout_split_viewmodel.dart';
import 'viewmodels/personal_record_viewmodel.dart';
import 'viewmodels/rest_timer_viewmodel.dart';
import 'viewmodels/workout_session_viewmodel.dart';
import 'views/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(WorkoutAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(ExerciseSetAdapter());
  Hive.registerAdapter(WorkoutSplitAdapter());
  Hive.registerAdapter(PersonalRecordAdapter());
  Hive.registerAdapter(WorkoutSessionAdapter());

  // Clear all boxes if there are any compatibility issues
  bool hasErrors = false;

  try {
    await Hive.openBox<Workout>('workouts');
    await Hive.openBox<Exercise>('exercises');
    await Hive.openBox<WorkoutSplit>('splits');
    await Hive.openBox<PersonalRecord>('records');
    await Hive.openBox<WorkoutSession>('sessions');
  } catch (e) {
    if (kDebugMode) {
      print('Error opening boxes: $e');
    }
    hasErrors = true;
  }

  if (hasErrors) {
    if (kDebugMode) {
      print('Clearing all Hive data due to compatibility issues...');
    }
    final boxNames = ['workouts', 'exercises', 'splits', 'records', 'sessions'];
    for (String boxName in boxNames) {
      try {
        await Hive.deleteBoxFromDisk(boxName);
      } catch (e) {
        if (kDebugMode) {
          print('Error deleting $boxName: $e');
        }
      }
    }

    // Reopen boxes after clearing
    await Hive.openBox<Workout>('workouts');
    await Hive.openBox<Exercise>('exercises');
    await Hive.openBox<WorkoutSplit>('splits');
    await Hive.openBox<PersonalRecord>('records');
    await Hive.openBox<WorkoutSession>('sessions');
  }

  runApp(const GymTrackerApp());
}

class GymTrackerApp extends StatelessWidget {
  const GymTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WorkoutViewModel()),
        ChangeNotifierProvider(create: (_) => WorkoutSplitViewModel()),
        ChangeNotifierProvider(create: (_) => PersonalRecordViewModel()),
        ChangeNotifierProvider(create: (_) => RestTimerViewModel()),
        ChangeNotifierProvider(create: (_) => WorkoutSessionViewModel()),
      ],
      child: MaterialApp(
        title: 'Gym Tracker',
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: Colors.green.shade700,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
            primary: Colors.green.shade700,
            secondary: Colors.green.shade400,
            surface: Colors.white,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Colors.grey.shade800,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              elevation: 2,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.green.shade700,
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            color: Colors.white,
            shadowColor: Colors.grey.shade300,
          ),
          inputDecorationTheme: InputDecorationTheme(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green.shade700, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green.shade300),
            ),
            labelStyle: TextStyle(color: Colors.green.shade700),
            hintStyle: TextStyle(color: Colors.grey.shade600),
          ),
          progressIndicatorTheme: ProgressIndicatorThemeData(
            color: Colors.green.shade700,
          ),
          switchTheme: SwitchThemeData(
            thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.green.shade700;
              }
              return Colors.grey.shade400;
            }),
            trackColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.green.shade300;
              }
              return Colors.grey.shade300;
            }),
          ),
          sliderTheme: SliderThemeData(
            activeTrackColor: Colors.green.shade700,
            thumbColor: Colors.green.shade700,
            inactiveTrackColor: Colors.green.shade200,
          ),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.grey.shade800),
            bodyMedium: TextStyle(color: Colors.grey.shade800),
            titleLarge: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold),
            titleMedium: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w600),
            titleSmall: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w500),
          ),
        ),
        home: const MainNavigation(),
      ),
    );
  }
}
