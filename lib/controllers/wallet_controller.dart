import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/firestore_service.dart';

class WalletController extends GetxController {
  final _box = GetStorage();
  final _firestore = FirestoreService.instance;

  final coins = 0.obs;
  final transactions = <Map<String, dynamic>>[].obs;
  final isSyncing = false.obs;

  final userDeposits = <Map<String, dynamic>>[].obs;
  final userPayouts = <Map<String, dynamic>>[].obs;

  StreamSubscription? _depositsSub;
  StreamSubscription? _payoutsSub;

  @override
  void onInit() {
    super.onInit();
    _loadLocalData();
    if (_firestore.isInitialized) {
      syncWithFirestore();
      _listenToLiveStreams();
    }
  }

  @override
  void onClose() {
    _depositsSub?.cancel();
    _payoutsSub?.cancel();
    super.onClose();
  }

  void _listenToLiveStreams() {
    _depositsSub?.cancel();
    _depositsSub = _firestore.streamUserDeposits().listen((list) {
      userDeposits.value = list;
    });

    _payoutsSub?.cancel();
    _payoutsSub = _firestore.streamUserPayouts().listen((list) {
      userPayouts.value = list;
    });
  }

  void _loadLocalData() {
    coins.value = _box.read<int>('wallet_coins') ?? 0;
    
    final List? cachedTx = _box.read<List>('wallet_transactions');
    if (cachedTx != null) {
      transactions.value = cachedTx.map((tx) => Map<String, dynamic>.from(tx as Map)).toList();
    } else {
      // Default initial reward
      transactions.value = [
        {
          'type': 'credit',
          'amount': 100,
          'reason': 'Welcome Bonus! 🎉',
          'timestamp': DateTime.now().toIso8601String(),
        }
      ];
      coins.value = 100;
      _saveLocalData();
    }

    // Load mock deposits and payouts
    final List? cachedDeposits = _box.read<List>('mock_deposits');
    if (cachedDeposits != null) {
      userDeposits.value = cachedDeposits.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    
    final List? cachedPayouts = _box.read<List>('mock_payouts');
    if (cachedPayouts != null) {
      userPayouts.value = cachedPayouts.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
  }

  void _saveLocalData() {
    _box.write('wallet_coins', coins.value);
    _box.write('wallet_transactions', transactions);
  }

  Future<void> syncWithFirestore() async {
    if (!_firestore.isInitialized) return;
    isSyncing.value = true;
    try {
      final uid = _firestore.currentUserId;
      if (uid == null) return;

      _listenToLiveStreams();

      final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final doc = await docRef.get();

      if (doc.exists) {
        final data = doc.data()!;
        final dbCoins = data['coins'] as int? ?? 0;
        
        // If local coins is greater (user earned offline rewards), upload local to Firestore
        if (coins.value > dbCoins) {
          await docRef.set({
            'coins': coins.value,
            'transactions': transactions,
            'lastSynced': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          debugPrint('WalletController: Uploaded offline coins to Firestore.');
        } else {
          // If Firestore is higher or equal, sync local database to Firestore
          coins.value = dbCoins;
          final List? dbTx = data['transactions'] as List?;
          if (dbTx != null) {
            transactions.value = dbTx.map((tx) => Map<String, dynamic>.from(tx as Map)).toList();
          }
          _saveLocalData();
          debugPrint('WalletController: Synced data from Firestore.');
        }
      } else {
        // Create new document in Firestore
        await docRef.set({
          'coins': coins.value,
          'transactions': transactions,
          'createdAt': FieldValue.serverTimestamp(),
        });
        debugPrint('WalletController: Created new user profile in Firestore.');
      }
    } catch (e) {
      debugPrint('WalletController: Firestore sync error: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  void addCoins(int amount, String reason) {
    if (amount <= 0) return;
    coins.value += amount;

    final tx = {
      'type': 'credit',
      'amount': amount,
      'reason': reason,
      'timestamp': DateTime.now().toIso8601String(),
    };
    transactions.insert(0, tx);
    _saveLocalData();

    _syncCoinsToFirestore();
  }

  Future<bool> requestWithdrawal({
    required int coinsAmount,
    required String paymentMethod,
    required String accountDetails,
  }) async {
    if (coins.value < coinsAmount) {
      Get.snackbar(
        'Insufficient Coins',
        'You need at least $coinsAmount coins to redeem.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    // Deduct coins locally
    coins.value -= coinsAmount;
    final tx = {
      'type': 'debit',
      'amount': coinsAmount,
      'reason': 'Payout request: $paymentMethod ($accountDetails)',
      'timestamp': DateTime.now().toIso8601String(),
    };
    transactions.insert(0, tx);
    _saveLocalData();

    // Sync profile and record payout request
    if (_firestore.isInitialized) {
      try {
        final uid = _firestore.currentUserId;
        if (uid != null) {
          // Update user document
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'coins': coins.value,
            'transactions': transactions,
            'lastSynced': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          // Save withdrawal request in payouts collection
          await FirebaseFirestore.instance.collection('payouts').add({
            'userId': uid,
            'coinsRedeemed': coinsAmount,
            'amountRupees': coinsAmount / 10.0, // e.g. 100 coins = ₹10
            'paymentMethod': paymentMethod,
            'accountDetails': accountDetails,
            'status': 'pending',
            'timestamp': FieldValue.serverTimestamp(),
          });
          
          debugPrint('WalletController: Recorded withdrawal request in Firestore.');
          return true;
        }
      } catch (e) {
        debugPrint('WalletController: Failed to save withdrawal online: $e. Saved locally only.');
      }
    } else {
      // In offline/demo mode, save the mock payout locally
      final List mockPayouts = _box.read<List>('mock_payouts') ?? [];
      final newPayout = {
        'coinsRedeemed': coinsAmount,
        'paymentMethod': paymentMethod,
        'accountDetails': accountDetails,
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'pending (demo)',
      };
      mockPayouts.insert(0, newPayout);
      _box.write('mock_payouts', mockPayouts);
      
      // Update local reactive list for offline users to see history
      userPayouts.value = mockPayouts.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return true;
  }

  Future<bool> requestDeposit({required double amount, required String transactionId}) async {
    if (!_firestore.isInitialized) {
      // Demo offline mode
      final List mockDeposits = _box.read<List>('mock_deposits') ?? [];
      final newDeposit = {
        'amount': amount,
        'transactionId': transactionId,
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'pending (demo)',
      };
      mockDeposits.insert(0, newDeposit);
      _box.write('mock_deposits', mockDeposits);
      
      userDeposits.value = mockDeposits.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      return true;
    }

    try {
      await _firestore.submitDepositClaim(amount: amount, transactionId: transactionId);
      return true;
    } catch (e) {
      Get.snackbar(
        'Submission Failed',
        'Could not submit payment claim: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<void> _syncCoinsToFirestore() async {
    if (!_firestore.isInitialized) return;
    try {
      final uid = _firestore.currentUserId;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'coins': coins.value,
          'transactions': transactions,
          'lastSynced': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('WalletController: Silent background sync error: $e');
    }
  }
}
