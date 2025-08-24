import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';

class ExerciseListView extends StatelessWidget {
  final List<Exercise> exercises;
  const ExerciseListView({super.key, required this.exercises});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        final maxWeightSet = exercise.maxWeightSet;
        final setCount = exercise.sets.length;

        return ListTile(
          title: Text(exercise.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sets: $setCount${maxWeightSet != null ? ', Max: ${maxWeightSet.reps} reps @ ${maxWeightSet.weight}kg' : ', No sets recorded'}',
              ),
              if (exercise.primaryMuscleGroup != null ||
                  exercise.secondaryMuscleGroup != null ||
                  exercise.tertiaryMuscleGroup != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _buildMuscleGroupText(exercise),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _buildMuscleGroupText(Exercise exercise) {
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

class AddExerciseForm extends StatefulWidget {
  final Function(Exercise) onAdd;
  const AddExerciseForm({super.key, required this.onAdd});

  @override
  State<AddExerciseForm> createState() => _AddExerciseFormState();
}

class _AddExerciseFormState extends State<AddExerciseForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String? _primaryMuscleGroup;
  String? _secondaryMuscleGroup;
  String? _tertiaryMuscleGroup;
  int _sets = 1;
  int _reps = 1;
  double _weight = 0;

  // Common muscle groups for dropdown selection
  final List<String> _muscleGroups = [
    'Chest',
    'Back',
    'Shoulders',
    'Biceps',
    'Triceps',
    'Quadriceps',
    'Hamstrings',
    'Glutes',
    'Calves',
    'Core',
    'Lats',
    'Rhomboids',
    'Rear Delts',
    'Traps',
    'Forearms',
  ];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Exercise Name'),
            onSaved: (val) => _name = val ?? '',
            validator: (val) =>
                val == null || val.isEmpty ? 'Enter a name' : null,
          ),
          const SizedBox(height: 16),
          // Primary Muscle Group
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Primary Muscle Group',
            ),
            initialValue: _primaryMuscleGroup,
            onChanged: (value) => setState(() => _primaryMuscleGroup = value),
            items: _muscleGroups
                .map(
                  (muscle) => DropdownMenuItem<String>(
                    value: muscle,
                    child: Text(muscle),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          // Secondary Muscle Group
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Secondary Muscle Group (Optional)',
            ),
            initialValue: _secondaryMuscleGroup,
            onChanged: (value) => setState(() => _secondaryMuscleGroup = value),
            items: [
              const DropdownMenuItem<String>(value: null, child: Text('None')),
              ..._muscleGroups
                  .map(
                    (muscle) => DropdownMenuItem<String>(
                      value: muscle,
                      child: Text(muscle),
                    ),
                  ),
            ],
          ),
          const SizedBox(height: 12),
          // Tertiary Muscle Group
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Tertiary Muscle Group (Optional)',
            ),
            initialValue: _tertiaryMuscleGroup,
            onChanged: (value) => setState(() => _tertiaryMuscleGroup = value),
            items: [
              const DropdownMenuItem<String>(value: null, child: Text('None')),
              ..._muscleGroups
                  .map(
                    (muscle) => DropdownMenuItem<String>(
                      value: muscle,
                      child: Text(muscle),
                    ),
                  ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(labelText: 'Sets'),
            keyboardType: TextInputType.number,
            onSaved: (val) => _sets = int.tryParse(val ?? '1') ?? 1,
            validator: (val) =>
                val == null || int.tryParse(val) == null ? 'Enter sets' : null,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Reps'),
            keyboardType: TextInputType.number,
            onSaved: (val) => _reps = int.tryParse(val ?? '1') ?? 1,
            validator: (val) =>
                val == null || int.tryParse(val) == null ? 'Enter reps' : null,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Weight (kg)'),
            keyboardType: TextInputType.number,
            onSaved: (val) => _weight = double.tryParse(val ?? '0') ?? 0,
            validator: (val) => val == null || double.tryParse(val) == null
                ? 'Enter weight'
                : null,
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState?.save();
                // Create the specified number of sets with the given reps and weight
                final exerciseSets = List.generate(
                  _sets,
                  (index) => ExerciseSet(reps: _reps, weight: _weight),
                );

                final exercise = Exercise(
                  name: _name,
                  sets: exerciseSets,
                  primaryMuscleGroup: _primaryMuscleGroup,
                  secondaryMuscleGroup: _secondaryMuscleGroup,
                  tertiaryMuscleGroup: _tertiaryMuscleGroup,
                );
                widget.onAdd(exercise);
                Navigator.of(context).pop();
              }
            },
            child: Text('Add Exercise'),
          ),
        ],
      ),
    );
  }
}
