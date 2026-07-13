import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import '../models/category_item_model.dart';
import '../core/app_constants.dart';
import 'wallet_controller.dart';
import '../core/firestore_service.dart';
import 'package:flutter/material.dart';

class MatchingPair {
  final CategoryItem item;
  bool emojiMatched;
  bool nameMatched;
  MatchingPair({required this.item, this.emojiMatched = false, this.nameMatched = false});
}

class MatchingGameController extends GetxController {
  final CategoryDef def;
  MatchingGameController(this.def);

  final _tts = FlutterTts();
  final _rng = Random();

  final pairs = <MatchingPair>[].obs;
  final emojiOrder = <int>[].obs;
  final nameOrder = <int>[].obs;
  final selectedEmoji = Rxn<int>();
  final selectedName = Rxn<int>();
  final moves = 0.obs;
  final isFinished = false.obs;
  final earnedCoins = 0.obs;
  final isDoubleRewarded = false.obs;

  int get matchedCount => pairs.where((p) => p.emojiMatched).length;

  @override
  void onInit() {
    super.onInit();
    _loadGame();
  }

  Future<void> _loadGame() async {
    const pairCount = 6;
    final list = await FirestoreService.instance.fetchCategoryItems(def);
    final all = list.map(CategoryItem.fromJson).toList();
    all.shuffle(_rng);
    final pool = all.take(pairCount).toList();
    pairs.value = pool.map((item) => MatchingPair(item: item)).toList();
    emojiOrder.value = List.generate(pool.length, (i) => i)..shuffle(_rng);
    nameOrder.value = List.generate(pool.length, (i) => i)..shuffle(_rng);
  }

  void tapEmoji(int pairIndex) {
    if (pairs[pairIndex].emojiMatched) return;
    selectedEmoji.value = pairIndex;
    _checkMatch();
  }

  void tapName(int pairIndex) {
    if (pairs[pairIndex].nameMatched) return;
    selectedName.value = pairIndex;
    _tts.speak(pairs[pairIndex].item.name);
    _checkMatch();
  }

  void _checkMatch() {
    if (selectedEmoji.value == null || selectedName.value == null) return;
    moves.value++;
    if (selectedEmoji.value == selectedName.value) {
      pairs[selectedEmoji.value!].emojiMatched = true;
      pairs[selectedEmoji.value!].nameMatched = true;
      pairs.refresh();
      _tts.speak('Correct!');
      if (pairs.every((p) => p.emojiMatched)) {
        isFinished.value = true;
        
        // Award coins
        earnedCoins.value = 15;
        try {
          Get.find<WalletController>().addCoins(earnedCoins.value, 'Completed ${def.title} Match Game 🎯');
        } catch (e) {
          debugPrint('MatchingGameController: Wallet not found: $e');
        }
      }
    } else {
      _tts.speak('Try again!');
    }
    selectedEmoji.value = null;
    selectedName.value = null;
  }

  void restart() {
    moves.value = 0;
    isFinished.value = false;
    isDoubleRewarded.value = false;
    selectedEmoji.value = null;
    selectedName.value = null;
    _loadGame();
  }

  @override
  void onClose() {
    _tts.stop();
    super.onClose();
  }
}
