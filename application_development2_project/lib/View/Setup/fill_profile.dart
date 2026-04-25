import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/app_colors.dart';
import '../../Model/user.dart';
import '../../DAO/user_dao.dart';
import '../home/home_page.dart';

class FillProfilePage extends StatefulWidget {
  final User user;
  const FillProfilePage({super.key, required this.user});

  @override
  State<FillProfilePage> createState() => _FillProfilePageState();
}

class _FillProfilePageState extends State<FillProfilePage> {
  final _fullNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Pre-fill fields if data exists
    String firstName = widget.user.firstName ?? "";
    String lastName = widget.user.lastName ?? "";
    _fullNameController.text = (firstName.isNotEmpty || lastName.isNotEmpty) 
        ? "$firstName $lastName".trim() 
        : "";
    _nicknameController.text = widget.user.username;
    _emailController.text = widget.user.email ?? "";
    _phoneController.text = widget.user.phone ?? "";
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleStart() async {
    String fullName = _fullNameController.text.trim();
    List<String> nameParts = fullName.split(' ');
    
    widget.user.firstName = nameParts.isNotEmpty ? nameParts[0] : "";
    widget.user.lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : "";
    widget.user.username = _nicknameController.text.trim();
    widget.user.email = _emailController.text.trim();
    widget.user.phone = _phoneController.text.trim();

    try {
      UserDao userDao = UserDao();
      await userDao.updateUser(widget.user);
      
      // TODO: If you want to upload the image to Firebase Storage, do it here.

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving profile: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Back button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_left, color: kYellow, size: 30),
                        Text(
                          "Back",
                          style: TextStyle(
                            color: kYellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Fill Your Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: const Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              // Purple section for avatar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                color: kPurpleLight,
                child: Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _image != null 
                              ? FileImage(_image!) 
                              : const NetworkImage('https://via.placeholder.com/150') as ImageProvider,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: kYellow,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, color: Colors.black, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Form fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Full name"),
                    _buildTextField(_fullNameController, "Full name"),
                    const SizedBox(height: 15),
                    _buildLabel("Nickname"),
                    _buildTextField(_nicknameController, "Nickname"),
                    const SizedBox(height: 15),
                    _buildLabel("Email"),
                    _buildTextField(_emailController, "Email", keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 15),
                    _buildLabel("Mobile Number"),
                    _buildTextField(_phoneController, "Mobile Number", keyboardType: TextInputType.phone),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Start Button
              SizedBox(
                width: 200,
                height: 55,
                child: ElevatedButton(
                  onPressed: _handleStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kYellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Start",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(color: kPurple, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
