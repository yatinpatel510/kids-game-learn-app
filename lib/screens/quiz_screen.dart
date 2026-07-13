import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quiz_controller.dart';
import '../core/app_colors.dart';
import '../core/ad_manager.dart';
import '../controllers/wallet_controller.dart';
import '../widgets/animated_background.dart';
import '../widgets/learn_widgets.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<QuizController>();

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
                if (c.questions.isEmpty) return const Center(child: CircularProgressIndicator());
                if (c.isFinished.value) return _ResultView(c: c);
                return Column(
                  children: [
                    LearnTopBar(title: '${c.def.title} Quiz'),
                    LearnProgressBar(
                      current: c.currentQ.value + 1,
                      total: c.questions.length,
                      activeColor: AppColors.cardGradients[0][0],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _QuestionCard(c: c),
                            _OptionsGrid(c: c),
                            if (c.isAnswered)
                              _NextButton(c: c),
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

class _QuestionCard extends StatelessWidget {
  final QuizController c;
  const _QuestionCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Column(
            children: [
              const Text('Which one is this?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.subtitlePurple)),
              const SizedBox(height: 16),
              Text(c.current.correct.emoji, style: const TextStyle(fontSize: 72)),
            ],
          ),
        ));
  }
}

class _OptionsGrid extends StatelessWidget {
  final QuizController c;
  const _OptionsGrid({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: c.current.options.map((opt) {
            final isSelected = c.selectedAnswer.value == opt.id;
            final isCorrect = opt.id == c.current.correct.id;
            Color bg = Colors.white;
            if (c.isAnswered) {
              if (isCorrect) bg = const Color(0xFF1DD1A1);
              else if (isSelected) bg = const Color(0xFFFF6B6B);
            }
            return GestureDetector(
              onTap: () => c.answer(opt.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Center(
                  child: Text(opt.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c.isAnswered && (isCorrect || isSelected) ? Colors.white : AppColors.titlePurple)),
                ),
              ),
            );
          }).toList(),
        ));
  }
}

class _NextButton extends StatelessWidget {
  final QuizController c;
  const _NextButton({required this.c});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: c.next,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF5F27CD), Color(0xFFA18CD1)]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: const Color(0xFF5F27CD).withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Text(
          c.currentQ.value < c.questions.length - 1 ? 'Next ➡️' : 'Finish 🏁',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final QuizController c;
  const _ResultView({required this.c});

  @override
  Widget build(BuildContext context) {
    final pct = (c.score.value / c.questions.length * 100).toInt();
    final emoji = pct == 100 ? '🏆' : pct >= 70 ? '🌟' : pct >= 40 ? '👍' : '💪';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            Text('$pct%', style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: AppColors.titlePurple)),
            const SizedBox(height: 8),
            Text('${c.score.value} / ${c.questions.length} correct', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.subtitlePurple)),
            
            Obx(() => Container(
              margin: const EdgeInsets.symmetric(vertical: 24),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        'You earned ${c.earnedCoins.value} Coins!',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFFFA500)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (!c.isDoubleRewarded.value)
                    GestureDetector(
                      onTap: () {
                        AdManager.instance.showRewardedAd(
                          onEarnedReward: () {
                            Get.find<WalletController>().addCoins(c.earnedCoins.value, 'Double Reward: Quiz Completed 📺');
                            c.isDoubleRewarded.value = true;
                            c.earnedCoins.value *= 2;
                            Get.snackbar(
                              '🎉 Coins Doubled!',
                              'Successfully added double rewards to your wallet!',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFF1DD1A1),
                              colorText: Colors.white,
                              borderRadius: 12,
                            );
                          },
                          onAdDismissed: () {},
                          onAdFailed: () {
                            Get.snackbar(
                              'Ad Not Ready',
                              'Please try again in a few seconds.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFFFECA57),
                              colorText: Colors.white,
                              borderRadius: 12,
                            );
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF5F27CD), Color(0xFFA18CD1)]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_circle_fill, color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Double Reward (Watch Ad)',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Color(0xFF1DD1A1), size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Reward Doubled! 🎉',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF159E7A)),
                        ),
                      ],
                    ),
                ],
              ),
            )),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionBtn(label: '🔄 Retry', onTap: c.restart, colors: [const Color(0xFF4FACFE), const Color(0xFF00F2FE)]),
                const SizedBox(width: 16),
                _ActionBtn(label: '🏠 Home', onTap: () => Get.until((r) => r.isFirst), colors: [const Color(0xFFA18CD1), const Color(0xFFFBC2EB)]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final List<Color> colors;
  const _ActionBtn({required this.label, required this.onTap, required this.colors});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: colors[0].withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
      ),
    );
  }
}
