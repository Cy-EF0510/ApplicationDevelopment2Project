import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../constants/app_colors.dart';
import '../../controllers/userController.dart';
import '../../models/user.dart' as model;
import '../home/workouts/workout_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  model.User? _currentUser;
  List<Map<String, dynamic>> _favoriteExercisesList = [];
  List<Map<String, dynamic>> _favoriteWorkoutsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final authUser = auth.FirebaseAuth.instance.currentUser;
      if (authUser != null) {
        _currentUser = await UserDao().getUser(authUser.uid);
      }

      if (_currentUser != null) {
        final String response = await rootBundle.loadString('assets/exercises.json');
        final data = await json.decode(response);
        final List allExercises = data['exercises'];

        // Filter favorite exercises
        _favoriteExercisesList = allExercises
            .where((ex) => _currentUser!.favoriteExercises.contains(ex['name']))
            .cast<Map<String, dynamic>>()
            .toList();

        // Workouts: Predefined + Custom
        // Predefined routines (from WorkoutsPage logic)
        final List<Map<String, dynamic>> predefinedWorkouts = [
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
          {
            'title': 'Power & Strength',
            'image': 'assets/core.jpg',
            'duration': '60 min',
            'exercises': _filter(allExercises, ['Barbell Deadlift', 'Barbell Hip Thrust', 'Romanian Deadlift', 'Dips - Chest Version', 'Standing One-Arm Cable Curl']),
          },
        ];

        final allPossibleWorkouts = [...predefinedWorkouts, ..._currentUser!.customWorkouts];
        _favoriteWorkoutsList = allPossibleWorkouts
            .where((w) => _currentUser!.favoriteWorkouts.contains(w['title']))
            .toList();
      }
    } catch (e) {
      debugPrint("Error loading favorites: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List _filter(List all, List<String> names) {
    return all.where((e) => names.contains(e['name'])).toList();
  }

  Future<void> _toggleFavoriteExercise(String name) async {
    if (_currentUser == null) return;
    setState(() {
      if (_currentUser!.favoriteExercises.contains(name)) {
        _currentUser!.favoriteExercises.remove(name);
        _favoriteExercisesList.removeWhere((ex) => ex['name'] == name);
      } else {
        _currentUser!.favoriteExercises.add(name);
      }
    });
    await UserDao().updateUser(_currentUser!);
  }

  Future<void> _toggleFavoriteWorkout(String title) async {
    if (_currentUser == null) return;
    setState(() {
      if (_currentUser!.favoriteWorkouts.contains(title)) {
        _currentUser!.favoriteWorkouts.remove(title);
        _favoriteWorkoutsList.removeWhere((w) => w['title'] == title);
      } else {
        _currentUser!.favoriteWorkouts.add(title);
      }
    });
    await UserDao().updateUser(_currentUser!);
  }

  void _showExerciseInstructions(Map<String, dynamic> exercise) {
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
                        _toggleFavoriteExercise(exercise['name']);
                        setModalState(() {});
                      },
                      icon: Icon(
                        _currentUser?.favoriteExercises.contains(exercise['name']) ?? false
                            ? Icons.star
                            : Icons.star_border,
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

  IconData _getIconForCategory(dynamic category) {
    if (category == null) return Icons.bolt;
    switch (category.toString().toLowerCase()) {
      case 'strength': return Icons.fitness_center;
      case 'stretching': return Icons.accessibility_new;
      case 'cardio': return Icons.directions_run;
      case 'powerlifting': return Icons.bolt;
      default: return Icons.bolt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: kBg,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPurple))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader('Favorite Workouts'),
                if (_favoriteWorkoutsList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text("No favorite workouts yet", style: TextStyle(color: Colors.white54)),
                  )
                else
                  ..._favoriteWorkoutsList.map((w) => _FavoriteWorkoutCard(
                        workout: w,
                        user: _currentUser!,
                        onUnfav: () => _toggleFavoriteWorkout(w['title']),
                      )),
                const SizedBox(height: 24),
                _buildSectionHeader('Favorite Exercises'),
                if (_favoriteExercisesList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text("No favorite exercises yet", style: TextStyle(color: Colors.white54)),
                  )
                else
                  ..._favoriteExercisesList.map((ex) => _FavoriteExerciseCard(
                        exercise: ex,
                        onTap: () => _showExerciseInstructions(ex),
                        onUnfav: () => _toggleFavoriteExercise(ex['name']),
                        categoryIcon: _getIconForCategory(ex['category']),
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

class _FavoriteWorkoutCard extends StatelessWidget {
  final Map<String, dynamic> workout;
  final model.User user;
  final VoidCallback onUnfav;
  const _FavoriteWorkoutCard({required this.workout, required this.user, required this.onUnfav});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => WorkoutDetailPage(workout: workout, user: user)),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            workout['image'] ?? 'assets/fitness.png',
            width: 50, height: 50, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, color: kPurple),
          ),
        ),
        title: Text(workout['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(workout['duration'] ?? 'Custom Routine', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.star, color: kYellow),
          onPressed: onUnfav,
        ),
      ),
    );
  }
}

class _FavoriteExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final VoidCallback onTap;
  final VoidCallback onUnfav;
  final IconData categoryIcon;
  const _FavoriteExerciseCard({required this.exercise, required this.onTap, required this.onUnfav, required this.categoryIcon});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: kPurple.withOpacity(0.1),
          child: Icon(categoryIcon, color: kPurple, size: 20),
        ),
        title: Text(exercise['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text("${exercise['level']} | ${exercise['equipment'] ?? 'No Equipment'}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.star, color: kYellow),
          onPressed: onUnfav,
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
