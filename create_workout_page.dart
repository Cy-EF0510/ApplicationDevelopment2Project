import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/app_colors.dart';
import '../../../controllers/userController.dart';
import '../../../models/user.dart' as model;

class CreateWorkoutPage extends StatefulWidget {
  final model.User user;
  const CreateWorkoutPage({super.key, required this.user});

  @override
  State<CreateWorkoutPage> createState() => _CreateWorkoutPageState();
}

class _CreateWorkoutPageState extends State<CreateWorkoutPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allExercises = [];
  List<Map<String, dynamic>> _filteredExercises = [];
  final List<Map<String, dynamic>> _selectedExercises = [];
  bool _isLoading = true;

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      final String response = await rootBundle.loadString('assets/exercises.json');
      final data = await json.decode(response);
      _allExercises = List<Map<String, dynamic>>.from(data['exercises']);
      _isLoading = false;
      _filterExercises(_searchController.text);
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
                      onPressed: () async {
                        setState(() {
                          if (widget.user.favoriteExercises.contains(exercise['name'])) {
                            widget.user.favoriteExercises.remove(exercise['name']);
                          } else {
                            widget.user.favoriteExercises.add(exercise['name']);
                          }
                        });
                        await UserDao().updateUser(widget.user);
                        setModalState(() {});
                      },
                      icon: Icon(
                        widget.user.favoriteExercises.contains(exercise['name'])
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

  Future<void> _saveWorkout() async {
    if (_nameController.text.isEmpty || _selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name and select at least one exercise')),
      );
      return;
    }

    final newWorkout = {
      'title': _nameController.text,
      'image': 'assets/fitness.png', // Default image
      'duration': '${_selectedExercises.length * 10} min', // Rough estimate
      'exercises': _selectedExercises,
      'isCustom': true,
    };

    widget.user.customWorkouts.add(newWorkout);
    await UserDao().updateUser(widget.user);
    
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Create Custom Workout'),
        backgroundColor: kBg,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPurple))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Workout Name',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterExercises,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search exercises...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.search, color: kPurple, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white54, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                _filterExercises("");
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Select Exercises', style: TextStyle(color: kYellow, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                Expanded(
                  child: _filteredExercises.isEmpty
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
                      final isSelected = _selectedExercises.any((e) => e['name'] == ex['name']);
                      return Card(
                        color: Colors.white.withOpacity(0.05),
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isSelected ? const BorderSide(color: kPurple, width: 1) : BorderSide.none,
                        ),
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedExercises.removeWhere((e) => e['name'] == ex['name']);
                              } else {
                                _selectedExercises.add(ex);
                              }
                            });
                          },
                          leading: CircleAvatar(
                            backgroundColor: kPurple.withOpacity(0.1),
                            child: Icon(_getIconForCategory(ex['category']), color: kPurple, size: 20),
                          ),
                          title: Text(ex['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text("${ex['level']} | ${ex['equipment'] ?? 'No Equipment'}",
                              style: const TextStyle(color: Colors.white60, fontSize: 12)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.info_outline, color: kPurpleLight),
                                onPressed: () => _showInstructions(ex),
                              ),
                              Icon(
                                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                color: isSelected ? kPurple : Colors.white24,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveWorkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('SAVE WORKOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
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
