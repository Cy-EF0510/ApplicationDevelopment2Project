class Article {
  final String title;
  final String imagePath;
  bool isFavorite;

  Article({
    required this.title,
    required this.imagePath,
    this.isFavorite = false,
  });
}