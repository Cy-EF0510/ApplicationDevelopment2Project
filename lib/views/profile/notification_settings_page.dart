import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/bottom_nav.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final _items = [
    {'label': 'General Notification', 'value': true, 'color': 'purple'},
    {'label': 'Sound', 'value': true, 'color': 'purple'},
    {'label': "Don't Disturb Mode", 'value': true, 'color': 'purple'},
    {'label': 'Vibrate', 'value': true, 'color': 'yellow'},
    {'label': 'Lock Screen', 'value': true, 'color': 'yellow'},
    {'label': 'Reminders', 'value': true, 'color': 'purple'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          _SimpleHeader(title: 'Notifications Settings'),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
              itemBuilder: (_, i) {
                final item = _items[i];
                return SwitchListTile(
                  value: item['value'] as bool,
                  activeColor: item['color'] == 'yellow' ? kYellow : kPurple,
                  onChanged: (v) => setState(() => _items[i]['value'] = v),
                  title: Text(
                    item['label'] as String,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                );
              },
            ),
          ),
          const AppBottomNav(selectedIndex: 2),
        ],
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