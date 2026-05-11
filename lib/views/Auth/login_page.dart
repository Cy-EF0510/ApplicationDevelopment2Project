import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/app_colors.dart';
import 'register_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final Uri _url = Uri.parse(
      'https://www.youtube.com/watch?v=dQw4w9WgXcQ&list=RDdQw4w9WgXcQ&start_radio=1');

  Future<void> _launchYoutube() async {
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kBg,
          title: Text("Log In", style: TextStyle(color: kYellow)),
          centerTitle: true,
        ),
        backgroundColor: kBg,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Welcome',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24
                  ),
                ),
                SizedBox(height: 26,),
                Container(
                  width: double.infinity,
                  color: kPurpleDim,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text("Username or email"),
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(),
                              fillColor: Colors.white,
                              filled: true
                          ),
                        ),
                        SizedBox(height: 16),
                        Text("Password"),
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                              fillColor: Colors.white,
                              filled: true,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              )),
                          obscureText: _obscurePassword,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 26),
                SizedBox(
                  width: 250,
                  height: 49,
                  child: ElevatedButton(
                    onPressed: () {
                      User.checkUserAndNavigate(
                          _usernameController.text, _passwordController.text, context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPurpleDim,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16,),
                Text("or log in with", style: TextStyle(color: Colors.white),),
                SizedBox(height: 16,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(onPressed: _launchYoutube, icon: FaIcon(FontAwesomeIcons.google, color: Colors.amberAccent,)),
                    IconButton(onPressed: _launchYoutube, icon: FaIcon(FontAwesomeIcons.facebook, color: Colors.amberAccent,)),
                    IconButton(onPressed: _launchYoutube, icon: FaIcon(FontAwesomeIcons.twitter, color: Colors.amberAccent,))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?", style: TextStyle(color: Colors.white),),
                    TextButton(onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                    }, child: Text("Sign up", style: TextStyle(color: Colors.amberAccent),))
                  ],
                )
              ],
            ),
          ),
        )
    );
  }
}
