import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/personal_record.dart';
import '../models/exercise_set.dart';
import '../viewmodels/workout_session_viewmodel.dart';
import 'edit_workout_view.dart';

class ProgressView extends StatefulWidget {
  final List<PersonalRecord> records;
  const ProgressView({super.key, required this.records});

  @override
  State<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView> {
  String? selectedExercise;
  final TextEditingController _searchController = TextEditingController();
  List<String> filteredExercises = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterExercises(String query, List<String> allExercises) {
    setState(() {
      if (query.isEmpty) {
        filteredExercises = [];
        selectedExercise = null;
      } else {
        filteredExercises = allExercises
            .where(
              (exercise) =>
                  exercise.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _selectExercise(String exercise) {
    setState(() {
      selectedExercise = exercise;
      _searchController.text = exercise;
      filteredExercises = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress & Analytics'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Consumer<WorkoutSessionViewModel>(
        builder: (context, sessionViewModel, child) {
          final exerciseNames = sessionViewModel.historicalExercises;

          return Column(
            children: [
              if (exerciseNames.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.green.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildSearchSection(exerciseNames, sessionViewModel),
                  ),
                ),

              if (selectedExercise != null)
                Expanded(
                  flex: 2,
                  child: _buildWeightProgressionChart(
                    sessionViewModel,
                    selectedExercise!,
                  ),
                ),

              if (selectedExercise != null)
                Expanded(
                  flex: 3,
                  child: _buildExerciseProgressHistory(
                    sessionViewModel,
                    selectedExercise!,
                  ),
                ),

              if (selectedExercise == null)
                Expanded(flex: 3, child: _buildPersonalRecords()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchSection(
    List<String> exerciseNames,
    WorkoutSessionViewModel sessionViewModel,
  ) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          style: TextStyle(color: Colors.grey.shade800),
          decoration: InputDecoration(
            labelText: 'Search for an exercise',
            labelStyle: TextStyle(color: Colors.green.shade700),
            hintText: 'Type exercise name...',
            hintStyle: TextStyle(color: Colors.grey.shade600),
            prefixIcon: Icon(Icons.search, color: Colors.green.shade700),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.green.shade700),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        selectedExercise = null;
                        filteredExercises = [];
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green.shade700, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (query) => _filterExercises(query, exerciseNames),
        ),

        // Search Results
        if (filteredExercises.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green.shade300),
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.white,
            ),
            child: Column(
              children: filteredExercises.take(5).map((exercise) {
                return ListTile(
                  title: Text(
                    exercise,
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
                  leading: Icon(
                    Icons.fitness_center,
                    color: Colors.green.shade700,
                  ),
                  onTap: () => _selectExercise(exercise),
                  dense: true,
                );
              }).toList(),
            ),
          ),

        // Selected Exercise Indicator
        if (selectedExercise != null)
          Container(
            margin: const EdgeInsets.only(top: 12.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.green.shade600, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Viewing: $selectedExercise',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
                if (_getMuscleGroupInfo(
                  sessionViewModel,
                  selectedExercise!,
                ).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      _getMuscleGroupInfo(sessionViewModel, selectedExercise!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildWeightProgressionChart(
    WorkoutSessionViewModel viewModel,
    String exerciseName,
  ) {
    // Get weight progression data over time
    final progressionData = <Map<String, dynamic>>[];
    final seenSessions = <String>{};

    for (var session in viewModel.completedSessions) {
      if (seenSessions.contains(session.id)) continue;

      ExerciseSet? sessionMaxSet;
      for (var exercise in session.exercises) {
        if (exercise.name == exerciseName && exercise.sets.isNotEmpty) {
          final exerciseMaxSet = exercise.maxWeightSet;
          if (exerciseMaxSet != null) {
            if (sessionMaxSet == null ||
                exerciseMaxSet.weight > sessionMaxSet.weight) {
              sessionMaxSet = exerciseMaxSet;
            }
          }
        }
      }

      if (sessionMaxSet != null) {
        progressionData.add({
          'date': session.startTime,
          'weight': sessionMaxSet.weight,
          'reps': sessionMaxSet.reps,
        });
        seenSessions.add(session.id);
      }
    }

    progressionData.sort(
      (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
    );

    if (progressionData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'No weight progression data available',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ),
      );
    }

    final spots = progressionData
        .asMap()
        .entries
        .map(
          (entry) =>
              FlSpot(entry.key.toDouble(), entry.value['weight'] as double),
        )
        .toList();

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weight Progression Chart',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Maximum weight lifted over time',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: false,
                    color: Colors.green.shade600,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        final dataIndex = spot.x.toInt();
                        final reps =
                            dataIndex >= 0 && dataIndex < progressionData.length
                            ? progressionData[dataIndex]['reps'] as int
                            : 0;

                        return _RepCountDotPainter(
                          radius: 12,
                          color: Colors.green.shade600,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                          repCount: reps,
                        );
                      },
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}kg',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < progressionData.length) {
                          final date =
                              progressionData[index]['date'] as DateTime;
                          return Text(
                            '${date.month}/${date.day}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade700,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.green.shade300),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: null,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.green.shade200, strokeWidth: 1),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        if (index >= 0 && index < progressionData.length) {
                          final data = progressionData[index];
                          final date = data['date'] as DateTime;
                          final weight = data['weight'] as double;
                          final reps = data['reps'] as int;
                          return LineTooltipItem(
                            '${weight}kg × $reps reps\n${date.month}/${date.day}/${date.year}',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        }
                        return null;
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseProgressHistory(
    WorkoutSessionViewModel viewModel,
    String exerciseName,
  ) {
    // Get all completed sessions with this exercise
    final sessionsWithExercise = <Map<String, dynamic>>[];
    final seenSessions = <String>{};

    for (var session in viewModel.completedSessions) {
      if (seenSessions.contains(session.id)) continue;

      ExerciseSet? sessionMaxSet;
      var totalSets = 0;
      var totalVolume = 0.0;

      for (var exercise in session.exercises) {
        if (exercise.name == exerciseName && exercise.sets.isNotEmpty) {
          final exerciseMaxSet = exercise.maxWeightSet;
          if (exerciseMaxSet != null) {
            if (sessionMaxSet == null ||
                exerciseMaxSet.weight > sessionMaxSet.weight) {
              sessionMaxSet = exerciseMaxSet;
            }
          }
          totalSets += exercise.sets.length;
          totalVolume += exercise.volume;
        }
      }

      if (sessionMaxSet != null) {
        sessionsWithExercise.add({
          'date': session.startTime,
          'maxSet': sessionMaxSet,
          'sessionId': session.id,
          'totalSets': totalSets,
          'totalVolume': totalVolume,
        });
        seenSessions.add(session.id);
      }
    }

    sessionsWithExercise.sort(
      (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
    );

    if (sessionsWithExercise.isEmpty) {
      return Center(
        child: Text(
          'No workout history found for this exercise',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Weight Progress: $exerciseName',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.green.shade800),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: sessionsWithExercise.length,
            itemBuilder: (context, index) {
              final sessionData = sessionsWithExercise[index];
              final date = sessionData['date'] as DateTime;
              final maxSet = sessionData['maxSet'] as ExerciseSet;
              final totalSets = sessionData['totalSets'] as int;
              final totalVolume = sessionData['totalVolume'] as double;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                elevation: 2,
                child: InkWell(
                  onTap: () => _showWorkoutDetails(
                    context,
                    viewModel,
                    sessionData['sessionId'],
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Workout ${date.toLocal().toString().split(' ')[0]}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.grey.shade800),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade600,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Max Working Set',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Colors.green.shade700,
                                  ),
                                  onPressed: () => _editWorkout(
                                    context,
                                    viewModel,
                                    sessionData['sessionId'],
                                  ),
                                  tooltip: 'Edit Workout',
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${maxSet.weight}kg × ${maxSet.reps} reps',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Set Volume: ${(maxSet.weight * maxSet.reps).toStringAsFixed(1)}kg',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Total Sets: $totalSets',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                Text(
                                  'Total Volume: ${totalVolume.toStringAsFixed(1)}kg',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showWorkoutDetails(
    BuildContext context,
    WorkoutSessionViewModel viewModel,
    String sessionId,
  ) {
    final session = viewModel.completedSessions.firstWhere(
      (s) => s.id == sessionId,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Workout Details - ${session.startTime.toLocal().toString().split(' ')[0]}',
          style: TextStyle(color: Colors.green.shade800),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: session.exercises.length,
            itemBuilder: (context, index) {
              final exercise = session.exercises[index];
              return Card(
                color: Colors.white,
                elevation: 2,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade300, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.green.shade800),
                        ),
                        const SizedBox(height: 8),
                        ...exercise.sets.asMap().entries.map((entry) {
                          final setIndex = entry.key;
                          final set = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: [
                                Text(
                                  'Set ${setIndex + 1}: ',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                                Text(
                                  '${set.weight}kg × ${set.reps} reps',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                if (set.isCompleted)
                                  const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(color: Colors.green.shade700),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _editWorkout(context, viewModel, sessionId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Edit Workout'),
          ),
        ],
      ),
    );
  }

  void _editWorkout(
    BuildContext context,
    WorkoutSessionViewModel viewModel,
    String sessionId,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditWorkoutView(sessionId: sessionId),
      ),
    );
  }

  Widget _buildPersonalRecords() {
    if (widget.records.isEmpty) {
      return Center(
        child: Text(
          'Complete some workouts to see your personal records!',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Records - Weight Progression',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.green.shade800),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap any exercise to view detailed analytics',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.records.length,
            itemBuilder: (context, index) {
              final record = widget.records[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                elevation: selectedExercise == record.exerciseName ? 4.0 : 1.0,
                color: selectedExercise == record.exerciseName
                    ? Colors.white
                    : null,
                child: Container(
                  decoration: selectedExercise == record.exerciseName
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.shade600,
                            width: 2,
                          ),
                        )
                      : null,
                  child: InkWell(
                    onTap: () => _selectExercise(record.exerciseName),
                    borderRadius: BorderRadius.circular(12.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                record.exerciseName,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                    ),
                              ),
                              Icon(
                                Icons.analytics_outlined,
                                color: Colors.green.shade600,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Max Weight: ${record.maxWeight}kg',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'at ${record.maxReps} reps',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Achieved: ${record.achievedDate.toLocal().toString().split(' ')[0]}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Best Volume: ${record.totalVolume.toStringAsFixed(1)}kg',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getMuscleGroupInfo(
    WorkoutSessionViewModel viewModel,
    String exerciseName,
  ) {
    for (var session in viewModel.completedSessions) {
      for (var exercise in session.exercises) {
        if (exercise.name == exerciseName) {
          final muscleGroups = <String>[];

          if (exercise.primaryMuscleGroup != null) {
            muscleGroups.add('Primary: ${exercise.primaryMuscleGroup}');
          }
          if (exercise.secondaryMuscleGroup != null) {
            muscleGroups.add('Secondary: ${exercise.secondaryMuscleGroup}');
          }
          if (exercise.tertiaryMuscleGroup != null) {
            muscleGroups.add('Tertiary: ${exercise.tertiaryMuscleGroup}');
          }

          return muscleGroups.join(', ');
        }
      }
    }
    return '';
  }
}

// Custom dot painter that displays rep count inside the dot
class _RepCountDotPainter extends FlDotPainter {
  final double radius;
  final Color color;
  final double strokeWidth;
  final Color strokeColor;
  final int repCount;

  _RepCountDotPainter({
    required this.radius,
    required this.color,
    required this.strokeWidth,
    required this.strokeColor,
    required this.repCount,
  });

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(offsetInCanvas, radius, paint);

    if (strokeWidth > 0) {
      final strokePaint = Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawCircle(offsetInCanvas, radius, strokePaint);
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: repCount.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final textOffset = Offset(
      offsetInCanvas.dx - textPainter.width / 2,
      offsetInCanvas.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, textOffset);
  }

  @override
  Size getSize(FlSpot spot) {
    return Size(radius * 2, radius * 2);
  }

  @override
  Color get mainColor => color;

  @override
  List<Object?> get props => [
    radius,
    color,
    strokeWidth,
    strokeColor,
    repCount,
  ];

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) {
    if (a is _RepCountDotPainter && b is _RepCountDotPainter) {
      return _RepCountDotPainter(
        radius: a.radius + (b.radius - a.radius) * t,
        color: Color.lerp(a.color, b.color, t) ?? a.color,
        strokeWidth: a.strokeWidth + (b.strokeWidth - a.strokeWidth) * t,
        strokeColor:
            Color.lerp(a.strokeColor, b.strokeColor, t) ?? a.strokeColor,
        repCount: t < 0.5 ? a.repCount : b.repCount,
      );
    }
    return this;
  }
}
