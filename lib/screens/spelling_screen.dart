import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/spelling_controller.dart';
import '../core/app_colors.dart';
import '../widgets/animated_background.dart';
import '../widgets/learn_widgets.dart';

class SpellingScreen extends StatelessWidget {
  const SpellingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SpellingController>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.bgGradient,
          ),
        ),
        child: Stack(
          children: [
            const AnimatedBackground(),
            SafeArea(
              child: Obx(() {
                if (c.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Column(
                  children: [
                    LearnTopBar(title: 'Spell It!'),
                    _ScoreBar(c: c),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _EmojiHint(c: c),
                            _AnswerSlots(c: c),
                            _LetterGrid(c: c),
                            _BottomButtons(c: c),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final SpellingController c;
  const _ScoreBar({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${c.currentIndex.value + 1} / ${c.total}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.subtitlePurple,
              ),
            ),
            Text(
              '⭐ ${c.score.value}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.titlePurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmojiHint extends StatelessWidget {
  final SpellingController c;
  const _EmojiHint({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: c.speakCurrent,
        child: Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  AppColors.cardGradients[c.currentIndex.value %
                      AppColors.cardGradients.length],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                c.current.emoji.isEmpty ? '🔊' : c.current.emoji,
                style: const TextStyle(fontSize: 52),
              ),
              const SizedBox(height: 4),
              const Text(
                '🔊 Tap to hear',
                style: TextStyle(fontSize: 10, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerSlots extends StatelessWidget {
  final SpellingController c;
  const _AnswerSlots({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final target = c.current.name.toUpperCase().split('');
      final tapped = c.tappedLetters;
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 6,
        runSpacing: 6,
        children: List.generate(target.length, (i) {
          final filled = i < tapped.length;
          final wrong = c.isWrong.value && filled;
          return Container(
            width: 36,
            height: 44,
            decoration: BoxDecoration(
              color: c.isCorrect.value
                  ? const Color(0xFF1DD1A1)
                  : wrong
                  ? const Color(0xFFFF6B6B)
                  : filled
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                filled ? tapped[i] : '_',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: c.isCorrect.value || wrong
                      ? Colors.white
                      : AppColors.titlePurple,
                ),
              ),
            ),
          );
        }),
      );
    });
  }
}

class _LetterGrid extends StatelessWidget {
  final SpellingController c;
  const _LetterGrid({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: c.shuffledLetters.map((letter) {
          return GestureDetector(
            onTap: c.isCorrect.value ? null : () => c.tapLetter(letter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA18CD1).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  letter,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BottomButtons extends StatelessWidget {
  final SpellingController c;
  const _BottomButtons({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Backspace
          GestureDetector(
            onTap: c.removeLast,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.backspace_rounded,
                color: AppColors.subtitlePurple,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Next
          if (c.isCorrect.value)
            GestureDetector(
              onTap: c.next,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1DD1A1), Color(0xFF43E97B)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1DD1A1).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'Next ➡️',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
