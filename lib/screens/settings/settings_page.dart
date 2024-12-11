import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lp_task/global/constants/theme.dart';
import 'package:lp_task/screens/auth/auth_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/auth_provider.dart';
import '../components/add_alarm_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? userId;
  String? name;
  String? email;
  String? userPhotoUrl;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      setState(() {
        userId = prefs.getString('userId');
        name = prefs.getString('userName');
        userPhotoUrl = prefs.getString('userPhotoUrl');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: CustomColors.pageBackgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                SizedBox(
                  height: 30.w,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10000.h),
                  child: Image.network(
                    '$userPhotoUrl',
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/image/logo/app_logo.png',
                        height: 100.w,
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 20.w,
                ),
                Text(
                  '$name',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                SizedBox(
                  height: 10.w,
                ),
                AddAlarmCard(),
                SizedBox(
                  height: 10.w,
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (!authProvider.isLoading) {
                  await authProvider.signOut(context);
                }
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const AuthPage(),
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text("Sign Out"),
              style: ElevatedButton.styleFrom(
                iconColor: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
