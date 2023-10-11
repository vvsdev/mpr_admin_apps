import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mpr_admin/screens/auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.teal[800],
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset(
              'assets/images/mpr_logo.png',
              height: 400,
              width: 400,
            ),
            SizedBox(height: MediaQuery.of(context).size.width / 2 - 10),
            Text(
              'Collaboration with',
              style: TextStyle(color: Colors.grey.shade300),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/sponsor_logo_transparent.png',
                  height: 70,
                  width: 70,
                ),
                Image.asset(
                  'assets/images/sponsor_logo_transparent_2.png',
                  height: 100,
                  width: 100,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
