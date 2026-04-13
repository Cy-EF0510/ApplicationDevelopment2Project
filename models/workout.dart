class Workout {
  final String title;
  final String imagePath;
  final String duration;
  final String calories;
  bool isFavorite;

  Workout({
    required this.title,
    required this.imagePath,
    required this.duration,
    required this.calories,
    this.isFavorite = false,
  });
}