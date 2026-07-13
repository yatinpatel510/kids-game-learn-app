import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import '../core/app_constants.dart';

class FirestoreService {
  static final FirestoreService instance = FirestoreService._internal();
  FirestoreService._internal();

  final _box = GetStorage();
  final _localUpdateStream = StreamController<void>.broadcast();

  bool _isFirebaseInitialized = false;
  bool get isInitialized => _isFirebaseInitialized;

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> initialize() async {
    try {
      // Initialize Firebase natively (looks for google-services.json / GoogleService-Info.plist)
      await Firebase.initializeApp();
      _isFirebaseInitialized = true;
      debugPrint('FirestoreService: Firebase initialized successfully.');

      // Sign in anonymously only if no user is currently logged in
      try {
        final existing = FirebaseAuth.instance.currentUser;
        if (existing == null) {
          await FirebaseAuth.instance.signInAnonymously();
          debugPrint(
            'FirestoreService: Anonymous user signed in: $currentUserId',
          );
        } else {
          debugPrint(
            'FirestoreService: Existing session restored: ${existing.uid} (anonymous: ${existing.isAnonymous})',
          );
        }
      } catch (authError) {
        debugPrint(
          'FirestoreService: Authentication warning (anonymous sign-in failed): $authError. '
          'Please enable the "Anonymous" provider under Authentication > Sign-in method in your Firebase Console if you want to support rewards.',
        );
      }

      // Trigger automatic data sync/migration in background
      _syncInitialDataIfNeeded();
    } catch (e) {
      _isFirebaseInitialized = false;
      debugPrint(
        'FirestoreService: Native Firebase config files missing or error: $e. Switching to local offline fallback.',
      );
    }
  }

  Future<void> _syncInitialDataIfNeeded() async {
    if (!_isFirebaseInitialized) return;
    try {
      final metaDoc = await FirebaseFirestore.instance
          .collection('metadata')
          .doc('status')
          .get();
      if (metaDoc.exists && metaDoc.data()?['dataMigrated'] == true) {
        debugPrint('FirestoreService: Data migration already completed.');
        return;
      }

      debugPrint(
        'FirestoreService: Starting one-time Firestore data migration from local assets...',
      );

      // Sync each category json
      for (final cat in AppConstants.learnCategories) {
        final raw = await rootBundle.loadString('assets/data/${cat.jsonFile}');
        final list = jsonDecode(raw) as List;

        final batch = FirebaseFirestore.instance.batch();

        for (int i = 0; i < list.length; i++) {
          final item = Map<String, dynamic>.from(list[i] as Map);
          // Standardize ID
          final String itemId =
              item['id']?.toString() ??
              item['letter']?.toString() ??
              '${cat.id}_$i';
          final docRef = FirebaseFirestore.instance
              .collection('items')
              .doc('${cat.id}_$itemId');

          // Save fields
          batch.set(docRef, {'categoryId': cat.id, 'id': itemId, ...item});
        }
        await batch.commit();
        debugPrint('FirestoreService: Migrated category "${cat.title}" items.');
      }

      // Mark migration as done
      await FirebaseFirestore.instance.collection('metadata').doc('status').set(
        {'dataMigrated': true, 'timestamp': FieldValue.serverTimestamp()},
      );
      debugPrint(
        'FirestoreService: One-time Firestore data migration finished successfully!',
      );
    } catch (e) {
      debugPrint('FirestoreService: Error during initial data sync: $e');
    }
  }

