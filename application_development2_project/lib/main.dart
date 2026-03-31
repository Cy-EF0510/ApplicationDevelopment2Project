import 'package:flutter/material.dart';
import 'package:application_development2_project/View/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: SoFitApp(),
      home: SplashScreenPage(),
    );
  }
}

// class SoFitApp extends StatefulWidget {
//   const SoFitApp({super.key});
//
//   @override
//   State<SoFitApp> createState() => _SoFitAppState();
// }
//
// class _SoFitAppState extends State<SoFitApp> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Image.asset(""),
//       ),
//     );
//   }
// }
