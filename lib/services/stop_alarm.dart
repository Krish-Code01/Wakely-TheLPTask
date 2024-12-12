import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:lp_task/model/alarm_model.dart';
import 'package:lp_task/providers/alarm_provider.dart';

class StartStopAlarm {
  static Future<void> stopAlarm(AlarmModel alarm, AlarmSettings alarmSettings,
      AlarmProvider alarmProvider) async {
    if (alarm.repeatOption == RepeatOption.noRepeat) {
      AlarmModel updatedModel = AlarmModel(
        id: alarm.id,
        userId: alarm.userId,
        alarmDateTime: alarm.alarmDateTime,
        label: alarm.label,
        isActive: false,
        customRepeatDays: alarm.customRepeatDays,
      );

      alarmProvider.updateAlarm(updatedModel);
    } else if (alarm.repeatOption == RepeatOption.daily) {
      final newAlarm = AlarmSettings(
        id: alarmSettings.id,
        dateTime: alarmSettings.dateTime.add(Duration(days: 1)),
        assetAudioPath: alarmSettings.assetAudioPath,
        loopAudio: true,
        vibrate: true,
        warningNotificationOnKill: Platform.isIOS,
        androidFullScreenIntent: true,
        notificationSettings: NotificationSettings(
          title: alarmSettings.notificationSettings.title,
          body: "Hey! It's time to wake",
          stopButton: "Stop",
          icon: 'assets/image/logo/app_logo.png',
        ),
      );

      await Alarm.set(alarmSettings: newAlarm);
    } else {
      List<int>? listDays = alarm.customRepeatDays;
      int todayIndex = (DateTime.now().weekday % 7);
      int _remainingDays = 0;
      for (int i = 0; i < 7; i++) {
        int checkIndex = (todayIndex + i) % 7;
        if (listDays[checkIndex] == 1) {
          _remainingDays = i;
          break;
        }
      }

      final newAlarm = AlarmSettings(
        id: alarmSettings.id,
        dateTime: alarmSettings.dateTime.add(
          Duration(days: _remainingDays),
        ),
        assetAudioPath: alarmSettings.assetAudioPath,
        loopAudio: true,
        vibrate: true,
        warningNotificationOnKill: Platform.isIOS,
        androidFullScreenIntent: true,
        notificationSettings: NotificationSettings(
          title: alarmSettings.notificationSettings.title,
          body: "Hey! It's time to wake",
          stopButton: "Stop",
          icon: 'assets/image/logo/app_logo.png',
        ),
      );
      await Alarm.set(alarmSettings: newAlarm);
    }
  }

  static Future<void> permanentStop(AlarmModel alarm) async {
    await Alarm.stop(int.parse(alarm.id!));
  }
}
