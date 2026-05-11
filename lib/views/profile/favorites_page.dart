import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../data/sample_data.dart';
import '../../models/workout.dart';
import '../../models/article.dart';
import '../../widgets/bottom_nav.dart';
import '../profile/profile_page.dart';
import '../profile/settings_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPage();
}

class _FavoritesPage extends State<FavoritesPage>{

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: kPurple,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Favorites',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _Favorites(onStateChange: (){})
                ],
              ),
            ),
          ),
          const AppBottomNav(selectedIndex: 2),
        ],
      ),
    );
  }
}
class _Favorites extends StatelessWidget {
  final VoidCallback onStateChange;
  const _Favorites({required this.onStateChange});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: workouts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _WorkoutCard(
          workout: workouts[i],
          onFavToggle: () {
            workouts[i].isFavorite = !workouts[i].isFavorite;
          },
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback onFavToggle;
  const _WorkoutCard({required this.workout, required this.onFavToggle});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 160,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              workout.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: kCardBg2,
                child: const Icon(Icons.image_not_supported, color: kPurple),
              ),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                height: 90,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8, left: 10, right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.title,
                    style: const TextStyle(color: kPurpleLight, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 11, color: Colors.white70),
                      const SizedBox(width: 3),
                      Text(workout.duration, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                      const SizedBox(width: 8),
                      const Icon(Icons.local_fire_department, size: 11, color: kOrange),
                      const SizedBox(width: 3),
                      Text(workout.calories, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8, right: 8,
              child: GestureDetector(
                onTap: onFavToggle,
                child: Icon(
                  workout.isFavorite ? Icons.star : Icons.star_border,
                  color: workout.isFavorite ? kYellow : Colors.white,
                  size: 20,
                ),
              ),
            ),
            Positioned(
              bottom: 44, right: 8,
              child: Container(
                width: 30, height: 30,
                decoration: const BoxDecoration(color: kPurple, shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}