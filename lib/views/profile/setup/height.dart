import 'package:flutter/material.dart';
import 'package:numeric_selector/numeric_selector.dart';
import '../../../constants/app_colors.dart';
import '../../../models/user.dart';
import '../../../controllers/userController.dart';
import '../fillProfile.dart';

class HeightSelectionPage extends StatefulWidget {
  final User user;
  const HeightSelectionPage({super.key, required this.user});

  @override
  State<HeightSelectionPage> createState() => _HeightSelectionPageState();
}

class _HeightSelectionPageState extends State<HeightSelectionPage> {
  int selectedHeight = 170;
  bool isCm = true;

  @override
  void initState() {
    super.initState();
    // Initially assumes value is in CM
    selectedHeight = widget.user.height?.toInt() ?? 170;
  }

  void _toggleUnit(bool toCm) {
    if (isCm == toCm) return;

    setState(() {
      if (toCm) {
        // Convert inches to CM: inches * 2.54
        selectedHeight = (selectedHeight * 2.54).round();
      } else {
        // Convert CM to total inches: cm / 2.54
        selectedHeight = (selectedHeight / 2.54).round();
      }
      isCm = toCm;

      // Clamp values to stay within selector range
      int maxVal = isCm ? 300 : 120; // 300cm or 10ft (120in)
      if (selectedHeight > maxVal) selectedHeight = maxVal;
      if (selectedHeight < 0) selectedHeight = 0;
    });
  }

  Future<void> _handleContinue() async {
    // Standardize to CM in database for consistency
    double heightInCm = isCm ? selectedHeight.toDouble() : selectedHeight * 2.54;
    widget.user.height = heightInCm;

    try {
      UserDao userDao = UserDao();
      await userDao.updateUser(widget.user);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FillProfilePage(user: widget.user),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving height: $e"), backgroundColor: Colors.red),
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
              "What Is Your Height?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 40),
            // CM | FT Toggle
            Container(
              width: 280,
              height: 60,
              decoration: BoxDecoration(
                color: kYellow,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _toggleUnit(true),
                      child: Center(
                        child: Text(
                          "CM",
                          style: TextStyle(
                            color: isCm ? Colors.black : Colors.black45,
                            fontWeight: isCm ? FontWeight.bold : FontWeight.normal,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(width: 2, height: 40, color: Colors.black45),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _toggleUnit(false),
                      child: Center(
                        child: Text(
                          "FT",
                          style: TextStyle(
                            color: !isCm ? Colors.black : Colors.black45,
                            fontWeight: !isCm ? FontWeight.bold : FontWeight.normal,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            HorizontalNumericSelector(
              key: ValueKey("height_selector_$isCm"),
              minValue: 0,
              maxValue: isCm ? 300 : 120,
              step: 1,
              initialValue: selectedHeight,
              onValueChanged: (value) {
                setState(() {
                  selectedHeight = value;
                });
              },
              viewPort: 0.3,
              selectedTextStyle: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              unselectedTextStyle: const TextStyle(fontSize: 24, color: Colors.white38),
              backgroundColor: kPurpleLight,
              showLabel: false,
              showArrows: true,
              enableVibration: true,
            ),
            Icon(Icons.arrow_drop_up, color: kYellow, size: 40),
            const SizedBox(height: 10),
            // Large Display Value
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                if (isCm) ...[
                  Text(
                    "$selectedHeight",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "CM",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else ...[
                  Text(
                    "${selectedHeight ~/ 12}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "FT ",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${selectedHeight % 12}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "IN",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
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