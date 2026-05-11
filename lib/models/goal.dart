import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class Goal {
  final String? id;
  final String title;
  final GoalCategory category;
  final String timeFrame;
  List<Task> tasks;
  bool isCompleted;

  Goal({
    this.id,
    required this.title,
    required this.category,
    required this.timeFrame,
    required this.tasks,
    this.isCompleted = false,
  });

  double get progress {
    if (tasks.isEmpty) return 0;
    return tasks.where((t) => t.isComplete).length / tasks.length;
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'category': category.name,
    'timeFrame': timeFrame,
    'tasks': tasks.map((t) => t.toMap()).toList(),
    'isCompleted': isCompleted,
  };

  factory Goal.fromMap(String id, Map<String, dynamic> map) => Goal(
    id: id,
    title: map['title'] ?? '',
    category: kCategories.firstWhere(
          (c) => c.name == map['category'],
      orElse: () => kCategories.first,
    ),
    timeFrame: map['timeFrame'] ?? '',
    tasks: (map['tasks'] as List<dynamic>? ?? [])
        .map((t) => Task.fromMap(t as Map<String, dynamic>))
        .toList(),
    isCompleted: map['isCompleted'] ?? false,
  );
}

class Task {
  final String title;
  bool isComplete;

  Task({required this.title,
    this.isComplete = false});

  Map<String, dynamic> toMap() => {
    'title': title,
    'isComplete': isComplete,
  };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
    title: map['title'] ?? '',
    isComplete: map['isComplete'] ?? false,
  );
}

class GoalCategory {
  final String name;
  final Color color;

  const GoalCategory({
    required this.name,
    required this.color,
  });
}

const kCategories = [
  GoalCategory(name: 'Chest', color: kPurple),
  GoalCategory(name: 'Back', color: kPurple),
  GoalCategory(name: 'Legs', color: kOrange),
  GoalCategory(name: 'Shoulders', color: kPurple),
  GoalCategory(name: 'Cardio', color: kOrange),
  GoalCategory(name: 'Core', color: kYellow),
];

GoalCategory categoryFor(String name) =>
    kCategories.firstWhere((c) => c.name == name,
        orElse: () => kCategories.first);