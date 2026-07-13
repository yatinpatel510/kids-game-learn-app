import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/matching_game_controller.dart';
import '../core/app_colors.dart';
import '../core/ad_manager.dart';
import '../controllers/wallet_controller.dart';
import '../widgets/animated_background.dart';
import '../widgets/learn_widgets.dart';

class MatchingGameScreen extends StatelessWidget {
  const MatchingGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MatchingGameController>();

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
                if (c.pairs.isEmpty) return const Center(child: CircularProgressIndicator());
                if (c.isFinished.value) return _FinishedView(c: c);
                return Column(
                  children: [
                    LearnTopBar(title: 'Matching'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatChip(label: 'Matched', value: '${c.matchedCount}/${c.pairs.length}', color: const Color(0xFF1DD1A1)),
                          _StatChip(label: 'Moves', value: '${c.moves.value}', color: const Color(0xFFFF6B6B)),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Emoji', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.subtitlePurple)),
                          Text('Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.subtitlePurple)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.builder(
                          itemCount: c.pairs.length,
                          itemBuilder: (_, i) {
                            final emojiPairIdx = c.emojiOrder[i];
                            final namePairIdx = c.nameOrder[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(child: _EmojiTile(c: c, pairIndex: emojiPairIdx)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _NameTile(c: c, pairIndex: namePairIdx)),
                                ],
                              ),
                            );
                          },
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

class _EmojiTile extends StatelessWidget {
  final MatchingGameController c;
  final int pairIndex;
  const _EmojiTile({required this.c, required this.pairIndex});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pair = c.pairs[pairIndex];
      final isSelected = c.selectedEmoji.value == pairIndex;
      final isMatched = pair.emojiMatched;
      return GestureDetector(
        onTap: isMatched ? null : () => c.tapEmoji(pairIndex),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isMatched
                  ? [const Color(0xFF1DD1A1), const Color(0xFF43E97B)]
                  : isSelected
                      ? [const Color(0xFF5F27CD), const Color(0xFFA18CD1)]
                      : [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Center(
            child: Text(pair.item.emoji, style: const TextStyle(fontSize: 30)),
          ),
        ),
      );
    });
  }
}

class _NameTile extends StatelessWidget {
  final MatchingGameController c;
  final int pairIndex;
  const _NameTile({required this.c, required this.pairIndex});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pair = c.pairs[pairIndex];
      final isSelected = c.selectedName.value == pairIndex;
      final isMatched = pair.nameMatched;
      return GestureDetector(
        onTap: isMatched ? null : () => c.tapName(pairIndex),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 64,
          decoration: BoxDecoration(
            color: isMatched
                ? const Color(0xFF1DD1A1)
                : isSelected
                    ? const Color(0xFF5F27CD)
                    : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Center(
            child: Text(
              pair.item.name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isMatched || isSelected ? Colors.white : AppColors.titlePurple,
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
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

class _FinishedView extends StatelessWidget {
  final MatchingGameController c;
  const _FinishedView({required this.c});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎯', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          const Text('Perfect Match!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.titlePurple)),
          const SizedBox(height: 8),
          Text('Done in ${c.moves.value} moves', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.subtitlePurple)),
          
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
                          Get.find<WalletController>().addCoins(c.earnedCoins.value, 'Double Reward: Match Completed 📺');
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
