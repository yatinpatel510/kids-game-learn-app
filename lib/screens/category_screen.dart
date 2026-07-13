import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';
import '../core/app_colors.dart';
import '../widgets/animated_background.dart';
import '../widgets/learn_widgets.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CategoryController>();
    final size = MediaQuery.of(context).size;

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
                    LearnTopBar(title: c.def.title),
                    LearnProgressBar(
                      current: c.index.value + 1,
                      total: c.total,
                      activeColor: c.def.gradient[0],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Emoji card
                            _EmojiCard(emoji: c.current.emoji, size: size, gradient: c.def.gradient),
                            // Name label
                            LearnWordLabel(word: c.current.name),
                            // Fact bubble
                            _FactBubble(fact: c.current.fact),
                            // Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                LearnNavButton(icon: Icons.arrow_back_ios_new_rounded, onTap: c.index.value > 0 ? c.prev : null),
                                LearnSpeakButton(isSpeaking: c.isSpeaking.value, color: c.def.gradient[0], onTap: c.speak),
                                LearnNavButton(icon: Icons.arrow_forward_ios_rounded, onTap: c.index.value < c.total - 1 ? c.next : null),
                              ],
                            ),
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

class _EmojiCard extends StatelessWidget {
  final String emoji;
  final Size size;
  final List<Color> gradient;
  const _EmojiCard({required this.emoji, required this.size, required this.gradient});

  @override
  Widget build(BuildContext context) {
    final w = size.width * 0.55;
    return Container(
      width: w, height: w,
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradient),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: gradient[0].withValues(alpha: 0.5), blurRadius: 30, offset: const Offset(0, 12))],
      ),
      child: Center(child: Text(emoji, style: TextStyle(fontSize: size.width * 0.25))),
    );
  }
}

class _FactBubble extends StatelessWidget {
  final String fact;
  const _FactBubble({required this.fact});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💡', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(fact, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF5F27CD))),
          ),
        ],
      ),
    );
  }
}
