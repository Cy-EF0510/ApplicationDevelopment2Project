import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Progress Tracking'),
        backgroundColor: kBg,
        elevation: 0,
      ),
      body: ListView(children: [_buildStreakBanner()]),
    );
  }

  Widget _buildStreakBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kCardBg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kYellow.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('🔥', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'x-day streak',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: kYellow,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Keep it going — check off a task today',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.27),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
