import 'package:flutter/material.dart';
import 'package:numeric_selector/numeric_selector.dart';
import '../../../constants/app_colors.dart';
import '../../../models/user.dart';
import '../../../controllers/userController.dart';
import 'weight.dart';

class AgeSelectionPage extends StatefulWidget {
  final User user;
  const AgeSelectionPage({super.key, required this.user});

  @override
  State<AgeSelectionPage> createState() => _AgeSelectionPageState();
}

class _AgeSelectionPageState extends State<AgeSelectionPage> {
  int selectedAge = 28;

  @override
  void initState() {
    super.initState();
    selectedAge = widget.user.age ?? 28;
  }

  Future<void> _handleContinue() async {
    widget.user.age = selectedAge;

    try {
      UserDao userDao = UserDao();
      await userDao.updateUser(widget.user);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeightSelectionPage(user: widget.user),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving age: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
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
                      const Text(
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
            const SizedBox(height: 30),
            const Text(
              "How Old Are You?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Spacer(),
            Icon(Icons.arrow_drop_up, color: kYellow, size: 50),
            HorizontalNumericSelector(
              minValue: 0,
              maxValue: 100,
              step: 1,
              initialValue: selectedAge,
              onValueChanged: (value) {
                setState(() {
                  selectedAge = value;
                });
              },
              viewPort: 0.3,
              selectedTextStyle: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              unselectedTextStyle: const TextStyle(fontSize: 24, color: Colors.grey),
              backgroundColor: kPurpleLight,
              showLabel: false,
              showArrows: true,
              enableVibration: true,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: SizedBox(
                width: 260,
                height: 55,
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    side: const BorderSide(color: Colors.grey, width: 1.5),
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
    );
  }
}