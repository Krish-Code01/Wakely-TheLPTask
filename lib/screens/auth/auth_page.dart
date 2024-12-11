import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lp_task/global/constants/theme.dart';
import 'package:lp_task/providers/auth_provider.dart';
import 'package:lp_task/screens/home/home_page.dart';
import 'package:provider/provider.dart';
import '../components/square-tiles.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: CustomColors.pageBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/image/logo/app_logo.png',
              height: 200.w,
            ),
            SizedBox(height: 20.w),
            Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: CustomColors.primaryTextColor,
              ),
            ),
            SizedBox(height: 40.w),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return GestureDetector(
                  onTap: () async {
                    await authProvider.signInWithGoogle(context);
                    if (authProvider.isLogin) {
                      Future.delayed(Duration.zero, () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ),
                        );
                      });
                    }
                  },
                  child: authProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const SquareTile(
                          imagePath: 'assets/image/icons/google.png',
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
