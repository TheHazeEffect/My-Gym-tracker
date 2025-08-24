import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/workout.dart';
import 'viewmodels/workout_viewmodel.dart';
import 'views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(WorkoutAdapter());
  await Hive.openBox<Workout>('workouts');
  runApp(const GymTrackerApp());
}

class GymTrackerApp extends StatelessWidget {
  const GymTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WorkoutViewModel()),
      ],
      child: MaterialApp(
        title: 'Gym Tracker',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const HomeView(),
      ),
    );
  }
}
