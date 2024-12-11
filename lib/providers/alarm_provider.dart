import 'dart:developer';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:lp_task/model/alarm_model.dart';

import '../services/alarm_service.dart';

class AlarmProvider with ChangeNotifier {
  List<AlarmModel> _alarms = [];

  List<AlarmModel> get alarms => _alarms;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final AlarmService _alarmService = AlarmService();

  Future<void> loadAlarms(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _alarms = await _alarmService.getAlarmsForUser(userId);
    } catch (e) {
      print("Error loading alarms: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAlarm(AlarmModel alarmInfo) async {
    try {
      _alarmService.insertAlarm(alarmInfo);
      _alarms.add(alarmInfo);
      notifyListeners();
    } catch (e) {
      print("Error adding alarm: $e");
    }
  }

  Future<void> updateAlarm(AlarmModel alarmInfo) async {
    try {
      int index = _alarms.indexWhere((alarm) => alarm.id == alarmInfo.id);
      if (index != -1) {
        _alarms[index] = alarmInfo;
      }
      await _alarmService.updateAlarm(alarmInfo);
      notifyListeners();
    } catch (e) {
      print("Error updating alarm: $e");
    }
  }

  Future<void> deleteAlarm(int id) async {
    try {
      await _alarmService.delete(id);
      _alarms.removeWhere((alarm) => alarm.id == id.toString());
      await Alarm.stop(id);
      notifyListeners();
    } catch (e) {
      print("Error deleting alarm: $e");
    }
  }

  DateTime? getNextAlarmTime(List<AlarmModel> alarms) {
    DateTime now = DateTime.now();
    DateTime? nextAlarm;
    for (var alarm in alarms) {
      if (alarm.isActive) {
        DateTime alarmTime = alarm.alarmDateTime;
        if (alarm.repeatOption == RepeatOption.noRepeat) {
          if (alarmTime.isAfter(now)) {
            if (nextAlarm == null || alarmTime.isBefore(nextAlarm)) {
              nextAlarm = alarmTime;
            }
          } else {
            alarmTime = alarmTime.add(const Duration(days: 1));
            if (nextAlarm == null || alarmTime.isBefore(nextAlarm)) {
              nextAlarm = alarmTime;
            }
          }
        } else if (alarm.repeatOption == RepeatOption.daily) {
          if (alarmTime.isBefore(now)) {
            alarmTime = alarmTime.add(const Duration(days: 1));
          }
          if (alarmTime.isAfter(now) &&
              (nextAlarm == null || alarmTime.isBefore(nextAlarm))) {
            nextAlarm = alarmTime;
          }
        } else if (alarm.repeatOption == RepeatOption.custom) {
          DateTime nextCustomAlarm = getNextCustomAlarmTime(alarm);
          if (nextCustomAlarm.isAfter(now) &&
              (nextAlarm == null || nextCustomAlarm.isBefore(nextAlarm))) {
            nextAlarm = nextCustomAlarm;
          }
        }
      }
    }
    return nextAlarm;
  }

  DateTime getNextCustomAlarmTime(AlarmModel alarm) {
    DateTime now = DateTime.now();
    int todayIndex = now.weekday - 1;
    DateTime nextCustomAlarm = alarm.alarmDateTime;
    for (int i = 0; i < 7; i++) {
      int dayIndex = (todayIndex + i) % 7;
      if (alarm.customRepeatDays[dayIndex] == 1) {
        nextCustomAlarm = nextCustomAlarm.add(Duration(days: i));
        break;
      }
    }
    nextCustomAlarm = DateTime(
      nextCustomAlarm.year,
      nextCustomAlarm.month,
      nextCustomAlarm.day,
      alarm.alarmDateTime.hour,
      alarm.alarmDateTime.minute,
    );
    return nextCustomAlarm;
  }

  String formatDuration(Duration duration) {
    if (duration.isNegative) {
      return "In the past";
    }
    return "${duration.inHours}h ${duration.inMinutes % 60}m";
  }
}
