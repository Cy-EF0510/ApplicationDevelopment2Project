import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../models/article.dart';
import '../models/quick_access_item.dart';

final List<QuickAccessItem> quickAccessItems = [
  QuickAccessItem(icon: Icons.fitness_center, label: 'Workout'),
  QuickAccessItem(icon: Icons.bar_chart, label: 'Progress\nTracking'),
  QuickAccessItem(icon: Icons.stars, label: 'Achievements'),
  QuickAccessItem(icon: Icons.pin_drop, label: 'Nearby Gyms'),
];

final List<Workout> workouts = [
  Workout(
    title: 'Squat Exercise',
    imagePath: 'assets/squat.jpg',
    duration: '12 Minutes',
    calories: '120 Kcal',
    isFavorite: true,
  ),
  Workout(
    title: 'Full Body Stretching',
    imagePath: 'assets/stretch.jpg',
    duration: '12 Minutes',
    calories: '120 Kcal',
  ),
  Workout(
    title: 'Core Strength',
    imagePath: 'assets/core.jpg',
    duration: '20 Minutes',
    calories: '200 Kcal',
  ),
];

final List<Article> articles = [
  Article(
    title: 'Supplement Guide...',
    imagePath: 'assets/food.jpg',
    isFavorite: true,
  ),
  Article(
    title: '15 Quick & Effective Daily Routines...',
    imagePath: 'assets/healthy.jpg',
  ),
];