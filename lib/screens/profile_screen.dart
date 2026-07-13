import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/wallet_controller.dart';
import '../core/app_colors.dart';
import '../routes/app_routes.dart';
import '../widgets/animated_background.dart';

class ProfileScreen extends StatelessWidget {
  final bool showBackButton;
  const ProfileScreen({super.key, this.showBackButton = false});

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
                 
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      child: Column(
                        children: [
                          _ProfileHeader(),
                          const SizedBox(height: 24),
                          _AccountSection(),
                          const SizedBox(height: 16),
                          _SettingsSection(),
                          const SizedBox(height: 16),
                          _AboutSection(),
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


}

// ── Profile Header ─────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final auth = AuthController.to;
      final u = auth.user.value;
      final isGoogle = auth.isLoggedInWithGoogle;
      final profile = auth.firestoreProfile.value;

      final firstName = profile?['firstName'] as String? ?? '';
      final lastName = profile?['lastName'] as String? ?? '';
      final fullName = [
        firstName,
        lastName,
      ].where((s) => s.isNotEmpty).join(' ');
      final email = profile?['email'] as String? ?? u?.email ?? '';
      final photoUrl = profile?['photoUrl'] as String? ?? u?.photoURL;

      String memberSince = '';
      final createdAt = profile?['createdAt'];
      if (createdAt is Timestamp) {
        final d = createdAt.toDate();
        memberSince = 'Member since ${d.day}/${d.month}/${d.year}';
      }

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5F27CD), Color(0xFFA18CD1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5F27CD).withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top row: avatar + info
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        backgroundImage: isGoogle && photoUrl != null
                            ? NetworkImage(photoUrl)
                            : null,
                        child: (!isGoogle || photoUrl == null)
                            ? const Text('👤', style: TextStyle(fontSize: 38))
                            : null,
                      ),
                      if (isGoogle)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1DD1A1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isGoogle
                              ? (fullName.isNotEmpty ? fullName : 'User')
                              : 'Guest User',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        if (isGoogle && email.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.email_outlined,
                                color: Colors.white60,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  email,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (memberSince.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            memberSince,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,)

            // Bottom: name chips + sync badge
          ],
        ),
      );
    });
  }
}

// ── Account Section ────────────────────────────────────────────────────────────
class _AccountSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final auth = AuthController.to;
      final isGoogle = auth.isLoggedInWithGoogle;

      return _SectionCard(
        title: 'ACCOUNT',
        icon: '👤',
        children: [
          if (isGoogle) ...[
            const _Divider(),
            _SettingsTile(
              icon: Icons.account_circle_rounded,
              iconColor: const Color(0xFF43E97B),
              title: 'Google Account',
              subtitle: 'Connected',
              onTap: null,
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1DD1A1).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1DD1A1),
                  ),
                ),
              ),
            ),
            const _Divider(),
            _SettingsTile(
              icon: Icons.logout_rounded,
              iconColor: const Color(0xFFFF6B6B),
              title: 'Sign Out',
              subtitle: 'Switch to guest mode',
              onTap: () => _showSignOutDialog(auth),
              titleColor: const Color(0xFFFF6B6B),
            ),
          ] else ...[
            _SettingsTile(
              icon: Icons.login_rounded,
              iconColor: const Color(0xFF5F27CD),
              title: 'Sign in with Google',
              subtitle: 'Save progress & sync across devices',
              onTap: auth.isLoading.value ? null : auth.signInWithGoogle,
              trailing: auth.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF5F27CD),
                      ),
                    )
                  : const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.grey,
                    ),
            ),
          ],
        ],
      );
    });
  }

  void _showSignOutDialog(AuthController auth) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('👋', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text(
                'Sign Out?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.titlePurple,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You will be switched to guest mode.\nYour coins are safely saved in the cloud.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await auth.signOut();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B6B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Settings Section ───────────────────────────────────────────────────────────
class _SettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'SETTINGS',
      icon: '⚙️',
      children: [
        _SettingsTile(
          icon: Icons.account_balance_wallet_rounded,
          iconColor: const Color(0xFFFFA500),
          title: 'Rewards Wallet',
          subtitle: 'View coins, earn & redeem rewards',
          onTap: () => Get.toNamed(AppRoutes.wallet),
          trailing: Obx(() {
            final coins = Get.find<WalletController>().coins.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '🪙 $coins',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            );
          }),
        ),
        const _Divider(),
        _SettingsTile(
          icon: Icons.admin_panel_settings_rounded,
          iconColor: const Color(0xFF5F27CD),
          title: 'Admin Panel',
          subtitle: 'Manage content & settings',
          onTap: () => Get.toNamed(AppRoutes.adminPanel),
        ),
      ],
    );
  }
}

