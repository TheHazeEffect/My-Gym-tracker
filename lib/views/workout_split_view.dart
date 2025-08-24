import 'package:flutter/material.dart';
import '../models/workout_split.dart';

class WorkoutSplitListView extends StatelessWidget {
  final List<WorkoutSplit> splits;
  final void Function(int) onDelete;
  final void Function(int, WorkoutSplit) onEdit;
  const WorkoutSplitListView({
    super.key,
    required this.splits,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: splits.length,
      itemBuilder: (context, index) {
        final split = splits[index];
        return ListTile(
          title: Text(split.name),
          subtitle: Text('Exercises: ${split.exerciseNames.join(", ")}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  // Call onEdit with index and split
                  onEdit(index, split);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  onDelete(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class AddSplitForm extends StatefulWidget {
  final Function(WorkoutSplit) onAdd;
  const AddSplitForm({super.key, required this.onAdd});

  @override
  State<AddSplitForm> createState() => _AddSplitFormState();
}

class _AddSplitFormState extends State<AddSplitForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Split Name'),
            onSaved: (val) => _name = val ?? '',
            validator: (val) =>
                val == null || val.isEmpty ? 'Enter a name' : null,
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState?.save();
                final split = WorkoutSplit(name: _name);
                widget.onAdd(split);
                Navigator.of(context).pop();
              }
            },
            child: Text('Add Split'),
          ),
        ],
      ),
    );
  }
}
