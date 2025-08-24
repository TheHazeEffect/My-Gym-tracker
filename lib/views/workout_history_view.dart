import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../viewmodels/workout_session_viewmodel.dart';
import '../models/workout_session.dart';
import 'edit_workout_view.dart';

class WorkoutHistoryView extends StatefulWidget {
  const WorkoutHistoryView({super.key});

  @override
  State<WorkoutHistoryView> createState() => _WorkoutHistoryViewState();
}

class _WorkoutHistoryViewState extends State<WorkoutHistoryView> {
  late final ValueNotifier<List<WorkoutSession>> _selectedEvents;
  late final PageController _pageController;
  
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  @override
  void initState() {
    super.initState();
    _selectedDay = null; // Start with no day selected to show all workouts
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
    _pageController = PageController();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<WorkoutSession> _getEventsForDay(DateTime? day) {
    final sessionViewModel = Provider.of<WorkoutSessionViewModel>(context, listen: false);
    
    if (day == null) {
      // Return all workouts for the focused month
      return sessionViewModel.completedSessions.where((session) {
        return session.startTime.year == _focusedDay.year &&
               session.startTime.month == _focusedDay.month;
      }).toList();
    } else {
      // Return workouts for the selected day
      return sessionViewModel.completedSessions.where((session) {
        return isSameDay(session.startTime, day);
      }).toList();
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        if (_selectedDay != null && isSameDay(_selectedDay!, selectedDay)) {
          // If tapping the same selected day, deselect it to show all month workouts
          _selectedDay = null;
        } else {
          _selectedDay = selectedDay;
        }
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getEventsForDay(_selectedDay);
    } else {
      // Tapping the same day again - deselect to show all month workouts
      setState(() {
        _selectedDay = null;
      });
      _selectedEvents.value = _getEventsForDay(null);
    }
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      if (_selectedDay == null) {
        // If no day is selected, update to show all workouts for the new month
        _selectedEvents.value = _getEventsForDay(null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = null;
              });
              _selectedEvents.value = _getEventsForDay(null);
            },
            tooltip: 'Go to Today',
          ),
        ],
      ),
      body: Consumer<WorkoutSessionViewModel>(
        builder: (context, sessionViewModel, child) {
          return Column(
            children: [
              // Calendar Widget
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TableCalendar<WorkoutSession>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  calendarFormat: _calendarFormat,
                  eventLoader: (day) {
                    return sessionViewModel.completedSessions
                        .where((session) => isSameDay(session.startTime, day))
                        .toList();
                  },
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: TextStyle(color: Colors.green.shade600),
                    holidayTextStyle: TextStyle(color: Colors.green.shade600),
                    selectedDecoration: BoxDecoration(
                      color: Colors.green.shade600,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.green.shade300,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: Colors.green.shade700,
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 3,
                    markerMargin: const EdgeInsets.symmetric(horizontal: 1.5),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    formatButtonDecoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    formatButtonTextStyle: const TextStyle(
                      color: Colors.white,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: Colors.green.shade700,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: Colors.green.shade700,
                    ),
                  ),
                  onDaySelected: _onDaySelected,
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: _onPageChanged,
                ),
              ),
              
              // Day filter indicator
              if (_selectedDay != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.filter_alt, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Showing workouts for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedDay = null;
                          });
                          _selectedEvents.value = _getEventsForDay(null);
                        },
                        child: Text(
                          'Show All',
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8.0),

              // Workout List
              Expanded(
                child: ValueListenableBuilder<List<WorkoutSession>>(
                  valueListenable: _selectedEvents,
                  builder: (context, value, _) {
                    if (value.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fitness_center_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedDay == null
                                  ? 'No workouts found this month'
                                  : 'No workouts on this day',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Complete some workouts to see them here!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Sort workouts by date (most recent first)
                    value.sort((a, b) => b.startTime.compareTo(a.startTime));

                    return ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        final workout = value[index];
                        final workoutDate = workout.startTime;
                        final duration = workout.endTime?.difference(workout.startTime);
                        
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          elevation: 2,
                          child: InkWell(
                            onTap: () => _showWorkoutDetails(context, workout),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${workoutDate.day}/${workoutDate.month}/${workoutDate.year}',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green.shade800,
                                            ),
                                          ),
                                          Text(
                                            '${workoutDate.hour.toString().padLeft(2, '0')}:${workoutDate.minute.toString().padLeft(2, '0')}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          if (duration != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0,
                                                vertical: 4.0,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade100,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '${duration.inHours}h ${duration.inMinutes % 60}m',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.green.shade700,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              size: 20,
                                              color: Colors.green.shade700,
                                            ),
                                            onPressed: () => _editWorkout(context, workout.id),
                                            tooltip: 'Edit Workout',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Exercise summary
                                  if (workout.exercises.isNotEmpty)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Exercises: ${workout.exercises.length}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 8.0,
                                          runSpacing: 4.0,
                                          children: workout.exercises
                                              .take(3) // Show first 3 exercises
                                              .map((exercise) => Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8.0,
                                                  vertical: 2.0,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade200,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  exercise.name,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ))
                                              .toList(),
                                        ),
                                        if (workout.exercises.length > 3)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4.0),
                                            child: Text(
                                              '... and ${workout.exercises.length - 3} more',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showWorkoutDetails(BuildContext context, WorkoutSession workout) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Workout Details - ${workout.startTime.toLocal().toString().split(' ')[0]}',
          style: TextStyle(color: Colors.green.shade800),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (workout.endTime != null) ...[
                Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.green.shade700, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Duration: ${workout.endTime!.difference(workout.startTime).inMinutes} minutes',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              Text(
                'Exercises:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: workout.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = workout.exercises[index];
                    return Card(
                      color: Colors.green.shade50,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...exercise.sets.asMap().entries.map((entry) {
                              final setIndex = entry.key;
                              final set = entry.value;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${setIndex + 1}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${set.weight}kg × ${set.reps} reps',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (set.isCompleted)
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green.shade600,
                                        size: 16,
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
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
            child: Text('Close', style: TextStyle(color: Colors.green.shade700)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _editWorkout(context, workout.id);
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

  void _editWorkout(BuildContext context, String workoutId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditWorkoutView(sessionId: workoutId),
      ),
    );
  }
}
