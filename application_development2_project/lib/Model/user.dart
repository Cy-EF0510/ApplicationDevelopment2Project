import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../DAO/user_dao.dart';
import '../View/home/home_page.dart';

class User {
  String? _id;
  String _username;
  String? _email;
  String _password;
  String? _firstName;
  String? _lastName;
  String? _phone;
  Timestamp _createdOn;
  Timestamp? _dob;
  int? _age;
  String? _gender;

  User({
    String? id,
    required String username,
    String? email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    required Timestamp createdOn,
    Timestamp? dob,
    int? age,
    String? gender,
  })  : _id = id,
        _username = username,
        _email = email,
        _password = password,
        _firstName = firstName,
        _lastName = lastName,
        _phone = phone,
        _createdOn = createdOn,
        _dob = dob,
        _age = age,
        _gender = gender;

  // Setters and Getters
  String? get gender => _gender;
  set gender(String? value) => _gender = value;

  int? get age => _age;
  set age(int? value) => _age = value;

  Timestamp? get dob => _dob;
  set dob(Timestamp? value) => _dob = value;

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
      'dob': _dob,
      'age': _age,
      'gender': _gender,
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
      dob: map['dob'] is Timestamp ? map['dob'] : null,
      age: map['age'],
      gender: map['gender'],
    );
  }

  // Check if user exists in Firestore and navigate or show error
  static Future<void> checkUserAndNavigate(String identifier, String password, BuildContext context) async {
    UserDao userDao = UserDao();
    
    // Check by email first
    User? user = await userDao.getUserByEmail(identifier);
    
    // If not found by email, check by username
    if (user == null) {
      user = await userDao.getUserByUsername(identifier);
    }

    if (user != null && user.password == password) {
      // User exists and password is correct, navigate to HomeView
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      // User does not exist or password is incorrect, show generic error message
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
    Timestamp? newDob,
    int? newAge,
    String? newGender,
  }) {
    this.username = newUsername ?? username;
    this.email = newEmail ?? email;
    this.password = newPassword ?? password;
    this.firstName = newFName ?? firstName;
    this.lastName = newLName ?? lastName;
    this.phone = newPhone ?? phone;
    this.dob = newDob ?? dob;
    this.age = newAge ?? age;
    this.gender = newGender ?? gender;
  }
}
