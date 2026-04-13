import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'screens/home/home_page.dart';
import 'screens/profile/profile_page.dart';

void main() {
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitness App',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kBg,
      ),
      home: const HomePage(),
      routes: {
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}