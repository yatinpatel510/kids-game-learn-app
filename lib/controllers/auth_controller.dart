import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'wallet_controller.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  final _db = FirebaseFirestore.instance;

  final user = Rxn<User>();
  final isLoading = false.obs;

  bool get isLoggedInWithGoogle =>
      user.value != null && !user.value!.isAnonymous;

  @override
  void onInit() {
    super.onInit();
    user.value = _auth.currentUser;
    _auth.authStateChanges().listen((u) {
      user.value = u;
      if (u != null && !u.isAnonymous) {
        _loadFirestoreProfile(u.uid);
      } else {
        firestoreProfile.value = null;
      }
    });
    // Restore session on app restart
    final current = _auth.currentUser;
    if (current != null && !current.isAnonymous) {
      _loadFirestoreProfile(current.uid);
    }
  }

  // ── Unique device ID ────────────────────────────────────────────────────────
  Future<String> _getDeviceId() async {
    final info = DeviceInfoPlugin();
    if (Platform.isAndroid) return (await info.androidInfo).id;
    if (Platform.isIOS) {
      final d = await info.iosInfo;
      return d.identifierForVendor ?? d.name;
    }
    return 'unknown_device';
  }

  Future<String> _getDeviceName() async {
    final info = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final d = await info.androidInfo;
      return '${d.brand} ${d.model}';
    }
    if (Platform.isIOS) return (await info.iosInfo).name;
    return 'Unknown Device';
  }

  // ── Check if another device is already active ───────────────────────────────
  Future<bool> _isAnotherDeviceLoggedIn(String uid) async {
    final deviceId = await _getDeviceId();
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return false;
    final stored = doc.data()?['deviceId'] as String?;
    return stored != null && stored.isNotEmpty && stored != deviceId;
  }

  // ── Firestore user profile ─────────────────────────────────────────────────
  final firestoreProfile = Rxn<Map<String, dynamic>>();

  Future<void> _loadFirestoreProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) firestoreProfile.value = doc.data();
    } catch (e) {
      debugPrint('AuthController: loadFirestoreProfile error: $e');
    }
  }

  // ── Write session entry to Firestore ───────────────────────────────────────
  Future<void> _writeSession(String uid, {String? givenName, String? familyName}) async {
    final u = _auth.currentUser;
    final fullName = u?.displayName ?? '';
    final nameParts = fullName.trim().split(' ');
    final firstName = givenName ?? (nameParts.isNotEmpty ? nameParts.first : '');
    final lastName = familyName ?? (nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '');

    // Check if doc already exists to preserve createdAt
    final existing = await _db.collection('users').doc(uid).get();
    final Map<String, dynamic> data = {
      'uid': uid,
      'email': u?.email,
      'displayName': fullName,
      'firstName': firstName,
      'lastName': lastName,
      'photoUrl': u?.photoURL,
      'deviceId': await _getDeviceId(),
      'deviceName': await _getDeviceName(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    };
    if (!existing.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
    firestoreProfile.value = {...(existing.data() ?? {}), ...data};
  }

  // ── Device conflict dialog ──────────────────────────────────────────────────
  Future<bool> _showDeviceConflictDialog(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    final existingDevice =
        doc.data()?['deviceName'] as String? ?? 'another device';

    final confirmed = await Get.dialog<bool>(
      barrierDismissible: false,
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📱', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text(
                'Already Logged In',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF5F27CD)),
              ),
              const SizedBox(height: 12),
              Text(
                'This account is currently active on\n"$existingDevice".\n\nLogging in here will sign out that device.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        side: const BorderSide(color: Color(0xFFFF6B6B)),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(
                              color: Color(0xFFFF6B6B),
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5F27CD),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Continue',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return confirmed ?? false;
  }

  // ── Main Google sign-in flow ────────────────────────────────────────────────
  Future<void> signInWithGoogle() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final previousUser = _auth.currentUser;
      final wasAnonymous = previousUser != null && previousUser.isAnonymous;

      String finalUid;

      if (wasAnonymous) {
        finalUid = await _handleAnonymousMigration(previousUser, credential);
      } else {
        final result = await _auth.signInWithCredential(credential);
        finalUid = result.user!.uid;
      }

      // Device conflict check
      final conflict = await _isAnotherDeviceLoggedIn(finalUid);
      if (conflict) {
        final proceed = await _showDeviceConflictDialog(finalUid);
        if (!proceed) {
          await _auth.signOut();
          await _auth.signInAnonymously();
          return;
        }
      }

      await _writeSession(
        finalUid,
        givenName: googleUser.displayName?.trim().split(' ').first,
        familyName: (googleUser.displayName?.trim().split(' ').length ?? 0) > 1
            ? googleUser.displayName!.trim().split(' ').sublist(1).join(' ')
            : null,
      );
      await _loadFirestoreProfile(finalUid);
      await Get.find<WalletController>().syncWithFirestore();

      Get.snackbar(
        '✅ Logged In!',
        'Welcome, ${_auth.currentUser?.displayName ?? 'User'}!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1DD1A1),
        colorText: Colors.white,
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      debugPrint('AuthController: Google sign-in error: $e');
      Get.snackbar(
        'Sign-in Failed',
        'Could not sign in with Google. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Anonymous → Google migration, returns final UID ────────────────────────
  Future<String> _handleAnonymousMigration(
      User anonUser, AuthCredential credential) async {
    try {
      final linked = await anonUser.linkWithCredential(credential);
      final uid = linked.user!.uid;
      await _mergeCoins(anonUser.uid, uid);
      return uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        // Google account already exists — sign in and merge anon coins
        final result = await _auth.signInWithCredential(credential);
        final uid = result.user!.uid;
        await _mergeCoins(anonUser.uid, uid);
        return uid;
      }
      rethrow;
    }
  }

  // ── Merge coins from source UID into target UID ─────────────────────────────
  Future<void> _mergeCoins(String fromUid, String toUid) async {
    if (fromUid == toUid) return;
    try {
      final fromDoc = await _db.collection('users').doc(fromUid).get();
      final fromCoins = fromDoc.data()?['coins'] as int? ?? 0;
      final fromTxs = fromDoc.data()?['transactions'] as List? ?? [];

      final toDoc = await _db.collection('users').doc(toUid).get();
      final toCoins = toDoc.data()?['coins'] as int? ?? 0;
      final toTxs = toDoc.data()?['transactions'] as List? ?? [];

      final mergedCoins = fromCoins > toCoins ? fromCoins : toCoins;
      final mergedTxs = [...fromTxs, ...toTxs];

      await _db.collection('users').doc(toUid).set({
        'coins': mergedCoins,
        'transactions': mergedTxs,
        'lastSynced': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('AuthController: Coin merge error: $e');
    }
  }

  // ── Sign out ────────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _db.collection('users').doc(uid).set(
          {'deviceId': '', 'deviceName': ''}, SetOptions(merge: true));
    }
    await _googleSignIn.signOut();
    await _auth.signInAnonymously();
    await Get.find<WalletController>().syncWithFirestore();
  }
}
