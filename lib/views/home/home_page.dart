import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../constants/app_colors.dart';
import '../../data/sample_data.dart';
import '../../models/workout.dart';
import '../../models/article.dart';
import '../../models/user.dart';
import '../../controllers/userController.dart';
import '../../widgets/bottom_nav.dart';
import '../profile/profile_page.dart';
import '../profile/settings_page.dart';
import '../goal/goals_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final authUser = auth.FirebaseAuth.instance.currentUser;
    if (authUser != null) {
      final user = await UserDao().getUser(authUser.uid);
      if (mounted) {
        setState(() {
          currentUser = user;
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
      Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsPage()));
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
        onTap: _onNavTap,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: kYellow))
            : SingleChildScrollView(
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
                    _SectionHeader(title: 'Recent Workouts', onSeeAll: () {}),
                    const SizedBox(height: 12),
                    _RecommendationsRow(onStateChange: () => setState(() {})),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: _WeeklyChallengeBanner(),
                    ),
                    const SizedBox(height: 24),
                    _SectionHeader(title: 'Articles & Tips', onSeeAll: () {}),
                    const SizedBox(height: 12),
                    _ArticlesGrid(onStateChange: () => setState(() {})),
                    const SizedBox(height: 24),
                  ],
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
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.search, color: kPurple, size: 24),
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
  final item;
  const _QuickAccessItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
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

class _RecommendationsRow extends StatelessWidget {
  final VoidCallback onStateChange;
  const _RecommendationsRow({required this.onStateChange});

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
          onFavToggle: () {
            workouts[i].isFavorite = !workouts[i].isFavorite;
            onStateChange();
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

class _ArticlesGrid extends StatelessWidget {
  final VoidCallback onStateChange;
  const _ArticlesGrid({required this.onStateChange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: articles.length,
        itemBuilder: (context, i) => _ArticleCard(
          article: articles[i],
          onFavToggle: () {
            articles[i].isFavorite = !articles[i].isFavorite;
            onStateChange();
          },
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onFavToggle;
  const _ArticleCard({required this.article, required this.onFavToggle});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            article.imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: kCardBg2,
              child: const Icon(Icons.article, color: kPurple),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black87, Colors.transparent],
                stops: [0.0, 0.6],
              ),
            ),
          ),
          Positioned(
            bottom: 10, left: 10, right: 10,
            child: Text(
              article.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
          Positioned(
            top: 8, right: 8,
            child: GestureDetector(
              onTap: onFavToggle,
              child: Icon(
                article.isFavorite ? Icons.star : Icons.star_border,
                color: article.isFavorite ? kYellow : Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
