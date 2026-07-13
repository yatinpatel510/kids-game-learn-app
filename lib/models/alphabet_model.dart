import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class AlphabetModel {
  final String letter;
  final String word;
  final String emoji;
  final List<Color> gradient;

  const AlphabetModel({
    required this.letter,
    required this.word,
    required this.emoji,
    required this.gradient,
  });

  factory AlphabetModel.fromJson(Map<String, dynamic> json) {
    final String letter = (json['letter'] ?? json['id'] ?? '').toString();
    final String word = (json['word'] ?? json['title'] ?? '').toString();
    final String emoji = (json['emoji'] ?? '').toString();

    final int charCode = letter.isNotEmpty ? letter.codeUnitAt(0) : 0;
    final List<Color> resolvedGradient =
        AppColors.cardGradients[charCode % AppColors.cardGradients.length];

    return AlphabetModel(
      letter: letter,
      word: word,
      emoji: emoji,
      gradient: resolvedGradient,
    );
  }

  String get speakText => '$letter for $word';
}
