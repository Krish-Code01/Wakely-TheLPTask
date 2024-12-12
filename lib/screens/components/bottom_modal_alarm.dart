import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lp_task/global/constants/theme.dart';
import 'package:lp_task/model/alarm_model.dart';
import 'package:lp_task/providers/alarm_provider.dart';
import 'package:lp_task/services/alarm_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showAlarmModalSheet(BuildContext context, AlarmService alarm) {
  String selectedLabel = '';
  bool isCustomRepeat = false;
  bool isDaily = false;
  bool isNoRepeat = true;
  String repeatValue = "noRepeat";
  List<int> selectedDays = List.filled(7, 0);
  TimeOfDay selectedTime = TimeOfDay.now();

  showModalBottomSheet(
    backgroundColor: CustomColors.pageBackgroundColor,
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        selectedTime = time;
                      });
                    }
                  },
                  child: Text(
                    "${selectedTime!.format(context)}",
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: CustomColors.primaryTextColor,
                      decoration: TextDecoration.underline,
                      decorationColor: CustomColors.primaryTextColor,
                      decorationStyle: TextDecorationStyle.double,
                    ),
                  ),
                ),
                SizedBox(height: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RadioListTile(
                      title: Text(
                        "No Repeat",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: CustomColors.primaryTextColor,
                        ),
                      ),
                      value: "noRepeat",
                      groupValue: isCustomRepeat
                          ? 'custom'
                          : isDaily
                              ? 'daily'
                              : 'noRepeat',
                      onChanged: (value) {
                        setState(() {
                          isCustomRepeat = false;
                          isNoRepeat = true;
                          isDaily = false;
                          repeatValue = value ?? "noRepeat";
                          selectedDays = [0, 0, 0, 0, 0, 0, 0];
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text(
                        "Daily",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: CustomColors.primaryTextColor,
                        ),
                      ),
                      value: "daily",
                      groupValue: isCustomRepeat
                          ? 'custom'
                          : isDaily
                              ? 'daily'
                              : 'noRepeat',
                      onChanged: (value) {
                        setState(() {
                          selectedDays = [1, 1, 1, 1, 1, 1, 1];
                          isCustomRepeat = false;
                          isNoRepeat = false;
                          isDaily = true;
                          repeatValue = value ?? "daily";
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text(
                        "Custom Repeat",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: CustomColors.primaryTextColor,
                          fontSize: 16.sp,
                        ),
                      ),
                      value: "custom",
                      groupValue: isCustomRepeat
                          ? 'custom'
                          : isDaily
                              ? 'daily'
                              : 'noRepeat',
                      onChanged: (value) {
                        setState(
                          () {
                            isCustomRepeat = true;
                            isNoRepeat = false;
                            isDaily = false;
                            repeatValue = value ?? "custom";
                          },
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.w,
                ),
                if (isCustomRepeat)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      7,
                      (index) {
                        String day = ["S", "M", "T", "W", "T", "F", "S"][index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDays[index] = 1 - selectedDays[index];
                            });
                          },
                          child: Container(
                            height: 25.w,
                            width: 25.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selectedDays[index] == 1
                                  ? const Color.fromARGB(255, 0, 140, 255)
                                  : Colors.grey[300],
                            ),
                            child: Center(
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: selectedDays[index] == 1
                                      ? CustomColors.primaryTextColor
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                SizedBox(height: 16.w),
                TextField(
                  onChanged: (text) {
                    setState(() {
                      selectedLabel = text;
                    });
                  },
                  maxLength: 20,
                  style: TextStyle(
                    color: CustomColors.primaryTextColor,
                  ),
                  cursorColor: CustomColors.primaryTextColor,
                  decoration: InputDecoration(
                    labelText: "Alarm Label",
                    labelStyle: TextStyle(
                      color: CustomColors.primaryTextColor,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: CustomColors.primaryTextColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: CustomColors.primaryTextColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: CustomColors.primaryTextColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.w),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: CustomColors.primaryTextColor,
                        ),
                      ),
                    ),
                    Consumer<AlarmProvider>(
                      builder: (context, alarmProvider, child) {
                        return ElevatedButton(
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String? userId = prefs.getString('userId');

                            RepeatOption repeatOption =
                                RepeatOption.values.firstWhere(
                              (e) =>
                                  e.toString().split('.').last == repeatValue,
                              orElse: () => RepeatOption.noRepeat,
                            );

                            DateTime now = DateTime.now();
                            DateTime selectedDateTime = DateTime(
                              now.year,
                              now.month,
                              now.day,
                              selectedTime.hour,
                              selectedTime.minute,
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
                                if (selectedDays[checkIndex] == 1) {
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
                                _remainingDays += 1;
                              }
                              selectedDateTime = selectedDateTime.add(
                                Duration(
                                  days: _remainingDays,
                                ),
                              );
                            }

                            int newId = 1;
                            if (alarmProvider.alarms.isNotEmpty) {
                              var lastAlarm = alarmProvider.alarms.last;
                              newId = int.parse(lastAlarm.id!) + 1;
                              print("ID of the last alarm: ${lastAlarm.id}");
                            } else {
                              print("No alarms available.");
                            }

                            final alarmSettings = AlarmSettings(
                              id: newId,
                              dateTime: selectedDateTime,
                              assetAudioPath: 'assets/ringtone/alarm_sound.wav',
                              loopAudio: true,
                              vibrate: true,
                              warningNotificationOnKill: Platform.isIOS,
                              androidFullScreenIntent: true,
                              notificationSettings: NotificationSettings(
                                title: selectedLabel,
                                body: "Hey! It's time to wake",
                                stopButton: "Stop",
                                icon: 'assets/image/logo/app_logo.png',
                              ),
                            );
                            await Alarm.set(alarmSettings: alarmSettings);

                            alarmProvider.addAlarm(
                              AlarmModel(
                                id: newId.toString(),
                                userId: '$userId',
                                alarmDateTime: selectedDateTime,
                                label: selectedLabel,
                                isActive: true,
                                repeatOption: repeatOption,
                                customRepeatDays: selectedDays,
                              ),
                            );

                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Save",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
