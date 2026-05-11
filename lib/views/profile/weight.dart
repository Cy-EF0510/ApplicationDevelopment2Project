import 'package:flutter/material.dart';
import 'package:numeric_selector/numeric_selector.dart';
import '../../constants/app_colors.dart';
import '../../models/user.dart';
import '../../controllers/userController.dart';
import 'height.dart';

class WeightSelectionPage extends StatefulWidget {
  final User user;
  const WeightSelectionPage({super.key, required this.user});

  @override
  State<WeightSelectionPage> createState() => _WeightSelectionPageState();
}

class _WeightSelectionPageState extends State<WeightSelectionPage> {
  int selectedWeight = 75;
  bool isKg = true;

  @override
  void initState() {
    super.initState();
    selectedWeight = widget.user.weight?.toInt() ?? 75;
  }

  void _toggleUnit(bool toKg) {
    if (isKg == toKg) return;

    setState(() {
      isKg = toKg;
      if (isKg) {
        // Convert LB to KG: lb / 2.20462
        selectedWeight = (selectedWeight / 2.20462).round();
      } else {
        // Convert KG to LB: kg * 2.20462
        selectedWeight = (selectedWeight * 2.20462).round();
      }

      // Clamp values to stay within selector range [0, 500]
      if (selectedWeight > 500) selectedWeight = 500;
      if (selectedWeight < 0) selectedWeight = 0;
    });
  }

  Future<void> _handleContinue() async {
    // Revert to KG if LB was selected before saving to Firestore
    double weightInKg = isKg ? selectedWeight.toDouble() : selectedWeight / 2.20462;
    widget.user.weight = weightInKg;

    try {
      UserDao userDao = UserDao();
      await userDao.updateUser(widget.user);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HeightSelectionPage(user: widget.user),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving weight: $e"), backgroundColor: Colors.red),
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
              "What Is Your Weight?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // KG | LB Toggle Container
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
                          "KG",
                          style: TextStyle(
                            color: isKg ? Colors.black : Colors.black45,
                            fontWeight: isKg ? FontWeight.bold : FontWeight.normal,
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
                          "LB",
                          style: TextStyle(
                            color: !isKg ? Colors.black : Colors.black45,
                            fontWeight: !isKg ? FontWeight.bold : FontWeight.normal,
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
            // The selector's key forces a rebuild when selectedWeight is changed programmatically (via toggle)
            HorizontalNumericSelector(
              key: ValueKey("weight_selector_$isKg"),
              minValue: 0,
              maxValue: 500, // to accommodate LB
              step: 1,
              initialValue: selectedWeight,
              onValueChanged: (value) {
                setState(() {
                  selectedWeight = value;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "$selectedWeight",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isKg ? "KG" : "LB",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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