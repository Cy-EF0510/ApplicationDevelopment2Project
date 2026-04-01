import 'package:splashscreen/splashscreen.dart';
import 'package:application_development2_project/View/login_view.dart';
import 'package:flutter/material.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  //create a variable for the default selected interface
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
        seconds: 3,
        navigateAfterSeconds: LoginPage(),
        title: Text('Welcome Habibi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
        backgroundColor: Colors.black12,
        styleTextUnderTheLoader: TextStyle(),
        image: Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Osu%21_Logo_2016.svg/960px-Osu%21_Logo_2016.svg.png?_=20220131190058'),
        photoSize: 100,
        loaderColor: Colors.white,
        loadingText: Text('Hey Welcome'),
        loadingTextPadding: EdgeInsets.zero,
        useLoader: true
    );
  }
}

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   //create a variable for the default selected interface
//   @override
//   Widget build(BuildContext context) {
//     return SplashScreen(
//         seconds: 6,
//         navigateAfterSeconds: AfterSplashScreen(),
//         title: Text('Welcome Habibi',
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
//         backgroundColor: Colors.black12,
//         styleTextUnderTheLoader: TextStyle(),
//         image: Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Osu%21_Logo_2016.svg/960px-Osu%21_Logo_2016.svg.png?_=20220131190058'),
//         photoSize: 100,
//         loaderColor: Colors.white,
//         loadingText: Text('Hey Welcome'),
//         loadingTextPadding: EdgeInsets.zero,
//         useLoader: true
//     );
//   }
// }




// @override
// void initState() {
//   // TODO: implement initState
//   super.initState();
//   // TODO: Splash Logic
//   _timer = Timer(Duration(seconds: 3), (){
//     // TODO: Navigate
//     Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
//   });