import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../constants/app_colors.dart';
import '../../../controllers/userController.dart';
import '../../../models/user.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  User? _user;
  bool _isLoading = true;
  int _streakCount = 0;
  int _highestStreakCount = 0;
  DateTime? _highestStreakStart;
  DateTime? _highestStreakEnd;
  Set<String> _workoutDates = {};

  @override
  void initState() {
    super.initState();
    _loadUserAndStreak();
  }

  Future<void> _loadUserAndStreak() async {
    final authUser = auth.FirebaseAuth.instance.currentUser;
    if (authUser != null) {
      final user = await UserDao().getUser(authUser.uid);
      if (user != null) {
        final history = user.workoutHistory;
        setState(() {
          _user = user;
          _streakCount = _calculateStreak(history);
          final highest = _calculateHighestStreak(history);
          _highestStreakCount = highest.count;
          _highestStreakStart = highest.start;
          _highestStreakEnd = highest.end;
          _workoutDates = history.map((e) {
            final date = (e['date'] as Timestamp).toDate();
            return "${date.year}-${date.month}-${date.day}";
          }).toSet();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  int _calculateStreak(List<Map<String, dynamic>> history) {
    if (history.isEmpty) return 0;

    // Normalize to unique calendar dates and sort descending (newest first)
    final dates = history.map((e) {
      final d = (e['date'] as Timestamp).toDate();
      return DateTime(d.year, d.month, d.day);
    }).toSet().toList();
    dates.sort((a, b) => b.compareTo(a));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Current streak only counts if the user worked out today or yesterday
    if (dates[0] != today && dates[0] != yesterday) return 0;

    int counter = 1;
    for (int i = 0; i < dates.length - 1; i++) {
      // Check if next date is exactly 1 day before current date in loop
      if (dates[i].difference(dates[i + 1]).inDays == 1) {
        counter++;
      } else {
        break;
      }
    }
    return counter;
  }

  ({int count, DateTime start, DateTime end}) _calculateHighestStreak(List<Map<String, dynamic>> history) {
    if (history.isEmpty) {
      return (count: 0, start: DateTime.now(), end: DateTime.now());
    }

    // Normalize to unique calendar dates and sort ascending (oldest first)
    final dates = history.map((e) {
      final d = (e['date'] as Timestamp).toDate();
      return DateTime(d.year, d.month, d.day);
    }).toSet().toList();
    dates.sort((a, b) => a.compareTo(b));

    int maxCount = 0;
    DateTime bestStart = dates[0];
    DateTime bestEnd = dates[0];

    int currentCount = 1;
    DateTime currentStart = dates[0];

    for (int i = 1; i < dates.length; i++) {
      if (dates[i].difference(dates[i - 1]).inDays == 1) {
        currentCount++;
      } else {
        if (currentCount > maxCount) {
          maxCount = currentCount;
          bestStart = currentStart;
          bestEnd = dates[i - 1];
        }
        currentCount = 1;
        currentStart = dates[i];
      }
    }

    // Final check for the last segment
    if (currentCount > maxCount) {
      maxCount = currentCount;
      bestStart = currentStart;
      bestEnd = dates.last;
    }

    return (count: maxCount, start: bestStart, end: bestEnd);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Progress Tracking'),
        backgroundColor: kBg,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: kYellow))
          : ListView(
              padding: const EdgeInsets.only(bottom: 30),
              children: [
                _buildStreakBanner(),
                _buildHighestStreakBanner(),
                const SizedBox(height: 24),
                _buildCalendarSection(),
              ],
            ),
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
                Text(
                  '$_streakCount-day streak',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: kYellow,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _streakCount > 0 
                      ? 'Keep it going — you\'re doing great!' 
                      : 'Start a workout today to begin your streak!',
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

  Widget _buildHighestStreakBanner() {
    if (_highestStreakCount == 0) return const SizedBox.shrink();

    final dateRange = "${_formatDate(_highestStreakStart!)} - ${_formatDate(_highestStreakEnd!)}";

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kCardBg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kPurple.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.emoji_events_rounded, color: kPurple, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_highestStreakCount-day highest streak',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: kPurpleLight,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  dateRange,
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

  Widget _buildCalendarSection() {
    if (_user == null) return const SizedBox.shrink();

    final startDate = _user!.createdOn.toDate();
    final endDate = DateTime.now();
    
    // Generate months from startDate to endDate
    List<DateTime> months = [];
    DateTime current = DateTime(startDate.year, startDate.month);
    while (current.isBefore(endDate) || (current.year == endDate.year && current.month == endDate.month)) {
      months.add(current);
      current = DateTime(current.year, current.month + 1);
    }
    
    // Show months in reverse (newest first)
    months = months.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'WORKOUT ACTIVITY',
            style: TextStyle(
              color: kPurpleLight,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...months.map((month) => _buildMonthCalendar(month)),
      ],
    );
  }

  Widget _buildMonthCalendar(DateTime monthDate) {
    final monthName = _getMonthName(monthDate.month);
    final year = monthDate.year;
    
    // Days in month
    final lastDay = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    final firstDayOfWeek = DateTime(monthDate.year, monthDate.month, 1).weekday % 7; // 0 = Sunday

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$monthName $year',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildWeekdayHeader(),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: lastDay + firstDayOfWeek,
            itemBuilder: (context, index) {
              if (index < firstDayOfWeek) return const SizedBox.shrink();
              
              final day = index - firstDayOfWeek + 1;
              final dateKey = "${monthDate.year}-${monthDate.month}-$day";
              final hasWorkout = _workoutDates.contains(dateKey);
              final isToday = _isToday(monthDate.year, monthDate.month, day);

              return Column(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isToday ? kPurple.withOpacity(0.2) : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isToday ? Border.all(color: kPurple, width: 1) : null,
                      ),
                      child: Text(
                        '$day',
                        style: TextStyle(
                          color: isToday ? kPurpleLight : Colors.white70,
                          fontSize: 12,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: hasWorkout ? kYellow : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((d) => SizedBox(
        width: 30,
        child: Text(
          d,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      )).toList(),
    );
  }

  bool _isToday(int year, int month, int day) {
    final now = DateTime.now();
    return now.year == year && now.month == month && now.day == day;
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    return "${_getMonthName(date.month).substring(0, 3)} ${date.day}, ${date.year}";
  }
}
