import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../../constants/app_colors.dart';
import '../../../controllers/userController.dart';
import '../../../models/user.dart' as model;

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  final TextEditingController _searchController = TextEditingController();
  List _allExercises = [];
  List _filteredExercises = [];
  model.User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final authUser = auth.FirebaseAuth.instance.currentUser;
      if (authUser != null) {
        _currentUser = await UserDao().getUser(authUser.uid);
      }

      final String response = await rootBundle.loadString('assets/exercises.json');
      final data = await json.decode(response);
      setState(() {
        _allExercises = data['exercises'];
        _isLoading = false;
        _filterExercises(_searchController.text);
      });
    } catch (e) {
      debugPrint("Error loading exercises: $e");
      setState(() => _isLoading = false);
    }
  }

  void _filterExercises(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredExercises = List.from(_allExercises);
      } else {
        final searchTerms = query.toLowerCase().trim().split(RegExp(r'[\s,.-]+')).where((t) => t.isNotEmpty).toList();
        _filteredExercises = _allExercises.where((ex) {
          final searchableText = [
            ex['name'],
            ex['category'],
            ex['equipment'],
            ex['level'],
            ex['force'],
            ex['mechanic'],
            ...((ex['primaryMuscles'] as List?) ?? []),
            ...((ex['secondaryMuscles'] as List?) ?? []),
          ].where((e) => e != null).join(' ').toLowerCase();

          return searchTerms.every((term) => searchableText.contains(term));
        }).toList();
      }
    });
  }

  Future<void> _toggleFavorite(String exerciseName) async {
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

  void _showInstructions(Map<String, dynamic> exercise) {
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
                        _toggleFavorite(exercise['name']);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Explore Exercises'),
        backgroundColor: kBg,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterExercises,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search exercises or muscles...",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: kPurple),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          _filterExercises("");
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: kPurple))
                : _filteredExercises.isEmpty
                    ? const Center(
                        child: Text(
                          "No exercises match your search",
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      final ex = _filteredExercises[index];
                      final isFav = _currentUser?.favoriteExercises.contains(ex['name']) ?? false;
                      return Card(
                        color: Colors.white.withOpacity(0.05),
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          onTap: () => _showInstructions(ex),
                          leading: CircleAvatar(
                            backgroundColor: kPurple.withOpacity(0.1),
                            child: Icon(_getIconForCategory(ex['category']), color: kPurple, size: 20),
                          ),
                          title: Text(ex['name'] ?? "Unknown Exercise", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text("${ex['level'] ?? 'Beginner'} | ${(ex['primaryMuscles'] as List?)?.isNotEmpty == true ? ex['primaryMuscles'][0] : 'Various'}",
                              style: const TextStyle(color: Colors.white60, fontSize: 12)),
                          trailing: IconButton(
                            icon: Icon(isFav ? Icons.star : Icons.star_border, color: kYellow),
                            onPressed: () => _toggleFavorite(ex['name']),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
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
