import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global/constants/theme.dart';
import '../../providers/alarm_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/alarm_service.dart';
import '../active_alarm/active_alarm.dart';
import '../components/alarm_card.dart';
import '../components/clock.dart';
import '../settings/settings_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  late DateTime _currentTime;
  AlarmService _alarm = AlarmService();
  StreamSubscription<AlarmSettings>? subscription;
  List<AlarmSettings> _alarmSettingList = [];

  @override
  void initState() {
    super.initState();
    _alarm.initializeDatabase().then((value) {});
    _currentTime = DateTime.now();
    AlarmProvider alarmProvider =
        Provider.of<AlarmProvider>(context, listen: false);
    subscription ??= Alarm.ringStream.stream.listen(navigateToRingScreen);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      _startTimer();
      alarmProvider.loadAlarms('$userId');
      loadAlarms();
    });
  }

  void loadAlarms() async {
    _alarmSettingList = await Alarm.getAlarms();

    setState(() {
      _alarmSettingList.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    });
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ActiveAlarmPage(alarmSettings: alarmSettings),
      ),
    );
    loadAlarms();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    AlarmProvider alarmProvider =
        Provider.of<AlarmProvider>(context, listen: false);
    DateTime? nextAlarmTime =
        alarmProvider.getNextAlarmTime(alarmProvider.alarms);
    Duration timeUntilNextAlarm;
    String formattedTimeRemaining = "";
    if (nextAlarmTime != null) {
      timeUntilNextAlarm = nextAlarmTime.difference(DateTime.now());
      formattedTimeRemaining = alarmProvider.formatDuration(timeUntilNextAlarm);
    }

    return Scaffold(
      backgroundColor: CustomColors.pageBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: ClockView(),
            ),
            ListTile(
              title: nextAlarmTime == null
                  ? Text(
                      "No Upcoming Alarm",
                      style: TextStyle(
                        color: CustomColors.primaryTextColor,
                        fontSize: 20.sp,
                      ),
                    )
                  : Text(
                      "Next Alarm in $formattedTimeRemaining",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16.sp,
                      ),
                    ),
              subtitle: Text(
                "${DateFormat('HH:mm').format(DateTime.now())}  ${DateFormat('EEE').format(DateTime.now())}, ${DateFormat('dd MMM').format(DateTime.now())}",
                style: TextStyle(
                  color: CustomColors.primaryTextColor,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
                child: const Text(
                  "SETTINGS",
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ),
            const Divider(color: Colors.grey),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 0),
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: alarmProvider.alarms.length,
                    itemBuilder: (context, index) {
                      return AlarmCard(
                        alarm: alarmProvider.alarms[index],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
