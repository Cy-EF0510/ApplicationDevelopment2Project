import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/bottom_nav.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _name = TextEditingController(text: 'Madison Smith');
  final _email = TextEditingController(text: 'madisons@example.com');
  final _phone = TextEditingController(text: '+123 567 89000');
  final _dob = TextEditingController(text: '01 / 04 / 199X');
  final _weight = TextEditingController(text: '75 Kg');
  final _height = TextEditingController(text: '1.65 CM');

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _dob, _weight, _height]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'My Profile',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 44,
                        backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=200',
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(color: kYellow, shape: BoxShape.circle),
                        child: const Icon(Icons.edit, size: 12, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Madison Smith',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'madisons@example.com',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Birthday: April 1st',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  _StatsBar(),
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
                  _FormField(label: 'Full name', controller: _name),
                  _FormField(
                    label: 'Email',
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _FormField(
                    label: 'Mobile Number',
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                  ),
                  _FormField(label: 'Date of birth', controller: _dob),
                  _FormField(label: 'Weight', controller: _weight),
                  _FormField(label: 'Height', controller: _height),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile updated!'), backgroundColor: kPurple),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kYellow,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text(
                        'Update Profile',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          const AppBottomNav(selectedIndex: 3),
        ],
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: kPurpleDim, borderRadius: BorderRadius.circular(12)),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatCell(value: '75 Kg', label: 'Weight'),
          _VertDivider(),
          _StatCell(value: '28', label: 'Years Old'),
          _VertDivider(),
          _StatCell(value: '1.65 CM', label: 'Height'),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value, label;
  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
    ],
  );
}

class _VertDivider extends StatelessWidget {
  const _VertDivider();

  @override
  Widget build(BuildContext context) => Container(width: 1, height: 28, color: Colors.white24);
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  const _FormField({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: kPurpleLight, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: kCardBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kPurple, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}