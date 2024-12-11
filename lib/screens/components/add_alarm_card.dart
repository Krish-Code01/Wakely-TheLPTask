import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lp_task/global/constants/theme.dart';
import 'package:lp_task/services/stop_alarm.dart';

import '../../services/alarm_service.dart';
import 'bottom_modal_alarm.dart';

class AddAlarmCard extends StatelessWidget {
  AddAlarmCard({Key? key}) : super(key: key);

  AlarmService _alarm = AlarmService();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      child: GestureDetector(
        onTap: () {
          showAlarmModalSheet(
            context,
            _alarm,
          );
        },
        child: DottedBorder(
          strokeWidth: 1,
          color: CustomColors.primaryTextColor,
          borderType: BorderType.RRect,
          radius: Radius.circular(20.w),
          dashPattern: [5, 4],
          child: Container(
            height: 100.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: GradientColors.sky),
              borderRadius: BorderRadius.circular(20.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Alarm',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: CustomColors.primaryTextColor,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: IconButton(
                      onPressed: () {
                        showAlarmModalSheet(
                          context,
                          _alarm,
                        );
                      },
                      icon: Icon(
                        Icons.add,
                        color:
                            CustomColors.primaryTextColor, // White icon color
                        size: 24.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
