import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/alphabet_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/matching_game_controller.dart';
import '../controllers/memory_game_controller.dart';
import '../controllers/number_controller.dart';
import '../controllers/quiz_controller.dart';
import '../controllers/spelling_controller.dart';
import '../core/app_constants.dart';
import '../screens/alphabet_screen.dart';
import '../screens/category_screen.dart';
import '../screens/game_select_screen.dart';
import '../screens/home_screen.dart';
import '../screens/matching_game_screen.dart';
import '../screens/memory_game_screen.dart';
import '../screens/number_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/spelling_screen.dart';
import '../screens/wallet_screen.dart';
import '../screens/profile_screen.dart';
import '../controllers/wallet_controller.dart';
import '../screens/admin/admin_panel_screen.dart';
import 'app_routes.dart';

abstract class AppPages {
  static const _dur = Duration(milliseconds: 400);

  static final pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
      transitionDuration: _dur,
    ),
    GetPage(
      name: AppRoutes.alphabet,
      page: () => const AlphabetScreen(),
      binding: BindingsBuilder<AlphabetController>(() {
        Get.put(AlphabetController());
      }),
      transition: Transition.downToUp,
      transitionDuration: _dur,
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.number,
      page: () => const NumberScreen(),
      binding: BindingsBuilder<NumberController>(() {
        Get.put(NumberController());
      }),
      transition: Transition.downToUp,
      transitionDuration: _dur,
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.category,
      page: () => const CategoryScreen(),
      binding: BindingsBuilder<CategoryController>(() {
        Get.put(CategoryController(Get.arguments as CategoryDef));
      }),
      transition: Transition.downToUp,
      transitionDuration: _dur,
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.gameSelect,
      page: () => const GameSelectScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: _dur,
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.quiz,
      page: () => const QuizScreen(),
      binding: BindingsBuilder<QuizController>(() {
        Get.put(QuizController(Get.arguments as CategoryDef));
      }),
      transition: Transition.rightToLeft,
      transitionDuration: _dur,
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.memory,
      page: () => const MemoryGameScreen(),
      binding: BindingsBuilder<MemoryGameController>(() {
        Get.put(MemoryGameController(Get.arguments as CategoryDef));
      }),
      transition: Transition.rightToLeft,
      transitionDuration: _dur,
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.matching,
      page: () => const MatchingGameScreen(),
      binding: BindingsBuilder<MatchingGameController>(() {
        Get.put(MatchingGameController(Get.arguments as CategoryDef));
      }),
      transition: Transition.rightToLeft,
      transitionDuration: _dur,
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.spelling,
      page: () => const SpellingScreen(),
      binding: BindingsBuilder<SpellingController>(() {
        Get.put(SpellingController(Get.arguments as CategoryDef));
      }),
      transition: Transition.rightToLeft,
      transitionDuration: _dur,
      curve: Curves.easeOutCubic,
    ),

    GetPage(
      name: AppRoutes.wallet,
      page: () => const WalletScreen(),
      binding: BindingsBuilder<WalletController>(() {
        Get.put(WalletController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: _dur,
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(showBackButton: true),
      transition: Transition.rightToLeft,
      transitionDuration: _dur,
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.adminPanel,
      page: () => const AdminPanelScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: _dur,
      curve: Curves.easeOutCubic,
    ),
  ];
}
