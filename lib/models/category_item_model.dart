class CategoryItem {
  final String id;
  final String name;
  final String emoji;
  final String fact;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.fact,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: (json['emoji'] as String?) ?? '',
      fact: (json['fact'] as String?) ?? '',
    );
  }

  String get speakText => '$name. $fact';
}
