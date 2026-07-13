import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/number_controller.dart';
import '../core/app_colors.dart';
import '../widgets/animated_background.dart';
import '../widgets/learn_widgets.dart';

class NumberScreen extends StatelessWidget {
  const NumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<NumberController>();

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
                final size = MediaQuery.of(context).size;
                final n = c.current.number;
                final fontSize = n >= 100
                    ? size.width * 0.16
                    : n >= 10
                    ? size.width * 0.20
                    : size.width * 0.28;
                return Column(
                  children: [
                    const LearnTopBar(title: 'Numbers'),
                    LearnProgressBar(
                      current: c.index.value + 1,
                      total: c.total,
                      activeColor: c.current.gradient[0],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ScaleTransition(
                              scale: c.cardScale,
                              child: LearnMainCard(
                                text: '$n',
                                gradient: c.current.gradient,
                                fontSize: fontSize,
                              ),
                            ),
                            LearnWordLabel(word: c.current.word),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                LearnNavButton(
                                  icon: Icons.arrow_back_ios_new_rounded,
                                  onTap: c.index.value > 0 ? c.prev : null,
                                ),
                                LearnSpeakButton(
                                  isSpeaking: c.isSpeaking.value,
                                  color: c.current.gradient[0],
                                  onTap: c.speak,
                                ),
                                LearnNavButton(
                                  icon: Icons.arrow_forward_ios_rounded,
                                  onTap: c.index.value < c.total - 1
                                      ? c.next
                                      : null,
                                ),
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
