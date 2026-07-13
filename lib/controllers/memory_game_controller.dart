import 'dart:math';
import 'package:get/get.dart';
import '../models/category_item_model.dart';
import '../core/app_constants.dart';
import 'wallet_controller.dart';
import '../core/firestore_service.dart';
import 'package:flutter/foundation.dart';

class MemoryCard {
  final String id;
  final CategoryItem item;
  final bool isEmoji;
  bool isFlipped;
  bool isMatched;

  MemoryCard({required this.id, required this.item, required this.isEmoji, this.isFlipped = false, this.isMatched = false});
}

class MemoryGameController extends GetxController {
  final CategoryDef def;
  MemoryGameController(this.def);

  final cards = <MemoryCard>[].obs;
  final flippedIndexes = <int>[].obs;
  final moves = 0.obs;
  final isFinished = false.obs;
  final isChecking = false.obs;
  final earnedCoins = 0.obs;
  final isDoubleRewarded = false.obs;

  int get matchedCount => cards.where((c) => c.isMatched).length ~/ 2;
  int get totalPairs => cards.length ~/ 2;

  @override
  void onInit() {
    super.onInit();
    _loadGame();
  }

  Future<void> _loadGame() async {
    const pairCount = 6;
    final list = await FirestoreService.instance.fetchCategoryItems(def);
    final all = list.map(CategoryItem.fromJson).toList();
    all.shuffle(Random());
    final pool = all.take(pairCount).toList();

    final deck = <MemoryCard>[];
    for (final item in pool) {
      deck.add(MemoryCard(id: '${item.id}_emoji', item: item, isEmoji: true));
      deck.add(MemoryCard(id: '${item.id}_name', item: item, isEmoji: false));
    }
    deck.shuffle(Random());
    cards.value = deck;
  }

  void flipCard(int index) {
    if (isChecking.value) return;
    final card = cards[index];
    if (card.isFlipped || card.isMatched) return;
    if (flippedIndexes.length >= 2) return;

    card.isFlipped = true;
    cards.refresh();
    flippedIndexes.add(index);

    if (flippedIndexes.length == 2) {
      moves.value++;
      _checkMatch();
    }
  }

  Future<void> _checkMatch() async {
    isChecking.value = true;
    await Future.delayed(const Duration(milliseconds: 800));

    final a = cards[flippedIndexes[0]];
    final b = cards[flippedIndexes[1]];

    if (a.item.id == b.item.id) {
      a.isMatched = true;
      b.isMatched = true;
      if (cards.every((c) => c.isMatched)) {
        isFinished.value = true;
        
        // Award coins
        earnedCoins.value = 20;
        try {
          Get.find<WalletController>().addCoins(earnedCoins.value, 'Completed ${def.title} Memory Game 🧠');
        } catch (e) {
          debugPrint('MemoryGameController: Wallet not found: $e');
        }
      }
    } else {
      a.isFlipped = false;
      b.isFlipped = false;
    }

    cards.refresh();
    flippedIndexes.clear();
    isChecking.value = false;
  }

  void restart() {
    flippedIndexes.clear();
    moves.value = 0;
    isFinished.value = false;
    isChecking.value = false;
    isDoubleRewarded.value = false;
    _loadGame();
  }
}
