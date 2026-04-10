class User{
  int? _id;
  String _username;
  String _email;
  String _password;
  String _firstName;
  String _lastName;
  DateTime _createdOn;
  DateTime _dob;
  int _age;
  String _gender;

  User({
    required int id,
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime createdOn,
    required DateTime dob,
    required int age,
    required String gender
  }):
      _id = id,
      _username = username,
      _email = email,
      _password = password,
      _firstName = firstName,
      _lastName = lastName,
      _createdOn = createdOn,
      _dob = dob,
      _age = age,
      _gender = gender
  ;

  //Setters and Getters
  String get gender => _gender;

  set gender(String value) {
    _gender = value;
  }

  int get age => _age;

  set age(int value) {
    _age = value;
  }

  DateTime get dob => _dob;

  set dob(DateTime value) {
    _dob = value;
  }

  DateTime get createdOn => _createdOn;

  String get lastName => _lastName;

  set lastName(String value) {
    _lastName = value;
  }

  String get firstName => _firstName;

  set firstName(String value) {
    _firstName = value;
  }

  String get password => _password;

  set password(String value) {
    _password = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get username => _username;

  set username(String value) {
    _username = value;
  }

  int? get id => _id;

  //Functions

  updateProfile({
    String? newUsername,
    String? newEmail,
    String? newPassword,
    String? newFName,
    String? newLName,
    DateTime? newDob,
    String? newGender,
  }){
    this.username = newUsername ?? username;
    this.email = newEmail ?? email;
    this.password = newPassword ?? password;
    this.firstName = newFName ?? firstName;
    this.lastName = newLName ?? lastName;
    this.dob = newDob ?? dob;
    this.gender = newGender ?? gender;
  }
}
