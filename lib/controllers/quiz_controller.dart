import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import '../models/category_item_model.dart';
import '../core/app_constants.dart';
import 'wallet_controller.dart';
import '../core/firestore_service.dart';
import 'package:flutter/foundation.dart';

class QuizQuestion {
  final CategoryItem correct;
  final List<CategoryItem> options;

  QuizQuestion({required this.correct, required this.options});
}

class QuizController extends GetxController {
  final CategoryDef def;
  QuizController(this.def);

  final _tts = FlutterTts();
  final _rng = Random();

  final questions = <QuizQuestion>[].obs;
  final currentQ = 0.obs;
  final selectedAnswer = Rxn<String>();
  final score = 0.obs;
  final isFinished = false.obs;
  final earnedCoins = 0.obs;
  final isDoubleRewarded = false.obs;

  QuizQuestion get current => questions[currentQ.value];
  bool get isAnswered => selectedAnswer.value != null;

  @override
  void onInit() {
    super.onInit();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    const int quizQuestions = 5;
    const int quizOptions = 3;
    final list = await FirestoreService.instance.fetchCategoryItems(def);
    final all = list.map(CategoryItem.fromJson).toList();
    all.shuffle(_rng);
    final pool = all.take(quizQuestions).toList();
    questions.value = pool.map((correct) {
      final wrong = (all.where((i) => i.id != correct.id).toList()..shuffle(_rng))
          .take(quizOptions - 1)
          .toList();
      final opts = [...wrong, correct]..shuffle(_rng);
      return QuizQuestion(correct: correct, options: opts);
    }).toList();
  }

  void answer(String itemId) {
    if (isAnswered) return;
    selectedAnswer.value = itemId;
    if (itemId == current.correct.id) {
      score.value++;
      _tts.speak('Correct!');
    } else {
      _tts.speak('Try again!');
    }
  }

  void next() {
    if (currentQ.value < questions.length - 1) {
      currentQ.value++;
      selectedAnswer.value = null;
    } else {
      isFinished.value = true;
      _onFinish();
    }
  }

  void _onFinish() {
    final pct = score.value / questions.length;

    // Calculate and award coins
    earnedCoins.value = (pct >= 0.7) ? 20 : 5;
    try {
      Get.find<WalletController>().addCoins(earnedCoins.value, 'Completed ${def.title} Quiz 📝');
    } catch (e) {
      debugPrint('QuizController: Wallet not found: $e');
    }
  }

  void restart() {
    currentQ.value = 0;
    score.value = 0;
    selectedAnswer.value = null;
    isFinished.value = false;
    isDoubleRewarded.value = false;
    _loadQuiz();
  }

  @override
  void onClose() {
    _tts.stop();
    super.onClose();
  }
}
