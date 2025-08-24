import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Timer state enum to track timer status
enum TimerState { running, paused, completed }

// Timer data class to hold timer information
class TimerData {
  final String id;
  final String name;
  final int originalDuration;
  int remainingTime;
  TimerState state;
  final DateTime createdAt;

  TimerData({
    required this.id,
    required this.name,
    required this.originalDuration,
    required this.remainingTime,
    this.state = TimerState.running,
    required this.createdAt,
  });
}

class RestTimerViewModel extends ChangeNotifier {
  final Map<String, Timer> _activeTimers = {};
  final Map<String, TimerData> _timerData = {};

  List<TimerData> get timers => _timerData.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Most recent first

  void startTimer(String name, int seconds) {
    final timerId = '${name}_${DateTime.now().millisecondsSinceEpoch}';

    final timerData = TimerData(
      id: timerId,
      name: name,
      originalDuration: seconds,
      remainingTime: seconds,
      createdAt: DateTime.now(),
    );

    _timerData[timerId] = timerData;

    _activeTimers[timerId] = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) {
      final data = _timerData[timerId]!;

      if (data.remainingTime > 0) {
        data.remainingTime--;
        notifyListeners();
      } else {
        // Timer completed - trigger alarm but don't delete
        data.state = TimerState.completed;
        _triggerAlarm(data);
        timer.cancel();
        _activeTimers.remove(timerId);
        notifyListeners();
      }
    });

    notifyListeners();
  }

  void pauseTimer(String timerId) {
    final data = _timerData[timerId];
    if (data != null && data.state == TimerState.running) {
      _activeTimers[timerId]?.cancel();
      _activeTimers.remove(timerId);
      data.state = TimerState.paused;
      notifyListeners();
    }
  }

  void resumeTimer(String timerId) {
    final data = _timerData[timerId];
    if (data != null &&
        data.state == TimerState.paused &&
        data.remainingTime > 0) {
      data.state = TimerState.running;

      _activeTimers[timerId] = Timer.periodic(const Duration(seconds: 1), (
        timer,
      ) {
        if (data.remainingTime > 0) {
          data.remainingTime--;
          notifyListeners();
        } else {
          // Timer completed - trigger alarm but don't delete
          data.state = TimerState.completed;
          _triggerAlarm(data);
          timer.cancel();
          _activeTimers.remove(timerId);
          notifyListeners();
        }
      });

      notifyListeners();
    }
  }

  void stopTimer(String timerId) {
    _activeTimers[timerId]?.cancel();
    _activeTimers.remove(timerId);
    _timerData.remove(timerId);
    notifyListeners();
  }

  void restartTimer(String timerId) {
    final data = _timerData[timerId];
    if (data != null) {
      // Stop current timer if running
      _activeTimers[timerId]?.cancel();
      _activeTimers.remove(timerId);

      // Reset to original duration
      data.remainingTime = data.originalDuration;
      data.state = TimerState.running;

      // Start new timer
      _activeTimers[timerId] = Timer.periodic(const Duration(seconds: 1), (
        timer,
      ) {
        if (data.remainingTime > 0) {
          data.remainingTime--;
          notifyListeners();
        } else {
          // Timer completed - trigger alarm but don't delete
          data.state = TimerState.completed;
          _triggerAlarm(data);
          timer.cancel();
          _activeTimers.remove(timerId);
          notifyListeners();
        }
      });

      notifyListeners();
    }
  }

  void _triggerAlarm(TimerData data) {
    // Trigger haptic feedback
    HapticFeedback.vibrate();

    // You could also play a sound here if desired
    // For now, we'll use system vibration as the alarm

    if (kDebugMode) {
      debugPrint(
      '⏰ TIMER COMPLETED: ${data.name} (${formatTime(data.originalDuration)})',
    );
    }
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Quick start methods for common timer durations
  void startQuickTimer(String name, int minutes) {
    startTimer(name, minutes * 60);
  }

  void start1MinTimer() => startQuickTimer('1 Min Rest', 1);
  void start3MinTimer() => startQuickTimer('3 Min Rest', 3);
  void start5MinTimer() => startQuickTimer('5 Min Rest', 5);

  @override
  void dispose() {
    for (var timer in _activeTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }
}
