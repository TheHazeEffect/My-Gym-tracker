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
                color: Colors.green.shade50,
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.play_circle_fill,
                            color: Colors.green.shade600,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Workout in Progress',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${sessionViewModel.currentSession!.exercises.length} exercises • ${sessionViewModel.currentSession!.totalVolume.toStringAsFixed(0)}kg total',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

            // Start workout section
            if (sessionViewModel.currentSession == null) ...[
              Column(
                children: [
                  Icon(
                    Icons.fitness_center, 
                    size: 64, 
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Ready to start your workout?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track exercises, sets, and progress',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
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
                      icon: const Icon(Icons.play_arrow, size: 24),
                      label: const Text(
                        'Start Workout',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Quick stats summary (only if there are completed sessions)
            if (sessionViewModel.completedSessions.isNotEmpty) ...[
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Workout Summary',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn(
                            '${sessionViewModel.completedSessions.length}',
                            'Total Workouts',
                          ),
                          _buildStatColumn(
                            '${sessionViewModel.historicalExercises.length}',
                            'Unique Exercises',
                          ),
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

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
