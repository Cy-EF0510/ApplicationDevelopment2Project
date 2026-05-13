import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../constants/app_colors.dart';

class HistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const HistoryPage({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    // Sort history by date descending
    final sortedHistory = List<Map<String, dynamic>>.from(history);
    sortedHistory.sort((a, b) {
      final dateA = (a['date'] as Timestamp).toDate();
      final dateB = (b['date'] as Timestamp).toDate();
      return dateB.compareTo(dateA);
    });

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Workout History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: sortedHistory.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sortedHistory.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _HistoryCard(entry: sortedHistory[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: kPurple.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'No workouts yet',
            style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete your first workout to see it here!',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  const _HistoryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final date = (entry['date'] as Timestamp).toDate();
    final dateStr = "${_getMonth(date.month)} ${date.day}, ${date.year}";
    final timeStr = "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    final progression = entry['progression'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: kPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fitness_center, color: kPurple, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['title'] ?? 'Workout',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "$dateStr • $timeStr",
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 14, color: kPurpleLight),
                    const SizedBox(width: 4),
                    Text(
                      entry['timeTaken'] ?? '0:00',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.check_circle_outline, size: 14, color: kYellow),
                    const SizedBox(width: 4),
                    Text(
                      "${entry['completedCount'] ?? 0}/${entry['exerciseCount'] ?? 0} exercises",
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "$progression%",
                style: const TextStyle(
                  color: kYellow,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "COMPLETED",
                style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
