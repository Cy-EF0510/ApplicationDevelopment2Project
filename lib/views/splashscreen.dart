import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'Auth/login_page.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/fitness.png', width: 100),
            const SizedBox(height: 24),
            const Text(
              'SoFit',
              style: TextStyle(
                fontFamily: 'Syne',
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: kYellow,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: kYellow),
            const SizedBox(height: 12),
            const Text('Loading', style: TextStyle(color: kYellow)),
          ],
        ),
      ),
    );
  }
}