import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/wallet_controller.dart';
import '../controllers/config_controller.dart';
import '../core/firestore_service.dart';
// import '../core/ad_manager.dart';
import '../core/app_colors.dart';
import '../widgets/animated_background.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletController walletCtrl = Get.find<WalletController>();
  final FirestoreService firestore = FirestoreService.instance;
  final ConfigController config = Get.find<ConfigController>();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();

  String selectedMethod = 'UPI ID';
  bool isAdShowing = false;
  int historyTabIndex = 0; // 0: Coin Log, 1: Withdrawals

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    amountController.dispose();
    detailsController.dispose();
    super.dispose();
  }

  // void _watchAd() {
  //   if (isAdShowing) return;
  //   setState(() => isAdShowing = true);

  //   AdManager.instance.showRewardedAd(
  //     onEarnedReward: () {
  //       walletCtrl.addCoins(50, 'Watched Rewarded Video Ad 📺');
  //       Get.snackbar(
  //         '🎉 Coins Earned!',
  //         'You earned 50 coins for watching the video ad.',
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: const Color(0xFF1DD1A1),
  //         colorText: Colors.white,
  //         borderRadius: 16,
  //         margin: const EdgeInsets.all(16),
  //       );
  //     },
  //     onAdDismissed: () {
  //       setState(() => isAdShowing = false);
  //     },
  //     onAdFailed: () {
  //       setState(() => isAdShowing = false);
  //       Get.snackbar(
  //         'Ad Not Ready',
  //         'Ad is loading or not available yet. Please try again in a few seconds.',
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: const Color(0xFFFECA57),
  //         colorText: Colors.white,
  //         borderRadius: 16,
  //         margin: const EdgeInsets.all(16),
  //       );
  //     },
  //   );
  // }

  void _submitWithdrawal() async {
    final amountText = amountController.text.trim();
    final details = detailsController.text.trim();

    if (amountText.isEmpty || details.isEmpty) {
      Get.snackbar(
        'Missing Fields',
        'Please enter the coins amount and payment details.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final coinsToRedeem = int.tryParse(amountText);
    if (coinsToRedeem == null || coinsToRedeem <= 0) {
      Get.snackbar(
        'Invalid Amount',
        'Please enter a valid positive number of coins.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (coinsToRedeem < 100) {
      Get.snackbar(
        'Minimum Limit',
        'Minimum withdrawal amount is 100 coins (₹10).',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (walletCtrl.coins.value < coinsToRedeem) {
      Get.snackbar(
        'Insufficient Balance',
        'You do not have enough coins to withdraw that amount.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final success = await walletCtrl.requestWithdrawal(
      coinsAmount: coinsToRedeem,
      paymentMethod: selectedMethod,
      accountDetails: details,
    );

    if (success) {
      amountController.clear();
      detailsController.clear();
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🎉 Request Submitted!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF5F27CD),
                  ),
                ),
                const SizedBox(height: 16),
                const Icon(
                  Icons.check_circle_outline,
                  size: 72,
                  color: Color(0xFF1DD1A1),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your request to withdraw $coinsToRedeem coins (₹${(coinsToRedeem / 10).toStringAsFixed(1)}) has been recorded.\n\nPayments are processed within 24-48 hours.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5F27CD),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Awesome!'),
                ),
              ],
            ),
          ),
        ),
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
              child: Column(
                children: [
                  // App Bar Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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
                            'Rewards Wallet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.titlePurple,
                            ),
                          ),
                        ),

                        Obx(
                          () => walletCtrl.isSyncing.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.titlePurple,
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(
                                    Icons.sync,
                                    color: AppColors.titlePurple,
                                  ),
                                  onPressed: walletCtrl.syncWithFirestore,
                                ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // // Connection Info Banner
                          // _buildConnectionBanner(),
                          // const SizedBox(height: 16),

                          // Wallet Balance Card
                          _buildBalanceCard(),
                          const SizedBox(height: 24),

                          // // Ad Reward Station
                          // _buildAdRewardStation(),
                          // const SizedBox(height: 24),

                          // Payout Section
                          _buildPayoutSection(),
                          const SizedBox(height: 24),

                          // Transactions Section
                          _buildTransactionsSection(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildLoginBanner() {
  //   return Obx(() {
  //     final auth = AuthController.to;
  //     if (auth.isLoggedInWithGoogle) {
  //       final u = auth.user.value!;
  //       return Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //         decoration: BoxDecoration(
  //           color: const Color(0xFF1DD1A1).withValues(alpha: 0.1),
  //           borderRadius: BorderRadius.circular(16),
  //           border: Border.all(color: const Color(0xFF1DD1A1), width: 1.5),
  //         ),
  //         child: Row(
  //           children: [
  //             CircleAvatar(
  //               radius: 18,
  //               backgroundImage: u.photoURL != null
  //                   ? NetworkImage(u.photoURL!)
  //                   : null,
  //               child: u.photoURL == null
  //                   ? const Icon(Icons.person, size: 18)
  //                   : null,
  //             ),
  //             const SizedBox(width: 10),
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     u.displayName ?? 'Google User',
  //                     style: const TextStyle(
  //                       fontSize: 13,
  //                       fontWeight: FontWeight.w800,
  //                       color: Color(0xFF159E7A),
  //                     ),
  //                   ),
  //                   Text(
  //                     u.email ?? '',
  //                     style: const TextStyle(fontSize: 11, color: Colors.grey),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             TextButton(
  //               onPressed: auth.signOut,
  //               child: const Text(
  //                 'Sign Out',
  //                 style: TextStyle(
  //                   fontSize: 12,
  //                   color: Color(0xFFFF6B6B),
  //                   fontWeight: FontWeight.w700,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     }

  //     return Container(
  //       padding: const EdgeInsets.all(16),
  //       decoration: BoxDecoration(
  //         color: Colors.white.withValues(alpha: 0.85),
  //         borderRadius: BorderRadius.circular(20),
  //         border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withValues(alpha: 0.05),
  //             blurRadius: 12,
  //             offset: const Offset(0, 4),
  //           ),
  //         ],
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.stretch,
  //         children: [
  //           const Row(
  //             children: [
  //               Text('🔐', style: TextStyle(fontSize: 20)),
  //               SizedBox(width: 8),
  //               Text(
  //                 'Save Your Progress',
  //                 style: TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.w900,
  //                   color: AppColors.titlePurple,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 6),
  //           const Text(
  //             'Sign in with Google to sync your coins across devices and enable reward redemption.',
  //             style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
  //           ),
  //           const SizedBox(height: 14),
  //           Obx(
  //             () => ElevatedButton.icon(
  //               onPressed: auth.isLoading.value ? null : auth.signInWithGoogle,
  //               icon: auth.isLoading.value
  //                   ? const SizedBox(
  //                       width: 18,
  //                       height: 18,
  //                       child: CircularProgressIndicator(
  //                         strokeWidth: 2,
  //                         color: Colors.white,
  //                       ),
  //                     )
  //                   : const Text(
  //                       'G',
  //                       style: TextStyle(
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.w900,
  //                         color: Color(0xFF4285F4),
  //                       ),
  //                     ),
  //               label: Text(
  //                 auth.isLoading.value
  //                     ? 'Signing in...'
  //                     : 'Continue with Google',
  //                 style: const TextStyle(
  //                   fontSize: 15,
  //                   fontWeight: FontWeight.w800,
  //                 ),
  //               ),
  //               style: ElevatedButton.styleFrom(
  //                 padding: const EdgeInsets.symmetric(vertical: 13),
  //                 backgroundColor: const Color(0xFF5F27CD),
  //                 foregroundColor: Colors.white,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(16),
  //                 ),
  //                 elevation: 3,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   });
  // }

  // Widget _buildConnectionBanner() {
  //   final isOnline = firestore.isInitialized;
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  //     decoration: BoxDecoration(
  //       color: isOnline
  //           ? const Color(0xFF1DD1A1).withValues(alpha: 0.1)
  //           : const Color(0xFFFECA57).withValues(alpha: 0.1),
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(
  //         color: isOnline ? const Color(0xFF1DD1A1) : const Color(0xFFFECA57),
  //         width: 1.5,
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(
  //           isOnline ? Icons.cloud_done_outlined : Icons.offline_bolt_outlined,
  //           color: isOnline ? const Color(0xFF1DD1A1) : const Color(0xFFFECA57),
  //         ),
  //         const SizedBox(width: 10),
  //         Expanded(
  //           child: Text(
  //             isOnline
  //                 ? 'Cloud Synced! Your balance is saved in Firestore.'
  //                 : 'Demo Mode (Offline). Rewards stored on device. Add Firebase config files to enable withdrawals.',
  //             style: TextStyle(
  //               fontSize: 12,
  //               fontWeight: FontWeight.w700,
  //               color: isOnline
  //                   ? const Color(0xFF159E7A)
  //                   : const Color(0xFFD69400),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFA500).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'TOTAL COIN BALANCE',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🪙', style: TextStyle(fontSize: 40)),
              const SizedBox(width: 8),
              Obx(
                () => Text(
                  '${walletCtrl.coins.value}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            final rupees = walletCtrl.coins.value / 10.0;
            return Text(
              'Estimated Value: ₹${rupees.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Widget _buildAdRewardStation() {
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: Colors.white.withValues(alpha: 0.8),
  //       borderRadius: BorderRadius.circular(28),
  //       border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha: 0.05),
  //           blurRadius: 16,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.stretch,
  //       children: [
  //         const Row(
  //           children: [
  //             Text('📺', style: TextStyle(fontSize: 22)),
  //             SizedBox(width: 8),
  //             Text(
  //               'Video Ads Reward Center',
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.w900,
  //                 color: AppColors.titlePurple,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 10),
  //         const Text(
  //           'Watch video ads to earn free bonus coins. You can watch ads as many times as you like to increase your balance!',
  //           style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
  //         ),
  //         const SizedBox(height: 16),
  //         ElevatedButton(
  //           onPressed: isAdShowing ? null : _watchAd,
  //           style: ElevatedButton.styleFrom(
  //             padding: const EdgeInsets.symmetric(vertical: 14),
  //             backgroundColor: const Color(0xFF5F27CD),
  //             foregroundColor: Colors.white,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(20),
  //             ),
  //             elevation: 4,
  //           ),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               if (isAdShowing)
  //                 const SizedBox(
  //                   width: 20,
  //                   height: 20,
  //                   child: CircularProgressIndicator(
  //                     strokeWidth: 2,
  //                     color: Colors.white,
  //                   ),
  //                 )
  //               else ...[
  //                 const Icon(Icons.play_circle_fill, size: 24),
  //                 const SizedBox(width: 8),
  //                 const Text(
  //                   'Watch Ad to Earn +50 Coins',
  //                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
  //                 ),
  //               ],
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildPayoutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Text('🎁', style: TextStyle(fontSize: 22)),
              SizedBox(width: 8),
              Text(
                'Redeem Coins for Cash',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.titlePurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Obx(
            () => Text(
              'Rate: ${config.conversionRate.value}. Min withdrawal is 100 Coins.',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),

          // Coins input field
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.monetization_on,
                color: Color(0xFFFFA500),
              ),
              labelText: 'Coins to Redeem',
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
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
          ),
          const SizedBox(height: 16),

          // Payment method dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedMethod,
                isExpanded: true,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                items: <String>['UPI ID', 'Paytm Number', 'PhonePe', 'PayPal']
                    .map((String val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(val),
                      );
                    })
                    .toList(),
                onChanged: (String? newVal) {
                  if (newVal != null) {
                    setState(() => selectedMethod = newVal);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Account details text field
          TextField(
            controller: detailsController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.payment, color: Color(0xFF5F27CD)),
              labelText: selectedMethod == 'UPI ID'
                  ? 'Enter UPI ID (e.g. name@upi)'
                  : selectedMethod == 'PayPal'
                  ? 'Enter PayPal Email'
                  : 'Enter Mobile Number',
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
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
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _submitWithdrawal,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: const Color(0xFF1DD1A1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
            ),
            child: const Text(
              'Submit Withdrawal Request',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('📊', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text(
                    'History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.titlePurple,
                    ),
                  ),
                ],
              ),
              DropdownButton<int>(
                value: historyTabIndex,
                underline: const SizedBox(),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.titlePurple,
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.titlePurple,
                  fontSize: 13,
                ),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Coins Log')),
                  DropdownMenuItem(value: 1, child: Text('Withdrawals')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => historyTabIndex = val);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (historyTabIndex == 0)
            _buildCoinsLog()
          else
            _buildWithdrawalsLog(),
        ],
      ),
    );
  }

  Widget _buildCoinsLog() {
    return Obx(() {
      if (walletCtrl.transactions.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              'No earnings yet. Play games to earn coins!',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: walletCtrl.transactions.length,
        separatorBuilder: (context, index) =>
            Divider(color: Colors.grey.shade200, height: 1),
        itemBuilder: (context, index) {
          final tx = walletCtrl.transactions[index];
          final isCredit = tx['type'] == 'credit';
          final timestamp = tx['timestamp'] != null
              ? DateTime.parse(tx['timestamp'].toString())
              : DateTime.now();
          final formattedDate =
              '${timestamp.day}/${timestamp.month} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCredit
                        ? const Color(0xFF1DD1A1).withValues(alpha: 0.15)
                        : const Color(0xFFFF6B6B).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    isCredit ? '🪙' : '💸',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx['reason'] ??
                            (isCredit ? 'Coins Credited' : 'Coins Redeemed'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.titlePurple,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isCredit ? "+" : "-"}${tx['amount']}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isCredit
                        ? const Color(0xFF1DD1A1)
                        : const Color(0xFFFF6B6B),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildWithdrawalsLog() {
    return Obx(() {
      if (walletCtrl.userPayouts.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              'No payout requests yet.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: walletCtrl.userPayouts.length,
        separatorBuilder: (context, index) =>
            Divider(color: Colors.grey.shade200, height: 1),
        itemBuilder: (context, index) {
          final payout = walletCtrl.userPayouts[index];
          final coinsRedeemed = payout['coinsRedeemed'] ?? 0;
          final double amountRupees =
              (payout['amountRupees'] as num?)?.toDouble() ??
              (coinsRedeemed / 10.0);
          final method = payout['paymentMethod'] ?? 'UPI';
          final details = payout['accountDetails'] ?? '';
          final status = (payout['status'] ?? 'pending')
              .toString()
              .toLowerCase();

          DateTime timestamp;
          if (payout['timestamp'] is Timestamp) {
            timestamp = (payout['timestamp'] as Timestamp).toDate();
          } else if (payout['timestamp'] is String) {
            timestamp = DateTime.parse(payout['timestamp'].toString());
          } else {
            timestamp = DateTime.now();
          }
          final formattedDate =
              '${timestamp.day}/${timestamp.month} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

          Color statusColor = const Color(0xFFFECA57);
          if (status == 'completed' || status == 'approved')
            statusColor = const Color(0xFF1DD1A1);
          if (status == 'rejected') statusColor = const Color(0xFFFF6B6B);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('💸', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Redeemed 🪙$coinsRedeemed (₹$amountRupees)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.titlePurple,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$method: $details',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
