import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodels/workout_viewmodel.dart';
import '../models/workout.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<WorkoutViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Gym Tracker')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: viewModel.workouts.length,
              itemBuilder: (context, index) {
                final workout = viewModel.workouts[index];
                return ListTile(
                  title: Text(workout.name),
                  subtitle: Text('${workout.date} - ${workout.duration} min'),
                );
              },
            ),
          ),
          SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: viewModel.workouts
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                              e.key.toDouble(), e.value.duration.toDouble()))
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          viewModel.addWorkout(
            Workout(
              name: 'Workout ${viewModel.workouts.length + 1}',
              date: DateTime.now(),
              duration: 30,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