// ── About Section ──────────────────────────────────────────────────────────────
class _AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'ABOUT',
      icon: 'ℹ️',
      children: [
        _SettingsTile(
          icon: Icons.description_rounded,
          iconColor: const Color(0xFF4FACFE),
          title: 'Terms & Conditions',
          subtitle: 'Read our terms of use',
          onTap: () => _showLegal(
            title: '📄 Terms & Conditions',
            content: _termsContent,
          ),
        ),
        const _Divider(),
        _SettingsTile(
          icon: Icons.privacy_tip_rounded,
          iconColor: const Color(0xFF43E97B),
          title: 'Privacy Policy',
          subtitle: 'How we handle your data',
          onTap: () =>
              _showLegal(title: '🔒 Privacy Policy', content: _privacyContent),
        ),
        const _Divider(),
        _SettingsTile(
          icon: Icons.info_outline_rounded,
          iconColor: const Color(0xFFFECA57),
          title: 'App Version',
          subtitle: '1.0.0',
          onTap: null,
        ),
      ],
    );
  }

  void _showLegal({required String title, required String content}) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.82,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.titlePurple,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Text(
                  content,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.7,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: const Color(0xFF5F27CD),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Got it!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  static const _termsContent = '''Welcome to Kids Learn App!

By using this application, you agree to the following terms:

1. Usage
This app is designed for educational purposes for children. Parents and guardians are responsible for supervising usage.

2. Rewards & Coins
Coins earned through watching ads or completing activities can be redeemed for real rewards. Minimum redemption is 100 coins (₹10). Rewards are processed within 24-48 hours.

3. Account
You may use the app as a guest or sign in with Google. Your data is securely stored in Firebase. Only one device session is allowed per account at a time.

4. Ads
This app displays rewarded video advertisements. Ad content is provided by Google AdMob and is subject to Google's advertising policies.

5. Content
All educational content is provided for learning purposes. We reserve the right to update content at any time.

6. Prohibited Use
You may not attempt to manipulate coin balances, exploit the reward system, or use the app for any unlawful purpose.

7. Changes
We reserve the right to modify these terms at any time. Continued use of the app constitutes acceptance of updated terms.

Contact us at support@kidslearnapp.com for any queries.''';

  static const _privacyContent = '''Your privacy matters to us.

1. Data We Collect
- Google account info (name, email, photo) when you sign in
- Device identifier for single-session enforcement
- Coin balance and transaction history
- App usage data for improving the experience

2. How We Use Data
- To sync your progress across devices
- To process reward redemptions
- To prevent fraud and abuse

3. Data Storage
All data is stored securely in Google Firebase (Firestore). We do not sell your data to third parties.

4. Ads
We use Google AdMob to display rewarded video ads. AdMob may collect device identifiers for ad personalization. See Google's Privacy Policy for details.

5. Children's Privacy
This app is designed for children. We collect minimal data and do not knowingly collect personal information from children under 13 without parental consent.

6. Data Deletion
You may request deletion of your account data by contacting us at support@kidslearnapp.com.

7. Contact
For privacy concerns, contact: support@kidslearnapp.com''';
}

// ── Reusable Widgets ───────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title, icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.subtitlePurple,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: titleColor ?? AppColors.titlePurple,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),
            trailing ??
                (onTap != null
                    ? const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Colors.grey,
                      )
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 72,
      endIndent: 16,
      color: Colors.grey.withValues(alpha: 0.15),
    );
  }
}
