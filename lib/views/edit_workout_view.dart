import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';
import '../models/workout_session.dart';
import '../viewmodels/workout_session_viewmodel.dart';

class EditWorkoutView extends StatefulWidget {
  final String sessionId;

  const EditWorkoutView({super.key, required this.sessionId});

  @override
  State<EditWorkoutView> createState() => _EditWorkoutViewState();
}

class _EditWorkoutViewState extends State<EditWorkoutView> {
  WorkoutSession? originalSession;
  late WorkoutSession editedSession;

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<WorkoutSessionViewModel>(
      context,
      listen: false,
    );
    originalSession = viewModel.completedSessions.firstWhere(
      (s) => s.id == widget.sessionId,
    );
    editedSession = _copySession(originalSession!);
  }

  WorkoutSession _copySession(WorkoutSession session) {
    return WorkoutSession(
      id: session.id,
      startTime: session.startTime,
      endTime: session.endTime,
      exercises: session.exercises
          .map(
            (exercise) => Exercise(
              name: exercise.name,
              sets: exercise.sets
                  .map(
                    (set) => ExerciseSet(
                      reps: set.reps,
                      weight: set.weight,
                      isCompleted: set.isCompleted,
                    ),
                  )
                  .toList(),
              primaryMuscleGroup: exercise.primaryMuscleGroup,
              secondaryMuscleGroup: exercise.secondaryMuscleGroup,
              tertiaryMuscleGroup: exercise.tertiaryMuscleGroup,
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (originalSession == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout Not Found')),
        body: const Center(child: Text('Workout not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Workout - ${editedSession.startTime.toLocal().toString().split(' ')[0]}',
        ),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Started: ${editedSession.startTime.toString().split('.')[0]}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Volume: ${editedSession.totalVolume.toStringAsFixed(1)}kg',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: editedSession.exercises.length,
              itemBuilder: (context, exerciseIndex) {
                final exercise = editedSession.exercises[exerciseIndex];
                return EditableExerciseCard(
                  exercise: exercise,
                  exerciseIndex: exerciseIndex,
                  onExerciseUpdated: (updatedExercise) {
                    setState(() {
                      editedSession.exercises[exerciseIndex] = updatedExercise;
                    });
                  },
                  onExerciseRemoved: () {
                    setState(() {
                      editedSession.exercises.removeAt(exerciseIndex);
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    final viewModel = Provider.of<WorkoutSessionViewModel>(
      context,
      listen: false,
    );
    viewModel.updateCompletedSession(editedSession);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout updated successfully')),
    );
  }
}

class EditableExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final int exerciseIndex;
  final Function(Exercise) onExerciseUpdated;
  final VoidCallback onExerciseRemoved;

  const EditableExerciseCard({
    super.key,
    required this.exercise,
    required this.exerciseIndex,
    required this.onExerciseUpdated,
    required this.onExerciseRemoved,
  });

  @override
  State<EditableExerciseCard> createState() => _EditableExerciseCardState();
}

class _EditableExerciseCardState extends State<EditableExerciseCard> {
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Volume: ${widget.exercise.volume.toStringAsFixed(1)}kg',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Exercise'),
                            content: Text(
                              'Remove ${widget.exercise.name} from this workout?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  widget.onExerciseRemoved();
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
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
                const Expanded(
                  flex: 1,
                  child: Text(
                    '',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ), // For delete button
              ],
            ),
            const Divider(),

            // Sets list
            ...widget.exercise.sets.asMap().entries.map((entry) {
              final setIndex = entry.key;
              final set = entry.value;
              return EditableSetRow(
                setNumber: setIndex + 1,
                set: set,
                onSetUpdated: (updatedSet) => _updateSet(setIndex, updatedSet),
                onSetRemoved: () => _removeSet(setIndex),
              );
            }),

            const SizedBox(height: 8),
            OutlinedButton(onPressed: _addSet, child: const Text('Add Set')),
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

  void _removeSet(int setIndex) {
    final updatedSets = List<ExerciseSet>.from(widget.exercise.sets)
      ..removeAt(setIndex);
    _updateExercise(updatedSets);
  }

  void _updateSet(int setIndex, ExerciseSet updatedSet) {
    final updatedSets = List<ExerciseSet>.from(widget.exercise.sets);
    updatedSets[setIndex] = updatedSet;
    _updateExercise(updatedSets);
  }

  void _updateExercise(List<ExerciseSet> updatedSets) {
    widget.onExerciseUpdated(
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

class EditableSetRow extends StatefulWidget {
  final int setNumber;
  final ExerciseSet set;
  final Function(ExerciseSet) onSetUpdated;
  final VoidCallback onSetRemoved;

  const EditableSetRow({
    super.key,
    required this.setNumber,
    required this.set,
    required this.onSetUpdated,
    required this.onSetRemoved,
  });

  @override
  State<EditableSetRow> createState() => _EditableSetRowState();
}

class _EditableSetRowState extends State<EditableSetRow> {
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
          Expanded(
            flex: 1,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: widget.onSetRemoved,
              tooltip: 'Delete Set',
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
