import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';
import '../viewmodels/workout_session_viewmodel.dart';
import '../viewmodels/rest_timer_viewmodel.dart';
import '../views/rest_timer_view.dart';

class WorkoutDetailsView extends StatelessWidget {
  const WorkoutDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutSessionViewModel>(
      builder: (context, sessionViewModel, child) {
        final currentSession = sessionViewModel.currentSession;
        if (currentSession == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('No Active Workout')),
            body: const Center(child: Text('No workout in progress')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Workout in Progress'),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'cancel') {
                    final shouldCancel = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cancel Workout'),
                        content: const Text(
                          'Are you sure you want to cancel this workout? All progress will be lost.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Keep Workout'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Cancel Workout'),
                          ),
                        ],
                      ),
                    );
                    
                    if (shouldCancel == true) {
                      sessionViewModel.cancelWorkout();
                      if (context.mounted) {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'cancel',
                    child: Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Cancel Workout'),
                      ],
                    ),
                  ),
                ],
                icon: const Icon(Icons.more_vert),
              ),
              TextButton(
                onPressed: () {
                  sessionViewModel.completeWorkout();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text(
                  'Complete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Active Timers Display
              Consumer<RestTimerViewModel>(
                builder: (context, timerViewModel, child) {
                  final activeTimers = timerViewModel.timers
                      .where((timer) => 
                          timer.state == TimerState.running || 
                          timer.state == TimerState.paused)
                      .toList();
                  
                  if (activeTimers.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  
                  return Container(
                    margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
                    child: Column(
                      children: activeTimers.map((timer) => Card(
                        color: timer.state == TimerState.running 
                            ? Colors.white 
                            : Colors.orange.shade50,
                        elevation: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: timer.state == TimerState.running
                                ? Border.all(color: Colors.green.shade600, width: 2)
                                : Border.all(color: Colors.orange.shade400, width: 1),
                          ),
                          child: ListTile(
                            dense: true,
                            leading: Icon(
                              timer.state == TimerState.running 
                                  ? Icons.timer 
                                  : Icons.pause_circle_outline,
                              color: timer.state == TimerState.running 
                                  ? Colors.green.shade700 
                                  : Colors.orange.shade700,
                            ),
                            title: Text(
                              timer.name,
                              style: TextStyle(
                                fontSize: 14, 
                                fontWeight: FontWeight.w500,
                                color: timer.state == TimerState.running 
                                    ? Colors.green.shade800 
                                    : Colors.orange.shade800,
                              ),
                            ),
                            subtitle: Text(
                              timerViewModel.formatTime(timer.remainingTime),
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold,
                                color: timer.state == TimerState.running 
                                    ? Colors.green.shade700 
                                    : Colors.orange.shade700,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  iconSize: 20,
                                  icon: Icon(
                                    timer.state == TimerState.running 
                                        ? Icons.pause 
                                        : Icons.play_arrow,
                                  ),
                                  onPressed: () {
                                    if (timer.state == TimerState.running) {
                                      timerViewModel.pauseTimer(timer.id);
                                    } else {
                                      timerViewModel.resumeTimer(timer.id);
                                    }
                                  },
                                ),
                                IconButton(
                                  iconSize: 20,
                                  icon: const Icon(Icons.stop),
                                  onPressed: () => timerViewModel.stopTimer(timer.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )).toList(),
                    ),
                  );
                },
              ),
              // Workout Info Section
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Started: ${currentSession.startTime.toString().split('.')[0]}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Volume: ${currentSession.totalVolume.toStringAsFixed(1)}kg',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: currentSession.exercises.length,
                  itemBuilder: (context, exerciseIndex) {
                    final exercise = currentSession.exercises[exerciseIndex];
                    return ExerciseCard(
                      exercise: exercise,
                      exerciseIndex: exerciseIndex,
                      sessionViewModel: sessionViewModel,
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: "timer",
                onPressed: () => _showTimerDialog(context),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: const Icon(Icons.timer),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: "add",
                onPressed: () => _showAddExerciseDialog(context, sessionViewModel),
                child: const Icon(Icons.add),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddExerciseDialog(
    BuildContext context,
    WorkoutSessionViewModel sessionViewModel,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: AddExerciseToWorkoutForm(
          historicalExercises: sessionViewModel.historicalExercises,
          onAdd: (exercise) =>
              sessionViewModel.addExerciseToCurrentWorkout(exercise),
        ),
      ),
    );
  }

  void _showTimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Rest Timer'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select timer duration:'),
            SizedBox(height: 16),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _startTimer(context, 'General Rest', 60);
              Navigator.of(context).pop();
            },
            child: const Text('1 min'),
          ),
          TextButton(
            onPressed: () {
              _startTimer(context, 'General Rest', 180);
              Navigator.of(context).pop();
            },
            child: const Text('3 min'),
          ),
          TextButton(
            onPressed: () {
              _startTimer(context, 'General Rest', 300);
              Navigator.of(context).pop();
            },
            child: const Text('5 min'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const RestTimerView()),
              );
            },
            child: const Text('Custom'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _startTimer(BuildContext context, String name, int seconds) {
    final timerViewModel = Provider.of<RestTimerViewModel>(
      context,
      listen: false,
    );
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    
    timerViewModel.startTimer(name, seconds);
    
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('Started ${seconds ~/ 60} min timer'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            navigator.push(
              MaterialPageRoute(
                builder: (context) => const RestTimerView(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final int exerciseIndex;
  final WorkoutSessionViewModel sessionViewModel;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.exerciseIndex,
    required this.sessionViewModel,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.exercise.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (widget.exercise.primaryMuscleGroup != null)
                        Text(
                          'Primary: ${widget.exercise.primaryMuscleGroup}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                Text(
                  'Volume: ${widget.exercise.volume.toStringAsFixed(1)}kg',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Sets header
            Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text(
                    'Set',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Reps',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Weight (kg)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: Text(
                    '✓',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(),

            // Sets list
            ...widget.exercise.sets.asMap().entries.map((entry) {
              final setIndex = entry.key;
              final set = entry.value;
              return SetRow(
                setNumber: setIndex + 1,
                set: set,
                onSetUpdated: (updatedSet) => _updateSet(setIndex, updatedSet),
              );
            }),

            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _addSet,
                    child: const Text('Add Set'),
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.exercise.sets.isNotEmpty)
                  OutlinedButton(
                    onPressed: _removeLastSet,
                    child: const Text('Remove Set'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addSet() {
    final lastSet = widget.exercise.sets.isNotEmpty
        ? widget.exercise.sets.last
        : null;

    final newSet = ExerciseSet(
      reps: lastSet?.reps ?? 8,
      weight: lastSet?.weight ?? 20.0,
      isCompleted: false,
    );

    final updatedSets = [...widget.exercise.sets, newSet];
    _updateExercise(updatedSets);
  }

  void _removeLastSet() {
    if (widget.exercise.sets.isNotEmpty) {
      final updatedSets = List<ExerciseSet>.from(widget.exercise.sets)
        ..removeLast();
      _updateExercise(updatedSets);
    }
  }

  void _updateSet(int setIndex, ExerciseSet updatedSet) {
    final updatedSets = List<ExerciseSet>.from(widget.exercise.sets);
    updatedSets[setIndex] = updatedSet;
    _updateExercise(updatedSets);
  }

  void _updateExercise(List<ExerciseSet> updatedSets) {
    widget.sessionViewModel.updateExerciseInCurrentWorkout(
      widget.exerciseIndex,
      Exercise(
        name: widget.exercise.name,
        sets: updatedSets,
        primaryMuscleGroup: widget.exercise.primaryMuscleGroup,
        secondaryMuscleGroup: widget.exercise.secondaryMuscleGroup,
        tertiaryMuscleGroup: widget.exercise.tertiaryMuscleGroup,
      ),
    );
  }
}

class SetRow extends StatefulWidget {
  final int setNumber;
  final ExerciseSet set;
  final Function(ExerciseSet) onSetUpdated;

  const SetRow({
    super.key,
    required this.setNumber,
    required this.set,
    required this.onSetUpdated,
  });

  @override
  State<SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<SetRow> {
  late TextEditingController _repsController;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController(text: widget.set.reps.toString());
    _weightController = TextEditingController(
      text: widget.set.weight.toString(),
    );
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text('${widget.setNumber}')),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                border: OutlineInputBorder(),
              ),
              onChanged: _updateSet,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                border: OutlineInputBorder(),
              ),
              onChanged: _updateSet,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Checkbox(
              value: widget.set.isCompleted,
              onChanged: (value) {
                final updatedSet = widget.set.copyWith(
                  isCompleted: value ?? false,
                );
                widget.onSetUpdated(updatedSet);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _updateSet(String value) {
    final reps = int.tryParse(_repsController.text) ?? widget.set.reps;
    final weight = double.tryParse(_weightController.text) ?? widget.set.weight;

    final updatedSet = widget.set.copyWith(reps: reps, weight: weight);
    widget.onSetUpdated(updatedSet);
  }
}

class AddExerciseToWorkoutForm extends StatefulWidget {
  final List<String> historicalExercises;
  final Function(Exercise) onAdd;

  const AddExerciseToWorkoutForm({
    super.key,
    required this.historicalExercises,
    required this.onAdd,
  });

  @override
  State<AddExerciseToWorkoutForm> createState() =>
      _AddExerciseToWorkoutFormState();
}

class _AddExerciseToWorkoutFormState extends State<AddExerciseToWorkoutForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String? _primaryMuscleGroup;
  String? _secondaryMuscleGroup;
  String? _tertiaryMuscleGroup;
  bool _isNewExercise = false;

  final _muscleGroups = [
    'Chest',
    'Back',
    'Shoulders',
    'Arms',
    'Legs',
    'Core',
    'Biceps',
    'Triceps',
    'Quadriceps',
    'Hamstrings',
    'Glutes',
    'Calves',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Exercise to Workout',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Historical Exercise'),
                    leading: Radio<bool>(
                      value: false,
                      groupValue: _isNewExercise,
                      onChanged: (value) =>
                          setState(() => _isNewExercise = value!),
                    ),
                    onTap: () => setState(() => _isNewExercise = false),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('New Exercise'),
                    leading: Radio<bool>(
                      value: true,
                      groupValue: _isNewExercise,
                      onChanged: (value) =>
                          setState(() => _isNewExercise = value!),
                    ),
                    onTap: () => setState(() => _isNewExercise = true),
                  ),
                ),
              ],
            ),
            if (_isNewExercise)
              TextFormField(
                decoration: const InputDecoration(labelText: 'Exercise Name'),
                onSaved: (val) => _name = val ?? '',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter a name' : null,
              )
            else
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Exercise'),
                items: widget.historicalExercises.map((exercise) {
                  return DropdownMenuItem(
                    value: exercise,
                    child: Text(exercise),
                  );
                }).toList(),
                onChanged: (value) => _name = value ?? '',
                validator: (val) => val == null ? 'Select an exercise' : null,
              ),
            if (_isNewExercise) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Primary Muscle Group',
                ),
                items: _muscleGroups.map((muscle) {
                  return DropdownMenuItem(value: muscle, child: Text(muscle));
                }).toList(),
                onChanged: (value) => _primaryMuscleGroup = value,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Secondary Muscle Group',
                ),
                items: _muscleGroups.map((muscle) {
                  return DropdownMenuItem(value: muscle, child: Text(muscle));
                }).toList(),
                onChanged: (value) => _secondaryMuscleGroup = value,
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();

                    // Create exercise with one default set
                    final defaultSet = ExerciseSet(
                      reps: 8,
                      weight: 20.0,
                      isCompleted: false,
                    );

                    final exercise = Exercise(
                      name: _name,
                      sets: [defaultSet],
                      primaryMuscleGroup: _primaryMuscleGroup,
                      secondaryMuscleGroup: _secondaryMuscleGroup,
                      tertiaryMuscleGroup: _tertiaryMuscleGroup,
                    );
                    widget.onAdd(exercise);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Add Exercise'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
