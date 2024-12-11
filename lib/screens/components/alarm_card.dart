import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lp_task/global/constants/theme.dart';
import 'package:lp_task/providers/alarm_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/alarm_model.dart';

class AlarmCard extends StatefulWidget {
  final AlarmModel alarm;

  const AlarmCard({Key? key, required this.alarm}) : super(key: key);

  @override
  State<AlarmCard> createState() => _AlarmCardState();
}

class _AlarmCardState extends State<AlarmCard> {
  bool isActive = false;
  @override
  Widget build(BuildContext context) {
    String repeatText;
    if (widget.alarm.repeatOption == RepeatOption.noRepeat) {
      repeatText = "No Repeat";
    } else if (widget.alarm.repeatOption == RepeatOption.daily) {
      repeatText = "Daily";
    } else {
      repeatText =
          "Custom: ${widget.alarm.customRepeatDays?.map((day) => DateFormat('EEE').format(DateTime(2024, 1, day + 1))).join(', ') ?? ""}";
    }
    bool isActive = widget.alarm.isActive;
    AlarmProvider alarmProvider = Provider.of<AlarmProvider>(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.w),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isActive
                ? GradientColors.dusk
                : [Colors.grey.shade800, Colors.grey.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10.w,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: widget.alarm.customRepeatDays
                                .every((day) => day == 0)
                            ? [
                                Text(
                                  "NO REPEAT",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: CustomColors.primaryTextColor,
                                  ),
                                ),
                              ]
                            : [
                                ...["S", "M", "T", "W", "T", "F", "S"]
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  String day = entry.value;
                                  return Text(
                                    "$day ",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: widget.alarm
                                                  .customRepeatDays[index] ==
                                              1
                                          ? CustomColors.primaryTextColor
                                          : Colors.grey,
                                    ),
                                  );
                                }).toList(),
                              ],
                      ),
                      Text(
                        DateFormat('hh:mm a')
                            .format(widget.alarm.alarmDateTime),
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w600,
                          color: CustomColors.primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: widget.alarm.isActive,
                    onChanged: (value) async {
                      if (value == false) {
                        await Alarm.stop(int.parse(widget.alarm.id!));
                      } else {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        RepeatOption repeatOption = widget.alarm.repeatOption;
                        DateTime now = DateTime.now();
                        DateTime selectedDateTime = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          widget.alarm.alarmDateTime.hour,
                          widget.alarm.alarmDateTime.minute,
                        );
                        int _remainingDays = 0;
                        if (repeatOption == RepeatOption.custom) {
                          int todayIndex = (now.weekday % 7);
                          if (selectedDateTime.isBefore(now)) {
                            todayIndex += 1;
                          }
                          _remainingDays = 0;
                          for (int i = 0; i < 7; i++) {
                            int checkIndex = (todayIndex + i) % 7;
                            if (widget.alarm.customRepeatDays[checkIndex] ==
                                1) {
                              _remainingDays = i;
                              break;
                            }
                          }
                          if (selectedDateTime.isBefore(now)) {
                            _remainingDays += 1;
                          }
                          selectedDateTime = selectedDateTime.add(
                            Duration(
                              days: _remainingDays,
                            ),
                          );
                        } else {
                          if (selectedDateTime.isBefore(now)) {
                            selectedDateTime = selectedDateTime.add(
                              const Duration(
                                days: 1,
                              ),
                            );
                          }
                        }

                        final alarmSettings = AlarmSettings(
                          id: int.parse(widget.alarm.id!),
                          dateTime: selectedDateTime,
                          assetAudioPath: 'assets/ringtone/alarm_sound.wav',
                          loopAudio: true,
                          vibrate: true,
                          warningNotificationOnKill: Platform.isIOS,
                          androidFullScreenIntent: true,
                          notificationSettings: NotificationSettings(
                            title: widget.alarm.label,
                            body: "Hey! It's time to wake",
                            stopButton: "Stop",
                            icon: 'assets/image/logo/app_logo.png',
                          ),
                        );
                        await Alarm.set(alarmSettings: alarmSettings);
                      }
                      AlarmModel updatedModel = AlarmModel(
                        id: widget.alarm.id,
                        userId: widget.alarm.userId,
                        alarmDateTime: widget.alarm.alarmDateTime,
                        label: widget.alarm.label,
                        isActive: value,
                        customRepeatDays: widget.alarm.customRepeatDays,
                      );
                      alarmProvider.updateAlarm(updatedModel);
                      setState(() {});
                    },
                    activeColor: CustomColors.primaryTextColor,
                  ),
                ],
              ),
              SizedBox(height: 10.w),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Ensure spacing
                children: [
                  widget.alarm.label != ''
                      ? Text(
                          widget.alarm.label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: CustomColors.primaryTextColor,
                          ),
                        )
                      : const SizedBox(),
                  GestureDetector(
                    onTap: () {
                      alarmProvider.deleteAlarm(int.parse(widget.alarm.id!));

                      setState(() {});
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.delete_outlined,
                          color: CustomColors.primaryTextColor,
                          size: 30,
                        ),
                        SizedBox(
                          width: 8.w,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
