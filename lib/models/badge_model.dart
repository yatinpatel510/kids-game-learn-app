class BadgeModel {
  final String id;
  final String title;
  final String emoji;
  final String description;
  final bool earned;

  const BadgeModel({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    this.earned = false,
  });

  static const all = [
    BadgeModel(id: 'first_step',   title: 'First Step',    emoji: '👶', description: 'Complete your first lesson'),
    BadgeModel(id: 'abc_master',   title: 'ABC Master',    emoji: '🔤', description: 'Complete all Alphabets'),
    BadgeModel(id: 'number_star',  title: 'Number Star',   emoji: '🔢', description: 'Complete all Numbers'),
    BadgeModel(id: 'fruit_lover',  title: 'Fruit Lover',   emoji: '🍎', description: 'Complete Fruits'),
    BadgeModel(id: 'animal_lover', title: 'Animal Lover',  emoji: '🦁', description: 'Complete Animals'),
    BadgeModel(id: 'quiz_champ',   title: 'Quiz Champ',    emoji: '🏆', description: 'Score 100% in a quiz'),
    BadgeModel(id: 'memory_king',  title: 'Memory King',   emoji: '🧠', description: 'Complete Memory Game'),
    BadgeModel(id: 'all_rounder',  title: 'All Rounder',   emoji: '🌟', description: 'Complete 5 categories'),
    BadgeModel(id: 'level_5',      title: 'Level 5',       emoji: '🎯', description: 'Reach Level 5'),
    BadgeModel(id: 'level_10',     title: 'Level 10',      emoji: '🔥', description: 'Reach Level 10'),
    BadgeModel(id: 'level_20',     title: 'Level 20',      emoji: '👑', description: 'Reach Level 20'),
  ];

  BadgeModel copyWith({bool? earned}) => BadgeModel(
    id: id, title: title, emoji: emoji, description: description,
    earned: earned ?? this.earned,
  );
}