  // Generic method to fetch items for a category
  // Falls back to local JSON if Firestore is unavailable
  Future<List<Map<String, dynamic>>> fetchCategoryItems(CategoryDef cat) async {
    if (!_isFirebaseInitialized) {
      final assetsList = await _loadLocalJson(cat.jsonFile);

      // Filter out deleted items
      final List? deletedIds = _box.read<List>(
        'offline_deleted_items_${cat.id}',
      );
      var filteredList = assetsList;
      if (deletedIds != null) {
        filteredList = assetsList.where((item) {
          final id = (item['id'] ?? item['letter'] ?? '').toString();
          return !deletedIds.contains(id);
        }).toList();
      }

      // Merge custom offline items
      final List? custom = _box.read<List>('offline_items_${cat.id}');
      if (custom != null) {
        final List<Map<String, dynamic>> customList = custom
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        final Map<String, Map<String, dynamic>> itemsMap = {};
        for (final item in filteredList) {
          final id = (item['id'] ?? item['letter'] ?? '').toString();
          itemsMap[id] = item;
        }
        for (final item in customList) {
          final id = (item['id'] ?? item['letter'] ?? '').toString();
          itemsMap[id] = item;
        }
        return itemsMap.values.toList();
      }
      return filteredList;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('items')
          .where('categoryId', isEqualTo: cat.id)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint(
          'FirestoreService: Firestore has no records for ${cat.id}. Reading from local asset.',
        );
        return _loadLocalJson(cat.jsonFile);
      }

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint(
        'FirestoreService: Error fetching from Firestore for ${cat.id}: $e. Falling back to local asset.',
      );
      return _loadLocalJson(cat.jsonFile);
    }
  }

  Future<List<Map<String, dynamic>>> _loadLocalJson(String jsonFile) async {
    final raw = await rootBundle.loadString('assets/data/$jsonFile');
    final list = jsonDecode(raw) as List;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ── Admin Settings ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchAdminSettings() async {
    if (!_isFirebaseInitialized) {
      return {'adminUpiId': 'admin@upi', 'adminPasscode': '123456'};
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('config')
          .get();
      if (doc.exists) {
        return doc.data()!;
      }
    } catch (e) {
      debugPrint('FirestoreService: Error fetching admin settings: $e');
    }
    return {'adminUpiId': 'admin@upi', 'adminPasscode': '123456'};
  }

  Future<void> updateAdminSettings(String upiId, String passcode) async {
    if (!_isFirebaseInitialized) return;
    try {
      await FirebaseFirestore.instance
          .collection('settings')
          .doc('config')
          .set({
            'adminUpiId': upiId,
            'adminPasscode': passcode,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('FirestoreService: Error updating admin settings: $e');
    }
  }

  // ── Deposit Claims (Buy Coins) ──────────────────────────────────────────────
  Future<void> submitDepositClaim({
    required double amount,
    required String transactionId,
  }) async {
    if (!_isFirebaseInitialized || currentUserId == null) return;
    try {
      await FirebaseFirestore.instance.collection('deposits').add({
        'userId': currentUserId,
        'amount': amount,
        'transactionId': transactionId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('FirestoreService: Error submitting deposit claim: $e');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> streamUserDeposits() {
    if (!_isFirebaseInitialized || currentUserId == null) {
      return Stream.value([]);
    }
    return FirebaseFirestore.instance
        .collection('deposits')
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
          // Sort manually because compound query orderBy requires complex index setup
          docs.sort((a, b) {
            final aTime = a['timestamp'] as Timestamp?;
            final bTime = b['timestamp'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });
          return docs;
        });
  }

  Stream<List<Map<String, dynamic>>> streamUserPayouts() {
    if (!_isFirebaseInitialized || currentUserId == null) {
      return Stream.value([]);
    }
    return FirebaseFirestore.instance
        .collection('payouts')
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
          docs.sort((a, b) {
            final aTime = a['timestamp'] as Timestamp?;
            final bTime = b['timestamp'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });
          return docs;
        });
  }

  // ── Admin Pending Lists ─────────────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> streamPendingDeposits() {
    if (!_isFirebaseInitialized) return Stream.value([]);
    return FirebaseFirestore.instance
        .collection('deposits')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
          docs.sort((a, b) {
            final aTime = a['timestamp'] as Timestamp?;
            final bTime = b['timestamp'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });
          return docs;
        });
  }

  Stream<List<Map<String, dynamic>>> streamPendingPayouts() {
    if (!_isFirebaseInitialized) return Stream.value([]);
    return FirebaseFirestore.instance
        .collection('payouts')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
          docs.sort((a, b) {
            final aTime = a['timestamp'] as Timestamp?;
            final bTime = b['timestamp'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });
          return docs;
        });
  }

  // ── Deposit Approval / Rejection ────────────────────────────────────────────
  Future<void> approveDeposit(
    String depositId,
    String userId,
    double amount,
    String txId,
  ) async {
    if (!_isFirebaseInitialized) return;
    final depositRef = FirebaseFirestore.instance
        .collection('deposits')
        .doc(depositId);
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      int currentCoins = 0;
      List<dynamic> txs = [];
      if (userDoc.exists) {
        currentCoins = userDoc.data()?['coins'] as int? ?? 0;
        txs = userDoc.data()?['transactions'] as List? ?? [];
      }

      final addedCoins = (amount * 10).toInt();
      final newCoins = currentCoins + addedCoins;
      final newTx = {
        'type': 'credit',
        'amount': addedCoins,
        'reason': 'UPI Deposit Approved (₹$amount, UTR: $txId) 🎉',
        'timestamp': DateTime.now().toIso8601String(),
      };

      txs.insert(0, newTx);

      transaction.update(depositRef, {'status': 'approved'});
      transaction.set(userRef, {
        'coins': newCoins,
        'transactions': txs,
        'lastSynced': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> rejectDeposit(String depositId) async {
    if (!_isFirebaseInitialized) return;
    await FirebaseFirestore.instance
        .collection('deposits')
        .doc(depositId)
        .update({'status': 'rejected'});
  }

  // ── Payout Approval / Rejection ─────────────────────────────────────────────
  Future<void> approvePayout(String payoutId) async {
    if (!_isFirebaseInitialized) return;
    await FirebaseFirestore.instance.collection('payouts').doc(payoutId).update(
      {'status': 'completed'},
    );
  }

  Future<void> rejectPayout(
    String payoutId,
    String userId,
    int coinsAmount,
  ) async {
    if (!_isFirebaseInitialized) return;
    final payoutRef = FirebaseFirestore.instance
        .collection('payouts')
        .doc(payoutId);
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      int currentCoins = 0;
      List<dynamic> txs = [];
      if (userDoc.exists) {
        currentCoins = userDoc.data()?['coins'] as int? ?? 0;
        txs = userDoc.data()?['transactions'] as List? ?? [];
      }

      final newCoins = currentCoins + coinsAmount;
      final newTx = {
        'type': 'credit',
        'amount': coinsAmount,
        'reason': 'Payout Rejected & Refunded 🪙',
        'timestamp': DateTime.now().toIso8601String(),
      };
      txs.insert(0, newTx);

      transaction.update(payoutRef, {'status': 'rejected'});
      transaction.set(userRef, {
        'coins': newCoins,
        'transactions': txs,
        'lastSynced': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  // ── Add new learning item ───────────────────────────────────────────────────
  Future<void> addLearningItem({
    required String categoryId,
    required Map<String, dynamic> itemData,
  }) async {
    if (!_isFirebaseInitialized) {
      final List custom = _box.read<List>('offline_items_$categoryId') ?? [];
      final id = (itemData['id'] ?? itemData['letter'] ?? '').toString();

      // Remove duplicate ID if it exists
      custom.removeWhere(
        (item) => (item['id'] ?? item['letter'] ?? '').toString() == id,
      );
      custom.add(itemData);

      await _box.write('offline_items_$categoryId', custom);

      // If it was previously marked as deleted, remove it from the deleted list
      final List? deletedIds = _box.read<List>(
        'offline_deleted_items_$categoryId',
      );
      if (deletedIds != null && deletedIds.contains(id)) {
        deletedIds.remove(id);
        await _box.write('offline_deleted_items_$categoryId', deletedIds);
      }

      _localUpdateStream.add(null);
      debugPrint(
        'FirestoreService: Offline added item $id to category $categoryId.',
      );
      return;
    }

    try {
      final String itemId =
          itemData['id']?.toString() ??
          itemData['letter']?.toString() ??
          '${categoryId}_${DateTime.now().millisecondsSinceEpoch}';
      final docRef = FirebaseFirestore.instance
          .collection('items')
          .doc('${categoryId}_$itemId');

      await docRef.set({'categoryId': categoryId, 'id': itemId, ...itemData});
      debugPrint(
        'FirestoreService: Successfully added/updated item $itemId in category $categoryId.',
      );
    } catch (e) {
      debugPrint('FirestoreService: Error adding learning item: $e');
      rethrow;
    }
  }

  // ── Manage Cards ────────────────────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> streamCategoryItems(String categoryId) {
    if (!_isFirebaseInitialized) {
      final controller = StreamController<List<Map<String, dynamic>>>();

      Future<void> emitData() async {
        if (controller.isClosed) return;
        final list = await fetchCategoryItems(
          CategoryDef(
            id: categoryId,
            title: '',
            emoji: '',
            jsonFile: AppConstants.learnCategories
                .firstWhere((c) => c.id == categoryId)
                .jsonFile,
            gradient: [],
          ),
        );

        final mapped = list
            .map(
              (e) => {'docId': (e['id'] ?? e['letter'] ?? '').toString(), ...e},
            )
            .toList();
        mapped.sort((a, b) {
          final aVal = (a['title'] ?? a['letter'] ?? '')
              .toString()
              .toLowerCase();
          final bVal = (b['title'] ?? b['letter'] ?? '')
              .toString()
              .toLowerCase();
          return aVal.compareTo(bVal);
        });
        controller.add(mapped);
      }

      final sub = _localUpdateStream.stream.listen((_) => emitData());
      emitData();

      controller.onCancel = () {
        sub.cancel();
        controller.close();
      };
      return controller.stream;
    }

    return FirebaseFirestore.instance
        .collection('items')
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => {'docId': doc.id, ...doc.data()})
              .toList();
          // Sort items by title/id for consistency in presentation
          list.sort((a, b) {
            final aVal = (a['title'] ?? a['letter'] ?? '')
                .toString()
                .toLowerCase();
            final bVal = (b['title'] ?? b['letter'] ?? '')
                .toString()
                .toLowerCase();
            return aVal.compareTo(bVal);
          });
          return list;
        });
  }

  Future<void> updateLearningItem({
    required String docId,
    required Map<String, dynamic> itemData,
  }) async {
    if (!_isFirebaseInitialized) {
      // Find which category this item belongs to
      for (final cat in AppConstants.learnCategories) {
        // If it is in custom offline items, update it
        final List? custom = _box.read<List>('offline_items_${cat.id}');
        if (custom != null) {
          final list = custom
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          final index = list.indexWhere(
            (item) => (item['id'] ?? item['letter'] ?? '').toString() == docId,
          );
          if (index != -1) {
            list[index]['title'] = itemData['title'] ?? list[index]['title'];
            list[index]['letter'] = itemData['title'] ?? list[index]['letter'];
            list[index]['emoji'] = itemData['emoji'] ?? list[index]['emoji'];
            list[index]['fact'] = itemData['fact'] ?? list[index]['fact'];

            await _box.write('offline_items_${cat.id}', list);
            _localUpdateStream.add(null);
            debugPrint('FirestoreService: Offline updated custom item $docId.');
            return;
          }
        }

        // If it's a default asset item, we clone it into custom offline items with modifications
        final assetsList = await _loadLocalJson(cat.jsonFile);
        final index = assetsList.indexWhere(
          (item) => (item['id'] ?? item['letter'] ?? '').toString() == docId,
        );

        if (index != -1) {
          final original = Map<String, dynamic>.from(assetsList[index]);
          original['title'] = itemData['title'] ?? original['title'];
          original['letter'] = itemData['title'] ?? original['letter'];
          original['emoji'] = itemData['emoji'] ?? original['emoji'];
          original['fact'] = itemData['fact'] ?? original['fact'];

          final List customList =
              _box.read<List>('offline_items_${cat.id}') ?? [];
          customList.add(original);
          await _box.write('offline_items_${cat.id}', customList);
          _localUpdateStream.add(null);
          debugPrint(
            'FirestoreService: Offline cloned and updated default item $docId.',
          );
          return;
        }
      }
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('items')
          .doc(docId)
          .update(itemData);
      debugPrint('FirestoreService: Successfully updated item $docId.');
    } catch (e) {
      debugPrint('FirestoreService: Error updating learning item: $e');
      rethrow;
    }
  }

  Future<void> deleteLearningItem({required String docId}) async {
    if (!_isFirebaseInitialized) {
      for (final cat in AppConstants.learnCategories) {
        // If it is in custom offline items, remove it
        final List? custom = _box.read<List>('offline_items_${cat.id}');
        if (custom != null) {
          final list = custom
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          final index = list.indexWhere(
            (item) => (item['id'] ?? item['letter'] ?? '').toString() == docId,
          );
          if (index != -1) {
            list.removeAt(index);
            await _box.write('offline_items_${cat.id}', list);
            _localUpdateStream.add(null);
            debugPrint('FirestoreService: Offline deleted custom item $docId.');
            return;
          }
        }

        // If it is a default asset item, add to deleted list
        final assetsList = await _loadLocalJson(cat.jsonFile);
        final existsInAssets = assetsList.any(
          (item) => (item['id'] ?? item['letter'] ?? '').toString() == docId,
        );

        if (existsInAssets) {
          final List deletedIds =
              _box.read<List>('offline_deleted_items_${cat.id}') ?? [];
          if (!deletedIds.contains(docId)) {
            deletedIds.add(docId);
            await _box.write('offline_deleted_items_${cat.id}', deletedIds);
          }
          _localUpdateStream.add(null);
          debugPrint(
            'FirestoreService: Offline marked default item $docId as deleted.',
          );
          return;
        }
      }
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('items').doc(docId).delete();
      debugPrint('FirestoreService: Successfully deleted item $docId.');
    } catch (e) {
      debugPrint('FirestoreService: Error deleting learning item: $e');
      rethrow;
    }
  }
}
