import 'package:flutter/material.dart';
import 'package:application_development2_project/View/splashscreen_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// DAO and Model connection imports
import 'DAO/user_dao.dart';
import 'Model/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (Firestore)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    // (
    //     apiKey: 'AIzaSyDg9Yl56a_AEfkfPPX5valFNWcIuCqxnBY',
    //     appId: '1:728947567594:android:31c86af73194dbccb8a093',
    //     messagingSenderId: '728947567594',
    //     projectId: 'sofit-b754c'
    //
    // ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SoFit App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
      ),
      home: SplashScreenPage(),
    );
  }
}
