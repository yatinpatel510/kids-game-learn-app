import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/config_controller.dart';
import '../controllers/wallet_controller.dart';
import '../core/app_colors.dart';
import '../core/app_constants.dart';
import '../routes/app_routes.dart';
import '../widgets/animated_background.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(_HomeController());

    return Scaffold(
      body: Obx(() {
        final idx = ctrl.tabIndex.value;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: idx.toDouble()),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (context, val, _) {
            final colors = _gradientForTab(val);
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
              ),
              child: Stack(
                children: [
                  const AnimatedBackground(),
                  SafeArea(
                    child: Column(
                      children: [
                        _HomeHeader(tabIndex: idx),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, anim) => FadeTransition(
                              opacity: anim,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.04),
                                  end: Offset.zero,
                                ).animate(anim),
                                child: child,
                              ),
                            ),
                            child: _tabContent(idx),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
      bottomNavigationBar: _BottomNav(),
    );
  }

  // Interpolate gradient colors between tabs
  static List<Color> _gradientForTab(double val) {
    const tab0 = [Color(0xFFFFF9C4), Color(0xFFE1F5FE), Color(0xFFF8BBD9)];
    const tab1 = [Color(0xFFE8F5E9), Color(0xFFE3F2FD), Color(0xFFF3E5F5)];
    const tab2 = [Color(0xFFF3E5F5), Color(0xFFEDE7F6), Color(0xFFE8EAF6)];

    final t1 = val.clamp(0.0, 1.0);
    final t2 = (val - 1.0).clamp(0.0, 1.0);
    final base = [
      Color.lerp(tab0[0], tab1[0], t1)!,
      Color.lerp(tab0[1], tab1[1], t1)!,
      Color.lerp(tab0[2], tab1[2], t1)!,
    ];
    return [
      Color.lerp(base[0], tab2[0], t2)!,
      Color.lerp(base[1], tab2[1], t2)!,
      Color.lerp(base[2], tab2[2], t2)!,
    ];
  }

  Widget _tabContent(int index) {
    switch (index) {
      case 0:
        return _LearnTab(key: const ValueKey('learn'));
      case 1:
        return _GamesTab(key: const ValueKey('games'));
      case 2:
        return _ProfileTab(key: const ValueKey('profile'));
      default:
        return _LearnTab(key: const ValueKey('learn'));
    }
  }
}

// ── controller ────────────────────────────────────────────────────────────────
class _HomeController extends GetxController {
  final tabIndex = 0.obs;
  final prevIndex = 0.obs;

  void changeTab(int i) {
    prevIndex.value = tabIndex.value;
    tabIndex.value = i;
  }
}

