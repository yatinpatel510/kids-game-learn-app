import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/app_colors.dart';
import '../core/app_constants.dart';
import '../routes/app_routes.dart';
import '../widgets/animated_background.dart';
import '../widgets/learn_widgets.dart';

class GameSelectScreen extends StatelessWidget {
  const GameSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameId = Get.arguments as String;
    final gameInfo = AppConstants.games.firstWhere((g) => g['id'] == gameId);

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
              child: Column(
                children: [
                  LearnTopBar(title: '${gameInfo['emoji']} ${gameInfo['title']}'),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Text('Pick a category to play!', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.subtitlePurple)),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.1,
                      ),
                      itemCount: AppConstants.gameCategories.length,
                      itemBuilder: (_, i) {
                        final cat = AppConstants.gameCategories[i];
                        return GestureDetector(
                          onTap: () {
                            if (gameId == 'quiz') {
                              Get.toNamed(AppRoutes.quiz, arguments: cat);
                            } else if (gameId == 'memory') {
                              Get.toNamed(AppRoutes.memory, arguments: cat);
                            } else if (gameId == 'matching') {
                              Get.toNamed(AppRoutes.matching, arguments: cat);
                            } else if (gameId == 'spelling') {
                              Get.toNamed(AppRoutes.spelling, arguments: cat);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: cat.gradient),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [BoxShadow(color: cat.gradient[0].withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 5))],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(cat.emoji, style: const TextStyle(fontSize: 40)),
                                const SizedBox(height: 8),
                                Text(cat.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
