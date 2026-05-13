import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';
import '../../controllers/userController.dart';
import '../profile/setup/gender.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});


  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _redoPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureRedoPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _redoPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final String username = _usernameController.text.trim();
    final String emailOrPhone = _emailController.text.trim();
    final String password = _passwordController.text;
    final String redoPassword = _redoPasswordController.text;

    if (username.isEmpty || emailOrPhone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields"), backgroundColor: Colors.red),
      );
      return;
    }

    if (password != redoPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match"), backgroundColor: Colors.red),
      );
      return;
    }

    String? email;
    String? phone;
    if (emailOrPhone.contains('@')) {
      email = emailOrPhone;
    } else {
      phone = emailOrPhone;
    }

    // Firebase Auth requires an email — if they entered a phone, block it for now
    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please use an email to register"), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      UserDao userDao = UserDao();

      // Check if username already taken in Firestore
      User? existingUser = await userDao.getUserByUsername(username);
      if (existingUser != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Username already taken"), backgroundColor: Colors.red),
        );
        return;
      }

      // Register with Firebase Auth — this handles email uniqueness too
      final credential = await auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create user in Firestore using the Auth uid as the document ID
      User newUser = User(
        id: credential.user!.uid,
        username: username,
        email: email,
        phone: phone,
        password: password,
        createdOn: Timestamp.now(),
      );

      await userDao.createUserWithId(newUser, credential.user!.uid);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GenderSelectionPage(user: newUser),
          ),
        );
      }
    } on auth.FirebaseAuthException catch (e) {
      String message = switch (e.code) {
        'email-already-in-use' => 'Email already in use',
        'weak-password' => 'Password must be at least 6 characters',
        'invalid-email' => 'Invalid email address',
        _ => 'Registration failed: ${e.message}',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kBg,
          title: Text("Sign Up", style: TextStyle(color: kYellow)),
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
                        Text("Username"),
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
                        Text("Email/Phone Number"),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                              labelText: 'Email/Phone Number',
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
                            ),
                          ),
                          obscureText: _obscurePassword,
                        ),
                        SizedBox(height: 16),
                        Text("Redo Password"),
                        TextField(
                          controller: _redoPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Redo Password',
                            border: OutlineInputBorder(),
                            fillColor: Colors.white,
                            filled: true,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureRedoPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureRedoPassword = !_obscureRedoPassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscureRedoPassword,
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
                    onPressed: _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPurpleDim,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Sign Up',
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
                    IconButton(onPressed: (){}, icon: FaIcon(FontAwesomeIcons.google, color: Colors.amberAccent,)),
                    IconButton(onPressed: (){}, icon: FaIcon(FontAwesomeIcons.facebook, color: Colors.amberAccent,)),
                    IconButton(onPressed: (){}, icon: FaIcon(FontAwesomeIcons.twitter, color: Colors.amberAccent,))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?", style: TextStyle(color: Colors.white),),
                    TextButton(onPressed: (){
                      Navigator.pop(context);
                    }, child: Text("Log In", style: TextStyle(color: Colors.amberAccent),))
                  ],
                )
              ],
            ),
          ),
        )
    );
  }
}
