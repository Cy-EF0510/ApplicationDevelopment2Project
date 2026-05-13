import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../models/user.dart';
import '../../../controllers/userController.dart';
import 'age.dart';
import 'weight.dart';

class GenderSelectionPage extends StatefulWidget {
  final User user;
  const GenderSelectionPage({super.key, required this.user});

  @override
  State<GenderSelectionPage> createState() => _GenderSelectionPageState();
}

class _GenderSelectionPageState extends State<GenderSelectionPage> {
  String selectedGender = "";

  @override
  void initState() {
    super.initState();
    selectedGender = widget.user.gender ?? "";
  }

  Future<void> _handleContinue() async {
    if (selectedGender.isEmpty) return;

    widget.user.gender = selectedGender;

    try {
      UserDao userDao = UserDao();
      await userDao.updateUser(widget.user);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AgeSelectionPage(user: widget.user),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving gender: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Back button
              Align(
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
              const SizedBox(height: 30),
              // Title
              const Text(
                "Select Your Gender",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Male Option
              GestureDetector(
                onTap: () => setState(() => selectedGender = "Male"),
                child: Column(
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selectedGender == "Male" ? kYellow : Colors.transparent,
                        border: Border.all(
                          color: selectedGender == "Male" ? kYellow : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.mars,
                          size: 70,
                          color: selectedGender == "Male" ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Male",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Female Option
              GestureDetector(
                onTap: () => setState(() => selectedGender = "Female"),
                child: Column(
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selectedGender == "Female" ? kYellow : Colors.transparent,
                        border: Border.all(
                          color: selectedGender == "Female" ? kYellow : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.venus,
                          size: 70,
                          color: selectedGender == "Female" ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Female",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Continue Button
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: SizedBox(
                  width: 260,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: selectedGender.isNotEmpty ? _handleContinue : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      side: BorderSide(
                        color: selectedGender.isNotEmpty ? kYellow : Colors.grey,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}