// ── header ────────────────────────────────────────────────────────────────────
class _HomeHeader extends StatelessWidget {
  final int tabIndex;
  const _HomeHeader({required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    final config = Get.find<ConfigController>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    tabIndex == 0 ? '📚 ${config.appTitle.value}' : tabIndex == 1 ? '🎮 Games' : '👤 Profile',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.titlePurple,
                    ),
                  ),
                ),
                Obx(
                  () => Text(
                    tabIndex == 0
                        ? config.learnSubtitle.value
                        : tabIndex == 1
                            ? config.gamesSubtitle.value
                            : 'Manage your account & settings',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.subtitlePurple,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final wallet = Get.find<WalletController>();
            return GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.wallet),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFA500).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 5),
                    Text(
                      '${wallet.coins.value}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── bottom nav ────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  static const _items = [
    {'emoji': '📚', 'label': 'Learn',   'colors': [Color(0xFFA18CD1), Color(0xFFFBC2EB)]},
    {'emoji': '🎮', 'label': 'Games',   'colors': [Color(0xFF43E97B), Color(0xFF38F9D7)]},
    {'emoji': '👤', 'label': 'Profile', 'colors': [Color(0xFF4FACFE), Color(0xFF00F2FE)]},
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<_HomeController>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (i) {
                final colors = _items[i]['colors'] as List<Color>;
                final auth = AuthController.to;
                // Profile tab: show avatar instead of emoji
                final isProfile = i == 2;
                final photoUrl = isProfile && auth.isLoggedInWithGoogle
                    ? auth.user.value?.photoURL
                    : null;
                return _NavItem(
                  emoji: _items[i]['emoji'] as String,
                  label: _items[i]['label'] as String,
                  colors: colors,
                  selected: ctrl.tabIndex.value == i,
                  photoUrl: photoUrl,
                  onTap: () => ctrl.changeTab(i),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final String emoji, label;
  final List<Color> colors;
  final bool selected;
  final VoidCallback onTap;
  final String? photoUrl;

  const _NavItem({
    required this.emoji,
    required this.label,
    required this.colors,
    required this.selected,
    required this.onTap,
    this.photoUrl,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void didUpdateWidget(_NavItem old) {
    super.didUpdateWidget(old);
    if (widget.selected && !old.selected) {
      _anim.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final scale = widget.selected
              ? 1.0 + 0.28 * Curves.elasticOut.transform(_anim.value)
              : 1.0;
          return Transform.scale(
            scale: scale,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: widget.selected ? 20 : 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                gradient: widget.selected
                    ? LinearGradient(
                        colors: widget.colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.circular(24),
                boxShadow: widget.selected
                    ? [
                        BoxShadow(
                          color: widget.colors[0].withValues(alpha: 0.45),
                          blurRadius: 16,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      widget.photoUrl != null
                          ? CircleAvatar(
                              radius: widget.selected ? 14 : 15,
                              backgroundImage: NetworkImage(widget.photoUrl!),
                            )
                          : Text(
                              widget.emoji,
                              style: TextStyle(fontSize: widget.selected ? 22 : 24),
                            ),
                      if (widget.photoUrl != null)
                        Positioned(
                          right: -2, top: -2,
                          child: Container(
                            width: 9, height: 9,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1DD1A1),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: widget.selected
                        ? Row(
                            children: [
                              const SizedBox(width: 6),
                              Text(
                                widget.label,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LearnTab extends StatelessWidget {
  const _LearnTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.0,
      ),
      itemCount: AppConstants.learnCategories.length,
      itemBuilder: (_, i) {
        final cat = AppConstants.learnCategories[i];
        return _HomeCard(
          emoji: cat.emoji,
          title: cat.title,
          gradient: cat.gradient,
          onTap: () {
            if (cat.id == 'alphabets')
              Get.toNamed(AppRoutes.alphabet);
            else if (cat.id == 'numbers')
              Get.toNamed(AppRoutes.number);
            else
              Get.toNamed(AppRoutes.category, arguments: cat);
          },
        );
      },
    );
  }
}

// ── games tab ─────────────────────────────────────────────────────────────────
class _GamesTab extends StatelessWidget {
  const _GamesTab({super.key});

  static const _games = [
    {
      'id': 'quiz',
      'title': 'Quiz',
      'emoji': '❓',
      'gradient': 0,
      'desc': 'Test your knowledge',
    },
    {
      'id': 'memory',
      'title': 'Memory',
      'emoji': '🧠',
      'gradient': 4,
      'desc': 'Match card pairs',
    },
    {
      'id': 'matching',
      'title': 'Matching',
      'emoji': '🎯',
      'gradient': 6,
      'desc': 'Connect names to emojis',
    },
    {
      'id': 'spelling',
      'title': 'Spell It!',
      'emoji': '✏️',
      'gradient': 2,
      'desc': 'Spell the words',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.9,
      ),
      itemCount: _games.length,
      itemBuilder: (_, i) {
        final game = _games[i];
        final gameId = game['id'] as String;
        final gradIdx = game['gradient'] as int;
        return _GameCard(
          emoji: game['emoji'] as String,
          title: game['title'] as String,
          desc: game['desc'] as String,
          gradient: AppColors.cardGradients[gradIdx],
          onTap: () => Get.toNamed(AppRoutes.gameSelect, arguments: gameId),
        );
      },
    );
  }
}

class _GameCard extends StatelessWidget {
  final String emoji, title, desc;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _GameCard({
    required this.emoji,
    required this.title,
    required this.desc,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                desc,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── profile tab (inline in home) ────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  const _ProfileTab({super.key});

  @override
  Widget build(BuildContext context) => const ProfileScreen();
}

class _HomeCard extends StatelessWidget {
  final String emoji, title;
  final List<Color> gradient;
  final VoidCallback onTap;
  const _HomeCard({
    required this.emoji,
    required this.title,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 44)),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
