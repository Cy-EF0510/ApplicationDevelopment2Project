import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../../constants/app_colors.dart';
import '../../../controllers/userController.dart';
import '../../../models/user.dart' as model;
//import 'create_workout_page.dart';

import 'workout_detail_page.dart';

class WorkoutsPage extends StatefulWidget {
  const WorkoutsPage({super.key});

  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  model.User? _currentUser;
  Map<String, List<Map<String, dynamic>>> _groupedWorkouts = {
    'Beginner': [],
    'Intermediate': [],
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final authUser = auth.FirebaseAuth.instance.currentUser;
      if (authUser != null) {
        _currentUser = await UserDao().getUser(authUser.uid);
      }

      final String response = await rootBundle.loadString('assets/exercises.json');
      final data = await json.decode(response);
      final List allExercises = data['exercises'];

      setState(() {
        _groupedWorkouts['Beginner'] = [
          {
            'title': 'Full Body Starter',
            'image': 'assets/fitness.png',
            'duration': '45 min',
            'exercises': _filter(allExercises, ['Barbell Squat', 'Barbell Bench Press - Medium Grip', 'T-Bar Row with Handle', 'Side Lateral Raise', 'Cable Crunch']),
          },
          {
            'title': 'Upper Body Focus',
            'image': 'assets/stretch.jpg',
            'duration': '40 min',
            'exercises': _filter(allExercises, ['Barbell Incline Bench Press - Medium Grip', 'Butterfly', 'Smith Machine Overhead Shoulder Press', 'Preacher Curl', 'Cable Rope Overhead Triceps Extension']),
          },
          {
            'title': 'Leg Day Basics',
            'image': 'assets/squat.jpg',
            'duration': '35 min',
            'exercises': _filter(allExercises, ['Barbell Walking Lunge', 'Leg Extensions', 'Seated Leg Curl', 'Seated Calf Raise']),
          },
        ];

        _groupedWorkouts['Intermediate'] = [
          {
            'title': 'Power & Strength',
            'image': 'assets/core.jpg',
            'duration': '60 min',
            'exercises': _filter(allExercises, ['Barbell Deadlift', 'Barbell Hip Thrust', 'Romanian Deadlift', 'Dips - Chest Version', 'Standing One-Arm Cable Curl']),
          },
        ];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  List _filter(List all, List<String> names) {
    return all.where((e) => names.contains(e['name'])).toList();
  }

  Future<void> _toggleFavoriteWorkout(String workoutTitle) async {
    if (_currentUser == null) return;
    setState(() {
      if (_currentUser!.favoriteWorkouts.contains(workoutTitle)) {
        _currentUser!.favoriteWorkouts.remove(workoutTitle);
      } else {
        _currentUser!.favoriteWorkouts.add(workoutTitle);
      }
    });
    await UserDao().updateUser(_currentUser!);
  }

  Future<void> _toggleFavoriteExercise(String exerciseName) async {
    if (_currentUser == null) return;
    setState(() {
      if (_currentUser!.favoriteExercises.contains(exerciseName)) {
        _currentUser!.favoriteExercises.remove(exerciseName);
      } else {
        _currentUser!.favoriteExercises.add(exerciseName);
      }
    });
    await UserDao().updateUser(_currentUser!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Workout Routines'),
        backgroundColor: kBg,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: (){},
            // onPressed: () async {
            //   if (_currentUser != null) {
            //     final result = await Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (_) => CreateWorkoutPage(user: _currentUser!)),
            //     );
            //     if (result == true) _loadData();
            //   }
            // },
            icon: const Icon(Icons.add_circle_outline, color: kYellow),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPurple))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_currentUser?.customWorkouts.isNotEmpty ?? false) ...[
                  _buildSectionHeader('Your Custom Workouts'),
                  ..._currentUser!.customWorkouts.map((w) => _WorkoutRoutineCard(
                        routine: w,
                        user: _currentUser!,
                        isFavorite: _currentUser!.favoriteWorkouts.contains(w['title']),
                        onFavoriteToggle: () => _toggleFavoriteWorkout(w['title']),
                        favoriteExercises: _currentUser!.favoriteExercises,
                        onExerciseFavoriteToggle: _toggleFavoriteExercise,
                      )),
                  const SizedBox(height: 24),
                ],
                _buildSectionHeader('Beginner'),
                ..._groupedWorkouts['Beginner']!.map((w) => _WorkoutRoutineCard(
                      routine: w,
                      user: _currentUser!,
                      isFavorite: _currentUser?.favoriteWorkouts.contains(w['title']) ?? false,
                      onFavoriteToggle: () => _toggleFavoriteWorkout(w['title']),
                      favoriteExercises: _currentUser?.favoriteExercises ?? [],
                      onExerciseFavoriteToggle: _toggleFavoriteExercise,
                    )),
                const SizedBox(height: 24),
                _buildSectionHeader('Intermediate'),
                ..._groupedWorkouts['Intermediate']!.map((w) => _WorkoutRoutineCard(
                      routine: w,
                      user: _currentUser!,
                      isFavorite: _currentUser?.favoriteWorkouts.contains(w['title']) ?? false,
                      onFavoriteToggle: () => _toggleFavoriteWorkout(w['title']),
                      favoriteExercises: _currentUser?.favoriteExercises ?? [],
                      onExerciseFavoriteToggle: _toggleFavoriteExercise,
                    )),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: const TextStyle(color: kYellow, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _WorkoutRoutineCard extends StatelessWidget {
  final Map<String, dynamic> routine;
  final model.User user;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final List<String> favoriteExercises;
  final Function(String) onExerciseFavoriteToggle;

  const _WorkoutRoutineCard({
    required this.routine,
    required this.user,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.favoriteExercises,
    required this.onExerciseFavoriteToggle,
  });

  void _showInstructions(BuildContext context, Map<String, dynamic> exercise) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => StatefulBuilder(
          builder: (context, setModalState) => SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exercise['name'],
                        style: const TextStyle(color: kPurpleLight, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        onExerciseFavoriteToggle(exercise['name']);
                        setModalState(() {});
                      },
                      icon: Icon(
                        favoriteExercises.contains(exercise['name']) ? Icons.star : Icons.star_border,
                        color: kYellow,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Badge(label: exercise['level'].toString().toUpperCase()),
                    const SizedBox(width: 8),
                    _Badge(label: exercise['equipment']?.toString().toUpperCase() ?? "NONE", color: kYellow),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  "Instructions",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...(exercise['instructions'] as List).asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: kPurple.withOpacity(0.2),
                          child: Text(
                            "${entry.key + 1}",
                            style: const TextStyle(color: kPurple, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.05),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => WorkoutDetailPage(workout: routine, user: user)),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(routine['image'], width: 50, height: 50, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, color: kPurple)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(routine['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(routine['duration'], style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(isFavorite ? Icons.star : Icons.star_border, color: kYellow),
                onPressed: onFavoriteToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, this.color = kPurple});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
