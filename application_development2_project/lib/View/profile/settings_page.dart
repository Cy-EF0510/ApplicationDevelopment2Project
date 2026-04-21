import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/bottom_nav.dart';
import 'notification_settings_page.dart';
import 'password_settings_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          const _SimpleHeader(title: 'Settings'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 8),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  label: 'Notification Setting',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationSettingsPage()),
                  ),
                ),
                const SizedBox(height: 10),
                _SettingsTile(
                  icon: Icons.key_outlined,
                  label: 'Password Setting',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PasswordSettingsPage()),
                  ),
                ),
                const SizedBox(height: 10),
                _SettingsTile(
                  icon: Icons.person_remove_outlined,
                  label: 'Delete Account',
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: kCardBg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text(
                        'Delete Account',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      content: const Text('This cannot be undone.', style: TextStyle(color: Colors.white70)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel', style: TextStyle(color: kPurple)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const AppBottomNav(selectedIndex: 3),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: const BoxDecoration(color: kPurple, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15))),
            const Icon(Icons.keyboard_arrow_down, color: kYellow, size: 22),
          ],
        ),
      ),
    );
  }
}

class _SimpleHeader extends StatelessWidget {
  final String title;
  const _SimpleHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPurple,
      width: double.infinity,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}