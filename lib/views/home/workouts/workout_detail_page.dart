import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/user.dart' as model;
import '../../../controllers/userController.dart';
import 'active_workout_page.dart';

class WorkoutDetailPage extends StatefulWidget {
  final Map<String, dynamic> workout;
  final model.User user;

  const WorkoutDetailPage({super.key, required this.workout, required this.user});

  @override
  State<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
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
                        widget.user.favoriteExercises.contains(exercise['name']) ? Icons.star : Icons.star_border,
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
    final exercises = widget.workout['exercises'] as List;

    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: kBg,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    widget.workout['image'] ?? widget.workout['imagePath'] ?? 'assets/fitness.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: kPurpleDim),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [kBg, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.workout['title'],
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          setState(() {
                            if (widget.user.favoriteWorkouts.contains(widget.workout['title'])) {
                              widget.user.favoriteWorkouts.remove(widget.workout['title']);
                            } else {
                              widget.user.favoriteWorkouts.add(widget.workout['title']);
                            }
                          });
                          await UserDao().updateUser(widget.user);
                        },
                        icon: Icon(
                          widget.user.favoriteWorkouts.contains(widget.workout['title']) ? Icons.star : Icons.star_border,
                          color: kYellow,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: kYellow, size: 18),
                      const SizedBox(width: 6),
                      Text(widget.workout['duration'], style: const TextStyle(color: Colors.white70)),
                      const SizedBox(width: 20),
                      const Icon(Icons.fitness_center, color: kPurpleLight, size: 18),
                      const SizedBox(width: 6),
                      Text("${exercises.length} Exercises", style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Exercises",
                    style: TextStyle(color: kYellow, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final ex = exercises[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: InkWell(
                    onTap: () => _showInstructions(context, ex),
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: kPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.fitness_center, color: kPurple),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ex['name'],
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${ex['level']} | ${ex['equipment'] ?? 'No Equipment'}",
                                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: exercises.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomSheet: Container(
        color: kBg,
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ActiveWorkoutPage(
                  workout: widget.workout,
                  user: widget.user,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kPurple,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: const Text(
            "START WORKOUT",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
