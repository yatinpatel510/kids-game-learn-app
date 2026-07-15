import 'package:flutter/material.dart';
import 'app_colors.dart';

const adMobAppId = "ca-app-pub-6951054569176297~6773578868"; //Live Android
// const adMobAppId = "ca-app-pub-3940256099942544~3347511713"; //Testing Android

const adMobUnitId = "ca-app-pub-6951054569176297/1161591314"; //Live Android
// const adMobUnitId = "ca-app-pub-3940256099942544/5224354917"; //Testing Android Rewarded

class CategoryDef {
  final String id;
  final String title;
  final String emoji;
  final String jsonFile;
  final List<Color> gradient;

  const CategoryDef({
    required this.id,
    required this.title,
    required this.emoji,
    required this.jsonFile,
    required this.gradient,
  });
}

abstract class AppConstants {
  // Learn categories shown on home
  static final learnCategories = [
    CategoryDef(
      id: 'alphabets',
      title: 'Alphabets',
      emoji: '🔤',
      jsonFile: 'alphabets.json',
      gradient: AppColors.cardGradients[2],
    ),
    CategoryDef(
      id: 'numbers',
      title: 'Numbers',
      emoji: '🔢',
      jsonFile: 'numbers.json',
      gradient: AppColors.cardGradients[4],
    ),
    CategoryDef(
      id: 'fruits',
      title: 'Fruits',
      emoji: '🍎',
      jsonFile: 'fruits.json',
      gradient: AppColors.cardGradients[0],
    ),
    CategoryDef(
      id: 'vegetables',
      title: 'Vegetables',
      emoji: '🥕',
      jsonFile: 'vegetables.json',
      gradient: AppColors.cardGradients[1],
    ),
    CategoryDef(
      id: 'animals',
      title: 'Animals',
      emoji: '🦁',
      jsonFile: 'animals.json',
      gradient: AppColors.cardGradients[6],
    ),
    CategoryDef(
      id: 'birds',
      title: 'Birds',
      emoji: '🦜',
      jsonFile: 'birds.json',
      gradient: AppColors.cardGradients[3],
    ),
    CategoryDef(
      id: 'vehicles',
      title: 'Vehicles',
      emoji: '🚗',
      jsonFile: 'vehicles.json',
      gradient: AppColors.cardGradients[7],
    ),
    CategoryDef(
      id: 'body_parts',
      title: 'Body Parts',
      emoji: '👀',
      jsonFile: 'body_parts.json',
      gradient: AppColors.cardGradients[8],
    ),
    CategoryDef(
      id: 'colors',
      title: 'Colors',
      emoji: '🎨',
      jsonFile: 'colors_shapes.json',
      gradient: AppColors.cardGradients[5],
    ),
    CategoryDef(
      id: 'days_months',
      title: 'Days & Months',
      emoji: '📅',
      jsonFile: 'days_months.json',
      gradient: AppColors.cardGradients[9],
    ),
    CategoryDef(
      id: 'gk',
      title: 'General Knowledge',
      emoji: '🌍',
      jsonFile: 'gk.json',
      gradient: AppColors.cardGradients[1],
    ),
  ];

  // Game-compatible categories (have id + emoji + fact fields)
  static List<CategoryDef> get gameCategories => learnCategories
      .where((c) => !['alphabets', 'numbers'].contains(c.id))
      .toList();
  static final games = [
    {
      'id': 'quiz',
      'title': 'Quiz',
      'emoji': '❓',
      'gradient': AppColors.cardGradients[0],
    },
    {
      'id': 'memory',
      'title': 'Memory Game',
      'emoji': '🧠',
      'gradient': AppColors.cardGradients[4],
    },
    {
      'id': 'matching',
      'title': 'Matching Game',
      'emoji': '🎯',
      'gradient': AppColors.cardGradients[6],
    },
    {
      'id': 'spelling',
      'title': 'Spell It!',
      'emoji': '✏️',
      'gradient': AppColors.cardGradients[2],
    },
  ];
}
