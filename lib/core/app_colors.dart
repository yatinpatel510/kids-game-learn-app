import 'package:flutter/material.dart';

abstract class AppColors {
  // background gradient
  static const bgGradient = [Color(0xFFFFF9C4), Color(0xFFE1F5FE), Color(0xFFF8BBD9)];

  // text
  static const titlePurple = Color(0xFF5F27CD);
  static const subtitlePurple = Color(0xFF7B5EA7);
  static const progressRed = Color(0xFFFF6B6B);

  // word label letter colors (cycling)
  static const wordLetterColors = [
    Color(0xFFFF6B6B), Color(0xFFFF9F43), Color(0xFF54A0FF), Color(0xFF5F27CD),
    Color(0xFF00D2D3), Color(0xFF1DD1A1), Color(0xFFFECA57), Color(0xFFEE5A24),
  ];

  // card gradients (cycling for numbers / home cards)
  static const cardGradients = [
    [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    [Color(0xFF4ECDC4), Color(0xFF44A08D)],
    [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
    [Color(0xFFFDDB92), Color(0xFFD1FDFF)],
    [Color(0xFF89F7FE), Color(0xFF66A6FF)],
    [Color(0xFF43E97B), Color(0xFF38F9D7)],
    [Color(0xFFF093FB), Color(0xFFF5576C)],
    [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    [Color(0xFFFA709A), Color(0xFFFEE140)],
    [Color(0xFF30CFD0), Color(0xFF330867)],
  ];

  // home screen cards
  static const alphabetCardGradient = [Color(0xFFA18CD1), Color(0xFFFBC2EB)];
  static const numberCardGradient   = [Color(0xFF4FACFE), Color(0xFF00F2FE)];

  // nav button
  static const navButton = Color(0xFF7B5EA7);
  static const voiceSelected = Color(0xFF7B5EA7);
  static const voiceSelectedBg = Color(0xFFF3EEFF);
}
