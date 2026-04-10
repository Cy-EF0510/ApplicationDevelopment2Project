import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text("Log In", style: TextStyle(color: Colors.amberAccent)),
        centerTitle: true,
      ),
      backgroundColor: Colors.black87,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Welcome',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 26),
            Container(
              width: double.infinity,
              color: Colors.deepPurpleAccent,
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
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true
                      ),
                      obscureText: true,
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
                  //TODO Handle Login
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
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
            Text("or sign up with"),
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
                Text("Don't have an account?", style: TextStyle(color: Colors.white),),
                TextButton(onPressed: (){}, child: Text("Sign up", style: TextStyle(color: Colors.amberAccent),))
              ],
            )
          ],
        ),
      ),
      // body: Center(
      //   child: Form(
      //     key: _formKey,
      //     child: Column(
      //       children: [
      //         TextFormField(
      //           inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
      //           keyboardType: TextInputType.text,
      //           textAlign: TextAlign.center,
      //           decoration: InputDecoration(
      //             hintText: 'Username',
      //             labelText: 'Username'
      //           ),
      //           validator: (value){
      //             if(value == null || value.isEmpty) {
      //               return 'Please fill in fields';
      //             }
      //             return null;
      //           },
      //           //TODO: Just decoration for the forms
      //           // decoration: InputDecoration(
      //           //   enabledBorder: OutlineInputBorder(
      //           //       borderSide:BorderSide(color: Colors.blueGrey, width: 2.0)),
      //           //   border: OutlineInputBorder(borderSide: BorderSide()),
      //           //   fillColor: Colors.white,
      //           //   filled: true,
      //           //   prefixIcon: Icon(Icons.account_box_outlined),
      //           //   suffixIcon: Icon(Icons.check_box_outlined),
      //           //   hintText: 'John Doe',
      //           //   labelText: 'Name',
      //           // ),
      //         ),
      //         SizedBox(height: 10,),
      //         TextFormField(
      //           controller: _passwordController,
      //           textAlign: TextAlign.center,
      //           decoration: InputDecoration(
      //             hintText: 'Password',
      //             labelText: 'Password',
      //           ),
      //           validator: (value){
      //             if(value == null || value.isEmpty) {
      //               return 'Please fill in fields';
      //             }
      //             return null;
      //           },
      //         ),
      //         SizedBox(height: 10,),
      //         ElevatedButton(
      //             onPressed: (){
      //               if(_formKey.currentState!.validate()){
      //                 // TODO: Redirect to the main page or something
      //               } else{
      //                 // TODO: The form has some validation errors
      //                 // TODO: Do something
      //               }
      //             },
      //             child: Text('Submit')
      //         ),
      //       ],
      //     ),
      //   )
      // ),
    );
  }

  // InputDecoration inputDecoration({
  //   InputBorder? enabledBorder,
  //   InputBorder? border,
  //   Color? fillColor,
  //   bool? filled,
  //   Widget? prefixIcon,
  //   String? hintText,
  //   String? labelText,
  // }) =>
  //     InputDecoration(
  //       enabledBorder: enabledBorder ??
  //       OutlineInputBorder(
  //         borderSide: BorderSide(color: Colors.lime, width: 2.0)),
  //       border: border ?? OutlineInputBorder(borderSide: BorderSide()),
  //       fillColor: fillColor ?? Colors.white,
  //       filled: filled ?? true,
  //       prefixIcon: prefixIcon,
  //       hintText: hintText,
  //       labelText: labelText,
  //     );
}
