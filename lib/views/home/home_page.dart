import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../data/sample_data.dart';
import '../../models/workout.dart' as legacy_model;
import '../../models/user.dart';
import '../../controllers/userController.dart';
import '../../widgets/bottom_nav.dart';
import '../profile/profile_page.dart';
import '../profile/settings/settings_page.dart';
import 'quick acces bar/goals_page.dart';
import '../../models/quick_access_item.dart';
import 'quick acces bar/map_view.dart';
import 'quick acces bar/exercises_page.dart';
import 'quick acces bar/tracking_page.dart';
import '../home/workouts/history_page.dart';
import '../home/workouts/workouts_page.dart';
import '../home/workouts/workout_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? currentUser;
  bool isLoading = true;
  List<Map<String, dynamic>> _allWorkouts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authUser = auth.FirebaseAuth.instance.currentUser;
    if (authUser != null) {
      final user = await UserDao().getUser(authUser.uid);
      
      // Load exercises to build routine objects
      final String response = await rootBundle.loadString('assets/exercises.json');
      final data = await json.decode(response);
      final List allExercises = data['exercises'];

      List _filter(List all, List<String> names) {
        return all.where((e) => names.contains(e['name'])).toList();
      }

      final beginner = [
        {
          'title': 'Full Body Starter',
          'image': 'assets/fitness.png',
          'duration': '45 min',
          'calories': '320',
          'exercises': _filter(allExercises, ['Barbell Squat', 'Barbell Bench Press - Medium Grip', 'T-Bar Row with Handle', 'Side Lateral Raise', 'Cable Crunch']),
        },
        {
          'title': 'Upper Body Focus',
          'image': 'assets/stretch.jpg',
          'duration': '40 min',
          'calories': '280',
          'exercises': _filter(allExercises, ['Barbell Incline Bench Press - Medium Grip', 'Butterfly', 'Smith Machine Overhead Shoulder Press', 'Preacher Curl', 'Cable Rope Overhead Triceps Extension']),
        },
        {
          'title': 'Leg Day Basics',
          'image': 'assets/squat.jpg',
          'duration': '35 min',
          'calories': '250',
          'exercises': _filter(allExercises, ['Barbell Walking Lunge', 'Leg Extensions', 'Seated Leg Curl', 'Seated Calf Raise']),
        },
      ];

      if (mounted) {
        setState(() {
          currentUser = user;
          _allWorkouts = [...(user?.customWorkouts ?? []), ...beginner];
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _onNavTap(int index) {
    if (index == 1) {
      // Handled by BottomNav normally, but we can add logic here if needed
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      bottomNavigationBar: AppBottomNav(
        selectedIndex: 0,
        onTap: (i) {
          if (i == 1) {
             // In the new idea, '+' takes to Workouts or a specific 'Start' view
             // For now, let's take to WorkoutsPage or handle as "Start Workout"
             Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkoutsPage()));
          } else if (i == 2) {
             Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
          }
        },
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: kYellow))
            : RefreshIndicator(
                onRefresh: _loadData,
                color: kPurple,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(
                        user: currentUser,
                        onSettingsTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
                        onProfileTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
                      ),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: _QuickAccessBar(),
                      ),
                      const SizedBox(height: 24),
                      _SectionHeader(title: 'Workouts', onSeeAll: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkoutsPage())).then((_) => _loadData());
                      }),
                      const SizedBox(height: 12),
                      _WorkoutsRow(
                        workouts: _allWorkouts,
                        user: currentUser!,
                        onStateChange: _loadData,
                      ),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: _WeeklyChallengeBanner(),
                      ),
                      const SizedBox(height: 24),
                      if (currentUser?.workoutHistory.isNotEmpty ?? false) ...[
                        _SectionHeader(title: 'History', onSeeAll: () {
                           Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryPage(history: currentUser!.workoutHistory)));
                        }),
                        const SizedBox(height: 12),
                        _HistoryList(history: currentUser!.workoutHistory),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final User? user;
  final VoidCallback onSettingsTap;
  final VoidCallback onProfileTap;

  const _Header({this.user, required this.onSettingsTap, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    String displayName = user?.firstName ?? user?.username ?? 'User';
    String initial = displayName.isNotEmpty ? displayName[0].toLowerCase() : 'u';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, $displayName',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: kPurple,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "It's time to challenge your limits.",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.notifications_outlined, color: kPurple, size: 24),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: onProfileTap,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: kPurpleDim,
              child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessBar extends StatelessWidget {
  const _QuickAccessBar();

  final List<QuickAccessItem> quickAccessItems = const [
    QuickAccessItem(icon: Icons.fitness_center, label: 'All Exercises'),
    QuickAccessItem(icon: Icons.checklist, label: 'Goals'),
    QuickAccessItem(icon: Icons.track_changes, label: 'Progress'),
    QuickAccessItem(icon: Icons.pin_drop, label: 'Nearby Gyms'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: kPurple, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: quickAccessItems.map((item) {
            final isLast = quickAccessItems.last == item;
            return Row(
              children: [
                _QuickAccessItemWidget(item: item),
                if (!isLast)
                  Container(width: 1, height: 48, color: kPurple.withOpacity(0.3)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _QuickAccessItemWidget extends StatelessWidget {
  final QuickAccessItem item;
  const _QuickAccessItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.label == 'Nearby Gyms') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MapView()),
          );
        } else if (item.label == 'All Exercises') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExercisesPage()),
          );
        } else if (item.label.contains('Progress')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TrackingPage()),
          );
        } else if (item.label == 'Goals') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GoalsPage()),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: kPurple, size: 28),
            const SizedBox(height: 6),
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 10, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: kYellow, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: const Row(
              children: [
                Text('See All', style: TextStyle(color: Colors.white70, fontSize: 13)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutsRow extends StatelessWidget {
  final List<Map<String, dynamic>> workouts;
  final User user;
  final VoidCallback onStateChange;
  const _WorkoutsRow({required this.workouts, required this.user, required this.onStateChange});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: workouts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _WorkoutCard(
          workout: workouts[i],
          user: user,
          onFavToggle: () async {
            final title = workouts[i]['title'];
            if (user.favoriteWorkouts.contains(title)) {
              user.favoriteWorkouts.remove(title);
            } else {
              user.favoriteWorkouts.add(title);
            }
            await UserDao().updateUser(user);
            onStateChange();
          },
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final Map<String, dynamic> workout;
  final User user;
  final VoidCallback onFavToggle;
  const _WorkoutCard({required this.workout, required this.user, required this.onFavToggle});

  @override
  Widget build(BuildContext context) {
    final bool isFav = user.favoriteWorkouts.contains(workout['title']);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WorkoutDetailPage(workout: workout, user: user)),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 160,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                workout['image'] ?? workout['imagePath'] ?? 'assets/fitness.png',
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
                      workout['title'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: kPurpleLight, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 11, color: Colors.white70),
                        const SizedBox(width: 3),
                        Text(workout['duration'], style: const TextStyle(color: Colors.white70, fontSize: 10)),
                        const SizedBox(width: 8),
                        const Icon(Icons.local_fire_department, size: 11, color: kOrange),
                        const SizedBox(width: 3),
                        Text(workout['calories'] ?? '200', style: const TextStyle(color: Colors.white70, fontSize: 10)),
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
                    isFav ? Icons.star : Icons.star_border,
                    color: isFav ? kYellow : Colors.white,
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
      ),
    );
  }
}

class _WeeklyChallengeBanner extends StatelessWidget {
  const _WeeklyChallengeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: kPurple,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'THIS WEEK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Weekly\nChallenge',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Plank With Hip Twist',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 140,
            child: Image.asset(
              'assets/challenge.jpg',
              fit: BoxFit.cover,
              height: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                color: kPurpleDim,
                child: const Icon(Icons.fitness_center, color: Colors.white, size: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  const _HistoryList({required this.history});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: history.length > 3 ? 3 : history.length,
      itemBuilder: (context, index) {
        final entry = history[index];
        final date = (entry['date'] as Timestamp).toDate();
        final dateStr = "${date.day}/${date.month}/${date.year}";

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: kPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.history, color: kPurple),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text("$dateStr • ${entry['timeTaken']}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("${entry['progression']}%", style: const TextStyle(color: kYellow, fontWeight: FontWeight.bold)),
                  const Text("Done", style: TextStyle(color: Colors.white38, fontSize: 10)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
