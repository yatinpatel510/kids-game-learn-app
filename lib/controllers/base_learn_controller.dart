import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import '../core/ad_manager.dart';
import 'wallet_controller.dart';

abstract class BaseLearnController extends GetxController
    with GetTickerProviderStateMixin {
  final tts = FlutterTts();

  final index = 0.obs;
  final isSpeaking = false.obs;

  late final AnimationController cardAnim;
  late final AnimationController emojiAnim;
  late final Animation<double> cardScale;
  late final Animation<double> emojiScale;

  int get total;
  String get currentSpeakText;
  String get categoryId;        // each subclass defines its category id
  String itemIdAt(int i);       // each subclass returns item id at index

  @override
  void onInit() {
    super.onInit();
    cardAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    emojiAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    cardScale = CurvedAnimation(parent: cardAnim, curve: Curves.elasticOut);
    emojiScale = CurvedAnimation(parent: emojiAnim, curve: Curves.elasticOut);
    playEntrance();
  }

  void playEntrance() {
    cardAnim.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 200), () => emojiAnim.forward(from: 0));
    Future.delayed(const Duration(milliseconds: 500), speak);
  }

  Future<void> speak() async {
    if (isSpeaking.value) return;
    isSpeaking.value = true;
    await tts.setLanguage('en-US');
    await tts.setSpeechRate(0.42);
    await tts.setPitch(1.5);
    await tts.setVolume(1.0);
    tts.setCompletionHandler(() => isSpeaking.value = false);
    await tts.speak(currentSpeakText);
  }

  void _goToNextItem() {
    if (index.value < total - 1) {
      index.value++;
      playEntrance();
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
      playEntrance();
    }
  }

  @override
  void onClose() {
    tts.stop();
    cardAnim.dispose();
    emojiAnim.dispose();
    super.onClose();
  }
}
