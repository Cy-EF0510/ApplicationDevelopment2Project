import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../constants/app_colors.dart';
import '../../../models/user.dart' as model;
import '../../../controllers/userController.dart';

class ActiveWorkoutPage extends StatefulWidget {
  final Map<String, dynamic> workout;
  final model.User user;

  const ActiveWorkoutPage({super.key, required this.workout, required this.user});

  @override
  State<ActiveWorkoutPage> createState() => _ActiveWorkoutPageState();
}

class _ActiveWorkoutPageState extends State<ActiveWorkoutPage> {
  late List<bool> _completedExercises;
  late Stopwatch _stopwatch;
  late Timer _timer;
  String _timeString = "00:00";

  @override
  void initState() {
    super.initState();
    _completedExercises = List.filled((widget.workout['exercises'] as List).length, false);
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeString = _formatDuration(_stopwatch.elapsed);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _finishWorkout() async {
    final int completedCount = _completedExercises.where((e) => e).length;
    final double progression = (completedCount / _completedExercises.length) * 100;

    final historyEntry = {
      'title': widget.workout['title'],
      'date': Timestamp.now(),
      'timeTaken': _timeString,
      'progression': progression.toInt(),
      'exerciseCount': _completedExercises.length,
      'completedCount': completedCount,
    };

    widget.user.workoutHistory.insert(0, historyEntry);
    await UserDao().updateUser(widget.user);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: kCardBg2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Workout Complete!", style: TextStyle(color: kYellow)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: kPurple, size: 80),
              const SizedBox(height: 16),
              Text("Time: $_timeString", style: const TextStyle(color: Colors.white)),
              Text("Completion: ${progression.toInt()}%", style: const TextStyle(color: Colors.white)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // pop dialog
                Navigator.of(context).pop(); // pop active workout
                Navigator.of(context).pop(); // pop workout detail
              },
              child: const Text("DONE", style: TextStyle(color: kPurpleLight)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.workout['exercises'] as List;
    final int completedCount = _completedExercises.where((e) => e).length;
    final double progressPercent = completedCount / exercises.length;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Text(widget.workout['title']),
        backgroundColor: kBg,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: kCardBg2,
                  title: const Text("Quit Workout?", style: TextStyle(color: Colors.white)),
                  content: const Text("Your progress won't be saved.", style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.white54))),
                    TextButton(onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }, child: const Text("QUIT", style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
            },
            child: const Text("QUIT", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white.withOpacity(0.05),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("TIME", style: TextStyle(color: Colors.white54, fontSize: 12)),
                        Text(_timeString, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("PROGRESS", style: TextStyle(color: Colors.white54, fontSize: 12)),
                        Text("$completedCount/${exercises.length}", style: const TextStyle(color: kYellow, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    backgroundColor: Colors.white12,
                    color: kPurple,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final ex = exercises[index];
                final isDone = _completedExercises[index];
                return Card(
                  color: isDone ? kPurple.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: isDone ? const BorderSide(color: kPurple, width: 1) : BorderSide.none,
                  ),
                  child: CheckboxListTile(
                    value: isDone,
                    onChanged: (val) {
                      setState(() {
                        _completedExercises[index] = val ?? false;
                      });
                    },
                    title: Text(
                      ex['name'],
                      style: TextStyle(
                        color: isDone ? Colors.white60 : Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      "${ex['level']} | ${ex['equipment'] ?? 'No Equipment'}",
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    activeColor: kPurple,
                    checkColor: Colors.white,
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _finishWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: kYellow,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text(
                "FINISH WORKOUT",
                style: TextStyle(color: kBg, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
