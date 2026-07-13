import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/memory_game_controller.dart';
import '../core/app_colors.dart';
import '../core/ad_manager.dart';
import '../controllers/wallet_controller.dart';
import '../widgets/animated_background.dart';
import '../widgets/learn_widgets.dart';

class MemoryGameScreen extends StatelessWidget {
  const MemoryGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MemoryGameController>();

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
                if (c.cards.isEmpty) return const Center(child: CircularProgressIndicator());
                if (c.isFinished.value) return _FinishedView(c: c);
                return Column(
                  children: [
                    LearnTopBar(title: 'Memory'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatChip(label: 'Pairs', value: '${c.matchedCount}/${c.totalPairs}', color: const Color(0xFF1DD1A1)),
                          _StatChip(label: 'Moves', value: '${c.moves.value}', color: const Color(0xFFFF6B6B)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10,
                          ),
                          itemCount: c.cards.length,
                          itemBuilder: (_, i) => _MemoryCard(card: c.cards[i], onTap: () => c.flipCard(i)),
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

class _MemoryCard extends StatelessWidget {
  final MemoryCard card;
  final VoidCallback onTap;
  const _MemoryCard({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final show = card.isFlipped || card.isMatched;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: card.isMatched
                ? [const Color(0xFF1DD1A1), const Color(0xFF43E97B)]
                : show
                    ? [const Color(0xFFA18CD1), const Color(0xFFFBC2EB)]
                    : [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Center(
          child: show
              ? Text(
                  card.isEmoji ? card.item.emoji : card.item.name,
                  style: TextStyle(fontSize: card.isEmoji ? 28 : 11, fontWeight: FontWeight.w800, color: Colors.white),
                  textAlign: TextAlign.center,
                )
              : const Text('?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(width: 6),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
        ],
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

class _FinishedView extends StatelessWidget {
  final MemoryGameController c;
  const _FinishedView({required this.c});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🧠', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          const Text('Well Done!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.titlePurple)),
          const SizedBox(height: 8),
          Text('Completed in ${c.moves.value} moves', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.subtitlePurple)),
          
          Obx(() => Container(
            margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
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
                          Get.find<WalletController>().addCoins(c.earnedCoins.value, 'Double Reward: Memory Completed 📺');
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
              _ActionBtn(label: '🔄 Play Again', onTap: c.restart, colors: [const Color(0xFF4FACFE), const Color(0xFF00F2FE)]),
              const SizedBox(width: 16),
              _ActionBtn(label: '🏠 Home', onTap: () => Get.until((r) => r.isFirst), colors: [const Color(0xFFA18CD1), const Color(0xFFFBC2EB)]),
            ],
          ),
        ],
      ),
    );
  }
}
