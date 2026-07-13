import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import '../models/category_item_model.dart';
import '../core/app_constants.dart';
import 'wallet_controller.dart';
import '../core/firestore_service.dart';
import 'package:flutter/foundation.dart';

class SpellingController extends GetxController {
  final CategoryDef def;
  SpellingController(this.def);

  final _tts = FlutterTts();
  final _rng = Random();

  final items = <CategoryItem>[].obs;
  final currentIndex = 0.obs;
  final tappedLetters = <String>[].obs;
  final shuffledLetters = <String>[].obs;
  final isCorrect = false.obs;
  final isWrong = false.obs;
  final score = 0.obs;

  CategoryItem get current => items[currentIndex.value];
  int get total => items.length;
  String get tappedWord => tappedLetters.join();

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    const maxLen = 0;
    final list = await FirestoreService.instance.fetchCategoryItems(def);
    final all = list.map(CategoryItem.fromJson).toList();

    // Filter by word length based on level (no limit)
    final filtered = maxLen == 0
        ? all
        : all.where((i) => i.name.replaceAll(' ', '').length <= maxLen).toList();

    final pool = filtered.isEmpty ? all : filtered;
    pool.shuffle(_rng);
    items.value = pool;
    _setupCurrent();
  }

  void _setupCurrent() {
    tappedLetters.clear();
    isCorrect.value = false;
    isWrong.value = false;
    final letters = current.name.toUpperCase().replaceAll(' ', '').split('');
    final extras = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        .split('')
        .where((l) => !letters.contains(l))
        .toList()
      ..shuffle(_rng);
    shuffledLetters.value = [...letters, ...extras.take(3)]..shuffle(_rng);
    _tts.speak(current.name);
  }

  void tapLetter(String letter) {
    if (isCorrect.value) return;
    tappedLetters.add(letter);
    final target = current.name.toUpperCase().replaceAll(' ', '');
    if (tappedWord == target) {
      isCorrect.value = true;
      score.value++;
      _tts.speak('Correct! ${current.name}');
      
      // Award coins
      try {
        Get.find<WalletController>().addCoins(2, 'Spelled "${current.name}" correctly ✏️');
      } catch (e) {
        debugPrint('SpellingController: Wallet not found: $e');
      }
    } else if (tappedWord.length >= target.length) {
      isWrong.value = true;
      _tts.speak('Try again!');
    }
  }

  void removeLast() {
    if (tappedLetters.isNotEmpty) {
      tappedLetters.removeLast();
      isWrong.value = false;
    }
  }

  void next() {
    if (currentIndex.value < total - 1) {
      currentIndex.value++;
    } else {
      currentIndex.value = 0;
    }
    _setupCurrent();
  }

  void speakCurrent() => _tts.speak(current.name);

  @override
  void onClose() {
    _tts.stop();
    super.onClose();
  }
}
