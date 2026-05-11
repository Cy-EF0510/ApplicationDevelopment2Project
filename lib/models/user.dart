import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../controllers/userController.dart';
import '../../views/home/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class User {
  String? _id;
  String _username;
  String? _email;
  String _password;
  String? _firstName;
  String? _lastName;
  String? _phone;
  Timestamp _createdOn;
  int? _age;
  String? _gender;
  double? _weight;
  double? _height;

  User({
    String? id,
    required String username,
    String? email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    required Timestamp createdOn,
    int? age,
    String? gender,
    double? weight,
    double? height,
  })  : _id = id,
        _username = username,
        _email = email,
        _password = password,
        _firstName = firstName,
        _lastName = lastName,
        _phone = phone,
        _createdOn = createdOn,
        _age = age,
        _gender = gender,
        _weight = weight,
        _height = height;

  // Setters and Getters
  String? get gender => _gender;
  set gender(String? value) => _gender = value;

  int? get age => _age;
  set age(int? value) => _age = value;

  Timestamp get createdOn => _createdOn;

  String? get lastName => _lastName;
  set lastName(String? value) => _lastName = value;

  String? get firstName => _firstName;
  set firstName(String? value) => _firstName = value;

  String? get phone => _phone;
  set phone(String? value) => _phone = value;

  String get password => _password;
  set password(String value) => _password = value;

  String? get email => _email;
  set email(String? value) => _email = value;

  String get username => _username;
  set username(String value) => _username = value;

  String? get id => _id;
  set id(String? value) => _id = value;

  double? get weight => _weight;
  set weight(double? value) => _weight = value;

  double? get height => _height;
  set height(double? value) => _height = value;

  // Conversion methods for Firestore
  Map<String, dynamic> toMap() {
    return {
      'username': _username,
      'email': _email,
      'password': _password,
      'firstName': _firstName,
      'lastName': _lastName,
      'phone': _phone,
      'createdOn': _createdOn,
      'age': _age,
      'gender': _gender,
      'weight': _weight,
      'height': _height,
    };
  }

  factory User.fromMap(Map<String, dynamic> map, String documentId) {
    return User(
      id: documentId,
      username: map['username'] ?? '',
      email: map['email'],
      password: map['password'] ?? '',
      firstName: map['firstName'],
      lastName: map['lastName'],
      phone: map['phone'],
      createdOn: map['createdOn'] is Timestamp ? map['createdOn'] : Timestamp.now(),
      age: map['age'],
      gender: map['gender'],
      weight: (map['weight'] as num?)?.toDouble(),
      height: (map['height'] as num?)?.toDouble(),
    );
  }

  static Future<void> checkUserAndNavigate(String identifier, String password, BuildContext context) async {
    UserDao userDao = UserDao();

    User? user = await userDao.getUserByEmail(identifier);
    if (user == null) {
      user = await userDao.getUserByUsername(identifier);
    }

    if (user != null && user.password == password) {
      try {
        // sign into Firebase Auth so currentUser is set
        await auth.FirebaseAuth.instance.signInWithEmailAndPassword(
          email: user.email!,
          password: password,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Auth error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Either username/email or password is incorrect.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Functions
  updateProfile({
    String? newUsername,
    String? newEmail,
    String? newPassword,
    String? newFName,
    String? newLName,
    String? newPhone,
    int? newAge,
    String? newGender,
    double? newWeight,
    double? newHeight,
  }) {
    this.username = newUsername ?? username;
    this.email = newEmail ?? email;
    this.password = newPassword ?? password;
    this.firstName = newFName ?? firstName;
    this.lastName = newLName ?? lastName;
    this.phone = newPhone ?? phone;
    this.age = newAge ?? age;
    this.gender = newGender ?? gender;
    this.weight = newWeight ?? weight;
    this.height = newHeight ?? height;
  }
}