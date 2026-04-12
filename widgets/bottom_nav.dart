import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../screens/home/home_page.dart';
import '../screens/profile/profile_page.dart';

class AppBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onTap;

  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    this.onTap,
  });

  void _handleTap(BuildContext context, int index) {
    if (onTap != null) {
      onTap!(index);
      return;
    }
    // Default navigation behavior
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (index == 3) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.home_rounded,
      Icons.grid_view_rounded,
      Icons.star_rounded,
      Icons.person,
    ];

    return Container(
      color: kPurple,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(icons.length, (i) {
              final isSelected = i == selectedIndex;
              return GestureDetector(
                onTap: () => _handleTap(context, i),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icons[i],
                        color: isSelected ? Colors.white : Colors.white54,
                        size: 26,
                      ),
                      if (isSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}