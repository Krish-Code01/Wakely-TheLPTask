import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lp_task/model/alarm_model.dart';
import 'package:lp_task/providers/alarm_provider.dart';
import 'package:lp_task/services/stop_alarm.dart';
import 'package:provider/provider.dart';

class ActiveAlarmPage extends StatefulWidget {
  AlarmSettings alarmSettings;
  ActiveAlarmPage({
    super.key,
    required this.alarmSettings,
  });

  @override
  State<ActiveAlarmPage> createState() => _AlarmNotificationScreenState();
}

class _AlarmNotificationScreenState extends State<ActiveAlarmPage> {
  @override
  Widget build(BuildContext context) {
    AlarmProvider _alarmProvider = Provider.of<AlarmProvider>(context);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              SizedBox(
                height: 20.w,
              ),
              Image.asset(
                'assets/image/logo/app_logo.png',
                height: 200.w,
              ),
              Text(
                widget.alarmSettings.notificationSettings.title,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                widget.alarmSettings.notificationSettings.body,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  final now = DateTime.now();
                  Alarm.set(
                    alarmSettings: widget.alarmSettings.copyWith(
                      dateTime: DateTime(
                        now.year,
                        now.month,
                        now.day,
                        now.hour,
                        now.minute,
                      ).add(
                        const Duration(minutes: 1),
                      ),
                    ),
                  ).then((_) => Navigator.pop(context));
                },
                child: Text(
                  "Snooze",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  AlarmModel alarm = _alarmProvider.alarms.firstWhere(
                    (alarm) => int.parse(alarm.id!) == widget.alarmSettings.id,
                  );
                  StartStopAlarm.stopAlarm(
                    alarm,
                    widget.alarmSettings,
                    _alarmProvider,
                  );
                  Alarm.stop(widget.alarmSettings.id).then(
                    (_) => Navigator.pop(context),
                  );
                },
                child: Text(
                  "Dismiss",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 202, 2, 2),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
