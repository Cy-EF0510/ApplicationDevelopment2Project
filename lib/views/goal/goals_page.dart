import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../widgets/bottom_nav.dart';
import '../../../widgets/add_goal.dart';
import '../../../models/goal.dart';
import '../../../controllers/goalController.dart';
import '../profile/profile_page.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final _goalsService = GoalsService();
  String _selectedFilter = 'All';
  int? _expandedIndex;

  static const _filters = [
    'All', 'Chest', 'Back', 'Legs', 'Shoulders', 'Cardio', 'Core'
  ];

  @override
  void initState() {
    super.initState();
  }

  void _toggleTask(Goal goal, int taskIndex) {
    _goalsService.toggleTask(goal, taskIndex);
  }

  void _openAddGoal() async {
    final newGoal = await showModalBottomSheet<Goal>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddGoalSheet(),
    );
    if (newGoal != null) {
      _goalsService.addGoal(newGoal);
    }
  }

  void _deleteGoal(Goal goal) {
    _goalsService.deleteGoal(goal.id!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${goal.title}" deleted'),
        backgroundColor: kCardBg2,
        action: SnackBarAction(
          label: 'Undo',
          textColor: kPurpleLight,
          onPressed: () => _goalsService.addGoal(goal),
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (index == 2) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      bottomNavigationBar: AppBottomNav(
        selectedIndex: 1,
        onTap: _onNavTap,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildFilterRow(),
            Expanded(
              child: StreamBuilder<List<Goal>>(
                stream: _goalsService.goalsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: kPurple),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Something went wrong',
                        style: TextStyle(color: Colors.white.withOpacity(0.5)),
                      ),
                    );
                  }

                  final goals = snapshot.data ?? [];

                  final activeGoals = goals
                      .where((g) => !g.isCompleted)
                      .where((g) =>
                  _selectedFilter == 'All' ||
                      g.category.name == _selectedFilter)
                      .toList();

                  final completedGoals = goals
                      .where((g) => g.isCompleted)
                      .where((g) =>
                  _selectedFilter == 'All' ||
                      g.category.name == _selectedFilter)
                      .toList();

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      _buildStreakBanner(),
                      if (activeGoals.isNotEmpty) ...[
                        _buildSectionLabel('In Progress'),
                        ...activeGoals.map((g) => _buildGoalCard(g)),
                      ],
                      if (completedGoals.isNotEmpty) ...[
                        _buildSectionLabel('Completed'),
                        ...completedGoals.map(
                              (g) => _buildGoalCard(g, completed: true),
                        ),
                      ],
                      if (activeGoals.isEmpty && completedGoals.isEmpty)
                        _buildEmptyState(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: StreamBuilder<List<Goal>>(
              stream: _goalsService.goalsStream(),
              builder: (context, snapshot) {
                final count =
                    snapshot.data?.where((g) => !g.isCompleted).length ?? 0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Goals',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$count active this month',
                      style: TextStyle(
                        fontSize: 13,
                        color: kPurple.withOpacity(0.6),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          GestureDetector(
            onTap: _openAddGoal,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = _filters[i];
          final active = _selectedFilter == f;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedFilter = f;
              _expandedIndex = null;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active ? kPurple.withOpacity(0.13) : kCardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? kPurple : kCardBg2,
                  width: 1,
                ),
              ),
              child: Text(
                f,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: active ? kPurpleLight : kPurple.withOpacity(0.5),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStreakBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kCardBg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kYellow.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('🔥', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'x-day streak',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: kYellow,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Keep it going — check off a task today',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.27),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: kPurple.withOpacity(0.4),
          letterSpacing: 0.1 * 11,
        ),
      ),
    );
  }

  Widget _buildGoalCard(Goal goal, {bool completed = false}) {
    final cat = goal.category;
    final isExpanded = _expandedIndex == goal.id.hashCode;

    return Dismissible(
      key: ValueKey(goal.id ?? goal.title),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteGoal(goal),
      background: _buildDeleteBackground(),
      child: GestureDetector(
        onTap: () => setState(
              () => _expandedIndex = isExpanded ? null : goal.id.hashCode,
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: completed ? 0.5 : 1.0,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isExpanded
                    ? kPurple.withOpacity(0.27)
                    : kPurple.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal.title,
                              style: const TextStyle(
                                fontFamily: 'Syne',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  goal.category.name,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: cat.color,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: kPurple.withOpacity(0.27),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  goal.timeFrame,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.27),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (!completed)
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 250),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: cat.color.withOpacity(0.6),
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: goal.progress,
                            minHeight: 4,
                            backgroundColor: kCardBg2,
                            valueColor:
                            AlwaysStoppedAnimation<Color>(cat.color),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 34,
                        child: Text(
                          '${(goal.progress * 100).round()}%',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: cat.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!completed && isExpanded) _buildTaskList(goal),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFF3B30),
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(
        Icons.delete_outline_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildTaskList(Goal goal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(color: Color(0x1A8B7FFF), thickness: 1, height: 1),
        ),
        Text(
          'TASKS',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: kPurple.withOpacity(0.35),
            letterSpacing: 0.08 * 10,
          ),
        ),
        const SizedBox(height: 8),
        ...goal.tasks.asMap().entries.map((entry) {
          final i = entry.key;
          final task = entry.value;
          return GestureDetector(
            onTap: () => _toggleTask(goal, i),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: task.isComplete ? kPurple : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: task.isComplete
                            ? kPurple
                            : kPurple.withOpacity(0.27),
                        width: 1.5,
                      ),
                    ),
                    child: task.isComplete
                        ? const Icon(Icons.check, color: Colors.white, size: 11)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 13,
                        color: task.isComplete
                            ? Colors.white.withOpacity(0.27)
                            : Colors.white.withOpacity(0.8),
                        decoration: task.isComplete
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: Colors.white.withOpacity(0.27),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            const Text('🎯', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              'No goals yet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap + to set your first goal',
              style: TextStyle(
                color: Colors.white.withOpacity(0.25),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}