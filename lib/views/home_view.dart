import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/workout_session_viewmodel.dart';
import 'workout_details_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionViewModel = Provider.of<WorkoutSessionViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Gym Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Active workout card
            if (sessionViewModel.currentSession != null)
              Card(
                color: Colors.green.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.play_circle_fill,
                        color: Colors.green,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Workout in Progress',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${sessionViewModel.currentSession!.exercises.length} exercises added',
                      ),
                      Text(
                        'Total Volume: ${sessionViewModel.currentSession!.totalVolume.toStringAsFixed(1)}kg',
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WorkoutDetailsView(),
                            ),
                          ),
                          child: const Text('Continue Workout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Start workout button
            if (sessionViewModel.currentSession == null) ...[
              const Icon(Icons.fitness_center, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              const Text(
                'Ready to start your workout?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Track your exercises, sets, and progress',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    sessionViewModel.startWorkout();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WorkoutDetailsView(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow, size: 28),
                  label: const Text(
                    'Start Workout',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    // Uses theme colors from main.dart
                  ),
                ),
              ),
            ],

            // Temporary: Add dummy data button
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                sessionViewModel.addDummyData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Realistic workout data added!'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Add Sample Workout Data'),
            ),

            // Clear data button (for testing)
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                sessionViewModel.clearAllData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Clear All Data'),
            ),

            // Completed sessions summary
            if (sessionViewModel.completedSessions.isNotEmpty) ...[
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${sessionViewModel.completedSessions.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Workouts'),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${sessionViewModel.historicalExercises.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Exercises'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
