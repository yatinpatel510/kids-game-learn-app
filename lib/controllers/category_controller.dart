import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import '../models/category_item_model.dart';
import '../core/app_constants.dart';
import '../core/firestore_service.dart';
import '../core/ad_manager.dart';
import 'wallet_controller.dart';

class CategoryController extends GetxController {
  final CategoryDef def;
  CategoryController(this.def);

  final _tts = FlutterTts();

  final items = <CategoryItem>[].obs;
  final index = 0.obs;
  final isSpeaking = false.obs;

  CategoryItem get current => items[index.value];
  int get total => items.length;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await FirestoreService.instance.fetchCategoryItems(def);
    items.value = list.map(CategoryItem.fromJson).toList();
    speak();
  }

  Future<void> speak() async {
    if (isSpeaking.value || items.isEmpty) return;
    isSpeaking.value = true;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.5);
    await _tts.setVolume(1.0);
    _tts.setCompletionHandler(() => isSpeaking.value = false);
    await _tts.speak(current.name);
  }

  void _goToNextItem() {
    if (index.value < total - 1) {
      index.value++;
      speak();
    }
  }

  void next() {
    if (AdManager.instance.isAdReady) {
      AdManager.instance.showRewardedAd(
        onEarnedReward: () {
          try {
            Get.find<WalletController>().addCoins(1, 'Watched video ad in study mode 📺');
            Get.snackbar(
              'Reward! 🪙',
              '+1 Coin added for watching!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF1DD1A1),
              colorText: Colors.white,
              duration: const Duration(milliseconds: 1500),
            );
          } catch (_) {}
        },
        onAdDismissed: () {
          _goToNextItem();
        },
        onAdFailed: () {
          _goToNextItem();
        },
      );
    } else {
      _goToNextItem();
    }
  }

  void prev() {
    if (index.value > 0) {
      index.value--;
      speak();
    }
  }

  @override
  void onClose() {
    _tts.stop();
    super.onClose();
  }
}
