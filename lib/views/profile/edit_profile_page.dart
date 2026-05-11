import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../constants/app_colors.dart';
import '../../widgets/bottom_nav.dart';
import '../../models/user.dart';
import '../../controllers/userController.dart';

class EditProfilePage extends StatefulWidget {
  final User? user;
  const EditProfilePage({super.key, this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  
  String? _selectedGender;
  bool _isLoading = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _firstNameController = TextEditingController(text: _currentUser?.firstName ?? '');
    _lastNameController = TextEditingController(text: _currentUser?.lastName ?? '');
    _emailController = TextEditingController(text: _currentUser?.email ?? '');
    _phoneController = TextEditingController(text: _currentUser?.phone ?? '');
    _weightController = TextEditingController(text: _currentUser?.weight?.toString() ?? '');
    _heightController = TextEditingController(text: _currentUser?.height?.toString() ?? '');
    _selectedGender = _currentUser?.gender ?? 'Male';

    if (_currentUser == null) {
      _fetchUserData();
    }
  }

  Future<void> _fetchUserData() async {
    final authUser = auth.FirebaseAuth.instance.currentUser;
    if (authUser != null) {
      final user = await UserDao().getUser(authUser.uid);
      if (mounted && user != null) {
        setState(() {
          _currentUser = user;
          _firstNameController.text = _currentUser?.firstName ?? '';
          _lastNameController.text = _currentUser?.lastName ?? '';
          _emailController.text = _currentUser?.email ?? '';
          _phoneController.text = _currentUser?.phone ?? '';
          _weightController.text = _currentUser?.weight?.toString() ?? '';
          _heightController.text = _currentUser?.height?.toString() ?? '';
          _selectedGender = _currentUser?.gender ?? 'Male';
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      _currentUser!.firstName = _firstNameController.text;
      _currentUser!.lastName = _lastNameController.text;
      _currentUser!.email = _emailController.text;
      _currentUser!.phone = _phoneController.text;
      _currentUser!.gender = _selectedGender;
      _currentUser!.weight = double.tryParse(_weightController.text);
      _currentUser!.height = double.tryParse(_heightController.text);

      await UserDao().updateUser(_currentUser!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String displayName = _currentUser?.firstName ?? 'User';
    
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: kPurple,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontFamily: 'Syne',
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        _isLoading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : GestureDetector(
                              onTap: _saveChanges,
                              child: const Icon(Icons.check, color: Colors.white, size: 24),
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white24,
                        child: Text(displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U', 
                            style: const TextStyle(fontSize: 32, color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontFamily: 'Syne',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _currentUser?.email ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FormField(label: 'First name', controller: _firstNameController),
                  _FormField(label: 'Last name', controller: _lastNameController),
                  _FormField(label: 'Email', controller: _emailController),
                  _FormField(label: 'Mobile Number', controller: _phoneController),
                  _GenderDropdownField(
                    label: 'Gender',
                    value: _selectedGender,
                    onChanged: (val) => setState(() => _selectedGender = val),
                  ),
                  Row(
                    children: [
                      Expanded(child: _FormField(label: 'Weight (kg)', controller: _weightController)),
                      const SizedBox(width: 12),
                      Expanded(child: _FormField(label: 'Height (cm)', controller: _heightController)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kYellow,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                        : const Text(
                            'Save Changes',
                            style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const AppBottomNav(selectedIndex: 2),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _FormField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: kPurpleLight, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: kCardBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;
  const _GenderDropdownField({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: kPurpleLight, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(10)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: kCardBg,
                icon: const Icon(Icons.keyboard_arrow_down, color: kYellow),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
