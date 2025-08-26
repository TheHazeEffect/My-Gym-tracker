import 'package:flutter/material.dart';

class AddExerciseDialog extends StatefulWidget {
  final Set<String> historicalExercises;
  final Function(String) onExerciseSelected;

  const AddExerciseDialog({
    super.key,
    required this.historicalExercises,
    required this.onExerciseSelected,
  });

  @override
  State<AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<AddExerciseDialog> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customController = TextEditingController();
  List<String> _filteredExercises = [];
  bool _showCustomInput = false;

  @override
  void initState() {
    super.initState();
    _filteredExercises = widget.historicalExercises.toList()..sort();
  }

  void _filterExercises(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredExercises = widget.historicalExercises.toList()..sort();
      } else {
        _filteredExercises = widget.historicalExercises
            .where((exercise) =>
                exercise.toLowerCase().contains(query.toLowerCase()))
            .toList()
          ..sort();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Add Exercise',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search exercises',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterExercises('');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: _filterExercises,
            ),
            const SizedBox(height: 16),
            
            // Toggle for custom exercise
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Add custom exercise'),
                Switch(
                  value: _showCustomInput,
                  onChanged: (value) {
                    setState(() {
                      _showCustomInput = value;
                      if (!value) {
                        _customController.clear();
                      }
                    });
                  },
                  activeThumbColor: Colors.green,
                ),
              ],
            ),
            
            if (_showCustomInput) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _customController,
                decoration: const InputDecoration(
                  labelText: 'Custom exercise name',
                  prefixIcon: Icon(Icons.fitness_center),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Exercise list
            Expanded(
              child: _showCustomInput
                  ? const Center(
                      child: Text(
                        'Enter a custom exercise name above',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : _filteredExercises.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No exercises found',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Try a different search term or add a custom exercise',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredExercises.length,
                          itemBuilder: (context, index) {
                            final exercise = _filteredExercises[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade600,
                                child: Icon(
                                  Icons.fitness_center,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: Text(exercise),
                              onTap: () {
                                widget.onExerciseSelected(exercise);
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (_showCustomInput)
          ElevatedButton(
            onPressed: _customController.text.trim().isNotEmpty
                ? () {
                    widget.onExerciseSelected(_customController.text.trim());
                    Navigator.of(context).pop();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customController.dispose();
    super.dispose();
  }
}
