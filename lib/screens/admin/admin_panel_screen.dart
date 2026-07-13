import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/firestore_service.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/animated_background.dart';
import '../../controllers/config_controller.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final FirestoreService firestore = FirestoreService.instance;
  final TextEditingController pinController = TextEditingController();
  final RxBool isVerified = false.obs;
  final RxBool isLoading = false.obs;

  // Settings tab controllers
  final TextEditingController upiController = TextEditingController();
  final TextEditingController passcodeController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController learnSubtitleController = TextEditingController();
  final TextEditingController gamesSubtitleController = TextEditingController();
  final TextEditingController rateController = TextEditingController();

  // Manage Cards tab properties
  String selectedCategoryId = AppConstants.learnCategories[0].id;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    pinController.dispose();
    upiController.dispose();
    passcodeController.dispose();
    titleController.dispose();
    learnSubtitleController.dispose();
    gamesSubtitleController.dispose();
    rateController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final settings = await firestore.fetchAdminSettings();
    upiController.text = settings['adminUpiId'] ?? 'admin@upi';
    passcodeController.text = settings['adminPasscode'] ?? '123456';

    try {
      final config = Get.find<ConfigController>();
      titleController.text = config.appTitle.value;
      learnSubtitleController.text = config.learnSubtitle.value;
      gamesSubtitleController.text = config.gamesSubtitle.value;
      rateController.text = config.conversionRate.value;
    } catch (_) {}
  }

  void _checkPasscode() async {
    final entered = pinController.text.trim();
    if (entered.isEmpty) return;

    isLoading.value = true;
    final settings = await firestore.fetchAdminSettings();
    final correctPasscode = settings['adminPasscode'] ?? '123456';
    isLoading.value = false;

    if (entered == correctPasscode) {
      isVerified.value = true;
      Get.snackbar(
        'Welcome Admin',
        'Authentication successful!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1DD1A1),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Access Denied',
        'Invalid admin passcode. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.bgGradient,
          ),
        ),
        child: Stack(
          children: [
            const AnimatedBackground(),
            SafeArea(
              child: Obx(() {
                if (!isVerified.value) {
                  return _buildLoginView();
                }
                return _buildAdminDashboard();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF5F27CD).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  size: 64,
                  color: Color(0xFF5F27CD),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Admin Authorization',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.titlePurple,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter passcode to access admin controls',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF5F27CD),
                  ),
                  labelText: 'Security Passcode',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF5F27CD),
                      width: 2,
                    ),
                  ),
                ),
                onSubmitted: (_) => _checkPasscode(),
              ),
              const SizedBox(height: 24),
              Obx(
                () => ElevatedButton(
                  onPressed: isLoading.value ? null : _checkPasscode,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 14,
                    ),
                    backgroundColor: const Color(0xFF5F27CD),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                  ),
                  child: isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Verify & Enter',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Go Back to Wallet',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminDashboard() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // App bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.titlePurple,
                  ),
                  onPressed: () => Get.back(),
                ),
                const Expanded(
                  child: Text(
                    '🛡️ Admin Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.titlePurple,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Color(0xFFFF6B6B)),
                  onPressed: () {
                    isVerified.value = false;
                    pinController.clear();
                  },
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const TabBar(
              labelColor: Color(0xFF5F27CD),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF5F27CD),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
              tabs: [
                Tab(icon: Icon(Icons.upload), text: 'Payouts'),
                Tab(icon: Icon(Icons.library_books), text: 'Manage Cards'),
                Tab(icon: Icon(Icons.settings), text: 'Settings'),
              ],
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              children: [
                _buildPayoutsTab(),
                _buildManageCardsTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. Payouts Tab ─────────────────────────────────────────────────────────
  Widget _buildPayoutsTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestore.streamPendingPayouts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF5F27CD)),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(
            'No pending payouts requests! 🪙',
            Icons.check_circle_outline,
          );
        }

        final requests = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            final reqId = req['id'].toString();
            final userId = req['userId']?.toString() ?? 'Unknown User';
            final int coins = (req['coinsRedeemed'] as num?)?.toInt() ?? 0;
            final double rupees =
                (req['amountRupees'] as num?)?.toDouble() ?? (coins / 10.0);
            final method = req['paymentMethod']?.toString() ?? 'UPI';
            final details = req['accountDetails']?.toString() ?? 'N/A';
            final Timestamp? time = req['timestamp'] as Timestamp?;
            final dateStr = time != null
                ? time.toDate().toString().substring(0, 16)
                : 'Just now';

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white.withValues(alpha: 0.95),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '🪙 $coins (₹$rupees)',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFF9F43),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFF9F43,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'PAYOUT REQUEST',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF9F43),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildClaimField('User ID:', userId, isCode: true),
                    _buildClaimField('Method:', method),
                    _buildClaimField(
                      'Account:',
                      details,
                      isCode: true,
                      canCopy: true,
                    ),
                    _buildClaimField('Requested:', dateStr),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B6B),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () =>
                                _rejectPayoutRequest(reqId, userId, coins),
                            child: const Text(
                              'Reject (Refund)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1DD1A1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _approvePayoutRequest(reqId),
                            child: const Text(
                              'Mark as Paid',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _approvePayoutRequest(String payoutId) async {
    try {
      await firestore.approvePayout(payoutId);
      Get.snackbar(
        'Payout Processed!',
        'Payout marked as completed/paid successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1DD1A1),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Approval failed: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _rejectPayoutRequest(
    String payoutId,
    String userId,
    int coinsAmount,
  ) async {
    try {
      await firestore.rejectPayout(payoutId, userId, coinsAmount);
      Get.snackbar(
        'Payout Rejected',
        'Payout rejected. $coinsAmount coins refunded to user wallet.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Rejection failed: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ── 3. Add Learn Data Tab ──────────────────────────────────────────────────
  // ── 3. Manage Cards Tab ────────────────────────────────────────────────────
  Widget _buildManageCardsTab() {
    return Column(
      children: [
        // Control Header (Category selection and Add button)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Select Category to Manage',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCategoryId,
                            isExpanded: true,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            items: AppConstants.learnCategories.map((cat) {
                              return DropdownMenuItem<String>(
                                value: cat.id,
                                child: Text('${cat.emoji} ${cat.title}'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null)
                                setState(() => selectedCategoryId = val);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _showAddCardDialog,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text(
                        'Add Card',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1DD1A1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // List of items in that category
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: firestore.streamCategoryItems(selectedCategoryId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF5F27CD)),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState(
                    'No items found. Click Add Card to create one!',
                    Icons.library_books_outlined,
                  );
                }
                final cards = snapshot.data!;
                return ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: cards.length,
                  separatorBuilder: (context, index) =>
                      Divider(color: Colors.grey.shade200, height: 1),
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    final docId = card['docId'].toString();
                    final id = card['id']?.toString() ?? '';
                    final title =
                        card['title']?.toString() ??
                        card['letter']?.toString() ??
                        '';
                    final emoji = card['emoji']?.toString() ?? '';
                    final fact = card['fact']?.toString() ?? '';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(
                          0xFF5F27CD,
                        ).withValues(alpha: 0.1),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      title: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        'ID: $id\nFact: $fact',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Color(0xFF5F27CD),
                              size: 20,
                            ),
                            onPressed: () => _showEditCardDialog(docId, card),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Color(0xFFFF6B6B),
                              size: 20,
                            ),
                            onPressed: () => _confirmDeleteCard(docId, title),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showAddCardDialog() {
    final TextEditingController addIdCtrl = TextEditingController();
    final TextEditingController addTitleCtrl = TextEditingController();
    final TextEditingController addEmojiCtrl = TextEditingController();
    final TextEditingController addFactCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '🆕 Add Card to ${AppConstants.learnCategories.firstWhere((c) => c.id == selectedCategoryId).title}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.titlePurple,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: addIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'Item ID (e.g. apple, lion)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addTitleCtrl,
                decoration: const InputDecoration(labelText: 'Display Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addEmojiCtrl,
                decoration: const InputDecoration(
                  labelText: 'Emoji Representation',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addFactCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Fun Fact / Description',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final id = addIdCtrl.text.trim().toLowerCase();
              final title = addTitleCtrl.text.trim();
              final emoji = addEmojiCtrl.text.trim();
              final fact = addFactCtrl.text.trim();

              if (id.isEmpty || title.isEmpty || emoji.isEmpty) {
                Get.snackbar(
                  'Validation Error',
                  'ID, Title and Emoji are required!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFFFF6B6B),
                  colorText: Colors.white,
                );
                return;
              }

              final itemData = {
                'id': id,
                'title': title,
                'emoji': emoji,
                'fact': fact.isNotEmpty ? fact : '$title is fun to learn!',
              };

              try {
                await firestore.addLearningItem(
                  categoryId: selectedCategoryId,
                  itemData: itemData,
                );
                Get.back();
                Get.snackbar(
                  'Success',
                  'Card "$title" added successfully.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFF1DD1A1),
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to add card: $e',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1DD1A1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Add Card',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditCardDialog(String docId, Map<String, dynamic> card) {
    final TextEditingController editTitleCtrl = TextEditingController(
      text: card['title']?.toString() ?? card['letter']?.toString() ?? '',
    );
    final TextEditingController editEmojiCtrl = TextEditingController(
      text: card['emoji']?.toString() ?? '',
    );
    final TextEditingController editFactCtrl = TextEditingController(
      text: card['fact']?.toString() ?? '',
    );

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '✏️ Edit Card Info',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.titlePurple,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editTitleCtrl,
                decoration: const InputDecoration(labelText: 'Display Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: editEmojiCtrl,
                decoration: const InputDecoration(
                  labelText: 'Emoji Representation',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: editFactCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Fun Fact / Description',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = editTitleCtrl.text.trim();
              final emoji = editEmojiCtrl.text.trim();
              final fact = editFactCtrl.text.trim();

              if (title.isEmpty || emoji.isEmpty) {
                Get.snackbar(
                  'Validation Error',
                  'Title and Emoji are required!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFFFF6B6B),
                  colorText: Colors.white,
                );
                return;
              }

              final updatedData = {
                'title': title,
                'emoji': emoji,
                'fact': fact,
              };

              try {
                await firestore.updateLearningItem(
                  docId: docId,
                  itemData: updatedData,
                );
                Get.back();
                Get.snackbar(
                  'Updated',
                  'Card updated successfully.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFF1DD1A1),
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to update: $e',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5F27CD),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCard(String docId, String title) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🗑️ Delete Card?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to permanently delete "$title" card? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await firestore.deleteLearningItem(docId: docId);
                Get.back();
                Get.snackbar(
                  'Deleted',
                  '"$title" has been deleted.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFFFF6B6B),
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to delete: $e',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. Settings Tab ────────────────────────────────────────────────────────
  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '⚙️ Global Admin Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.titlePurple,
              ),
            ),
            const SizedBox(height: 20),

            _buildInputField(
              upiController,
              'Enter payment receiver UPI ID',
              'Admin UPI ID',
            ),
            const SizedBox(height: 16),

            _buildInputField(
              passcodeController,
              'Change passcode to enter admin panel',
              'Admin Security Passcode',
              isObscured: true,
            ),
            const SizedBox(height: 16),

            _buildInputField(
              titleController,
              'Enter dynamic App Title (e.g. Kids Learn)',
              'App Title / Heading',
            ),
            const SizedBox(height: 16),

            _buildInputField(
              learnSubtitleController,
              'Enter Learn Tab Subtitle',
              'Learn Subtitle',
            ),
            const SizedBox(height: 16),

            _buildInputField(
              gamesSubtitleController,
              'Enter Games Tab Subtitle',
              'Games Subtitle',
            ),
            const SizedBox(height: 16),

            _buildInputField(
              rateController,
              'Enter Conversion Rate text (e.g. ₹1 = 10 Coins)',
              'Conversion Rate Text',
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: const Color(0xFF1DD1A1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Save Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveSettings() async {
    final upi = upiController.text.trim();
    final pass = passcodeController.text.trim();
    final title = titleController.text.trim();
    final learnSub = learnSubtitleController.text.trim();
    final gamesSub = gamesSubtitleController.text.trim();
    final rate = rateController.text.trim();

    if (upi.isEmpty ||
        pass.isEmpty ||
        title.isEmpty ||
        learnSub.isEmpty ||
        gamesSub.isEmpty ||
        rate.isEmpty) {
      Get.snackbar(
        'Error',
        'All settings fields are required.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Update dynamic configuration in Firestore via ConfigController
      await Get.find<ConfigController>().updateConfig(
        upiId: upi,
        passcode: pass,
        title: title,
        learnSub: learnSub,
        gamesSub: gamesSub,
        rate: rate,
      );

      // Save admin credential settings online
      await firestore.updateAdminSettings(upi, pass);

      Get.snackbar(
        'Settings Saved',
        'Configuration updated dynamically in Firestore database.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1DD1A1),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Update failed: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Helper widgets
  Widget _buildClaimField(
    String label,
    String value, {
    bool isCode = false,
    bool canCopy = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onLongPress: canCopy
                  ? () {
                      Clipboard.setData(ClipboardData(text: value));
                      Get.snackbar(
                        'Copied',
                        'Copied to clipboard!',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 1),
                      );
                    }
                  : null,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isCode ? FontWeight.bold : FontWeight.normal,
                  fontFamily: isCode ? 'Courier' : null,
                  color: isCode ? Colors.black87 : Colors.black54,
                ),
              ),
            ),
          ),
          if (canCopy)
            IconButton(
              icon: const Icon(Icons.copy, size: 14, color: Colors.grey),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                Get.snackbar(
                  'Copied',
                  'Copied to clipboard!',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 1),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String hint,
    String label, {
    int maxLines = 1,
    bool isObscured = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      obscureText: isObscured,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF5F27CD), width: 2),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String text, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
