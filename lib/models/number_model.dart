import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class NumberModel {
  final int number;
  final String word;
  final List<Color> gradient;

  const NumberModel({
    required this.number,
    required this.word,
    required this.gradient,
  });

  factory NumberModel.fromJson(Map<String, dynamic> json) {
    final n = json['number'] as int;
    return NumberModel(
      number: n,
      word: json['word'] as String,
      gradient: AppColors.cardGradients[(n - 1) % AppColors.cardGradients.length],
    );
  }

  String get speakText => word;
}
