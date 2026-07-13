import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/firestore_service.dart';

class ConfigController extends GetxController {
  static ConfigController get to => Get.find<ConfigController>();

  final _firestore = FirestoreService.instance;
  StreamSubscription? _configSub;

  // Configuration observables
  final adminUpiId = 'admin@upi'.obs;
  final adminPasscode = '123456'.obs;
  final appTitle = 'Kids Learn'.obs;
  final learnSubtitle = 'Choose a topic to explore'.obs;
  final gamesSubtitle = 'Play games and learn!'.obs;
  final conversionRate = '₹1 = 10 Coins'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLocalDefaults();
    if (_firestore.isInitialized) {
      _listenToConfig();
    }
  }

  @override
  void onClose() {
    _configSub?.cancel();
    super.onClose();
  }

  void _loadLocalDefaults() {
    adminUpiId.value = 'admin@upi';
    adminPasscode.value = '123456';
    appTitle.value = 'Kids Learn';
    learnSubtitle.value = 'Choose a topic to explore';
    gamesSubtitle.value = 'Play games and learn!';
    conversionRate.value = '₹1 = 10 Coins';
  }

  void _listenToConfig() {
    _configSub?.cancel();
    _configSub = FirebaseFirestore.instance
        .collection('settings')
        .doc('config')
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          adminUpiId.value = data['adminUpiId']?.toString() ?? 'admin@upi';
          adminPasscode.value = data['adminPasscode']?.toString() ?? '123456';
          appTitle.value = data['appTitle']?.toString() ?? 'Kids Learn';
          learnSubtitle.value = data['learnSubtitle']?.toString() ?? 'Choose a topic to explore';
          gamesSubtitle.value = data['gamesSubtitle']?.toString() ?? 'Play games and learn!';
          conversionRate.value = data['conversionRate']?.toString() ?? '₹1 = 10 Coins';
        }
      }
    }, onError: (e) {
      debugPrint('ConfigController: Error listening to config: $e');
    });
  }

  Future<void> updateConfig({
    required String upiId,
    required String passcode,
    required String title,
    required String learnSub,
    required String gamesSub,
    required String rate,
  }) async {
    adminUpiId.value = upiId;
    adminPasscode.value = passcode;
    appTitle.value = title;
    learnSubtitle.value = learnSub;
    gamesSubtitle.value = gamesSub;
    conversionRate.value = rate;

    if (_firestore.isInitialized) {
      await FirebaseFirestore.instance
          .collection('settings')
          .doc('config')
          .set({
        'adminUpiId': upiId,
        'adminPasscode': passcode,
        'appTitle': title,
        'learnSubtitle': learnSub,
        'gamesSubtitle': gamesSub,
        'conversionRate': rate,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
}
