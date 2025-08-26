import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/rest_timer_viewmodel.dart';

class RestTimerView extends StatelessWidget {
  const RestTimerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RestTimerViewModel>(
      builder: (context, timerViewModel, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Rest Timers')),
          body: Column(
            children: [
              // Quick timer buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => timerViewModel.start1MinTimer(),
                      child: const Text('1 Min'),
                    ),
                    ElevatedButton(
                      onPressed: () => timerViewModel.start3MinTimer(),
                      child: const Text('3 Min'),
                    ),
                    ElevatedButton(
                      onPressed: () => timerViewModel.start5MinTimer(),
                      child: const Text('5 Min'),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          _showAddTimerDialog(context, timerViewModel),
                      child: const Text('Custom'),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Timer list
              Expanded(
                child: timerViewModel.timers.isEmpty
                    ? const Center(
                        child: Text(
                          'No timers active\nTap a button above to start a timer',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: timerViewModel.timers.length,
                        itemBuilder: (context, index) {
                          final timer = timerViewModel.timers[index];
                          return _buildTimerCard(timer, timerViewModel);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimerCard(TimerData timer, RestTimerViewModel timerViewModel) {
    Color cardColor;
    IconData statusIcon;

    switch (timer.state) {
      case TimerState.running:
        cardColor = Colors.white;
        statusIcon = Icons.timer;
        break;
      case TimerState.paused:
        cardColor = Colors.orange.shade50;
        statusIcon = Icons.pause_circle;
        break;
      case TimerState.completed:
        cardColor = Colors.white;
        statusIcon = Icons.check_circle;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      color: cardColor,
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: timer.state == TimerState.running
              ? Border.all(color: Colors.green.shade600, width: 2)
              : timer.state == TimerState.completed
                  ? Border.all(color: Colors.green.shade400, width: 1.5)
                  : null,
        ),
        child: ListTile(
        leading: Icon(statusIcon, color: _getStatusColor(timer.state)),
        title: Text(
          timer.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: timer.state == TimerState.completed
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              timerViewModel.formatTime(timer.remainingTime),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: timer.state == TimerState.completed
                    ? Colors.green.shade700
                    : timer.remainingTime <= 10
                    ? Colors.red.shade700
                    : Colors.black87,
              ),
            ),
            Text(
              'Original: ${timerViewModel.formatTime(timer.originalDuration)} | ${_formatTimestamp(timer.createdAt)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: _buildTimerActions(timer, timerViewModel),
        ),
      ),
    );
  }

  Widget _buildTimerActions(
    TimerData timer,
    RestTimerViewModel timerViewModel,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (timer.state == TimerState.running) ...[
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: () => timerViewModel.pauseTimer(timer.id),
            tooltip: 'Pause',
          ),
        ] else if (timer.state == TimerState.paused) ...[
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () => timerViewModel.resumeTimer(timer.id),
            tooltip: 'Resume',
          ),
        ],
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => timerViewModel.restartTimer(timer.id),
          tooltip: 'Restart',
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => timerViewModel.stopTimer(timer.id),
          tooltip: 'Delete',
        ),
      ],
    );
  }

  Color _getStatusColor(TimerState state) {
    switch (state) {
      case TimerState.running:
        return Colors.green;
      case TimerState.paused:
        return Colors.orange;
      case TimerState.completed:
        return Colors.green;
    }
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showAddTimerDialog(
    BuildContext context,
    RestTimerViewModel timerViewModel,
  ) {
    final nameController = TextEditingController();
    final minutesController = TextEditingController();
    final secondsController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Custom Timer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Timer Name',
                hintText: 'e.g., Bicep Curls Rest',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: minutesController,
                    decoration: const InputDecoration(labelText: 'Minutes'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: secondsController,
                    decoration: const InputDecoration(labelText: 'Seconds'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Note: Timer will vibrate and persist when completed',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final minutes = int.tryParse(minutesController.text) ?? 0;
              final seconds = int.tryParse(secondsController.text) ?? 0;
              final totalSeconds = (minutes * 60) + seconds;

              if (totalSeconds > 0) {
                final finalName = name.isNotEmpty
                    ? name
                    : '$minutes:${seconds.toString().padLeft(2, '0')} Timer';
                timerViewModel.startTimer(finalName, totalSeconds);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Start Timer'),
          ),
        ],
      ),
    );
  }
}
