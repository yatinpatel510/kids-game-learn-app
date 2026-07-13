import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/app_colors.dart';

// ── top bar ──────────────────────────────────────────────────────────────────
class LearnTopBar extends StatelessWidget {
  final String title;
  const LearnTopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: AppColors.navButton,
          ),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.titlePurple)),
        ],
      ),
    );
  }
}

// ── progress bar ─────────────────────────────────────────────────────────────
class LearnProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final Color activeColor;

  const LearnProgressBar({
    super.key,
    required this.current,
    required this.total,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final progress = current / total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$current of $total', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.subtitlePurple)),
              Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.progressRed)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation(activeColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ── main card (letter or number) ─────────────────────────────────────────────
class LearnMainCard extends StatelessWidget {
  final String text;
  final List<Color> gradient;
  final double fontSize;

  const LearnMainCard({
    super.key,
    required this.text,
    required this.gradient,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width * 0.55;
    return Container(
      width: w,
      height: w,
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradient),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: gradient[0].withValues(alpha: 0.5), blurRadius: 30, offset: const Offset(0, 12))],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black26, blurRadius: 8, offset: Offset(3, 4))],
          ),
        ),
      ),
    );
  }
}

// ── emoji card ────────────────────────────────────────────────────────────────
class LearnEmojiCard extends StatelessWidget {
  final String emoji;
  const LearnEmojiCard({super.key, required this.emoji});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Text(emoji, style: TextStyle(fontSize: size.width * 0.22)),
    );
  }
}

// ── word label ────────────────────────────────────────────────────────────────
class LearnWordLabel extends StatelessWidget {
  final String word;
  const LearnWordLabel({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    final letters = word.toUpperCase().split('');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(letters.length, (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Text(
            letters[i],
            style: TextStyle(
              fontSize: i == 0 ? 34 : 28,
              fontWeight: FontWeight.w900,
              color: AppColors.wordLetterColors[i % AppColors.wordLetterColors.length],
            ),
          ),
        )),
      ),
    );
  }
}

// ── nav button ────────────────────────────────────────────────────────────────
class LearnNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const LearnNavButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.white.withValues(alpha: 0.4),
          shape: BoxShape.circle,
          boxShadow: enabled ? [BoxShadow(color: AppColors.navButton.withValues(alpha: 0.25), blurRadius: 14, offset: const Offset(0, 5))] : [],
        ),
        child: Icon(icon, color: enabled ? AppColors.navButton : AppColors.navButton.withValues(alpha: 0.3), size: 26),
      ),
    );
  }
}

// ── speak button ──────────────────────────────────────────────────────────────
class LearnSpeakButton extends StatelessWidget {
  final bool isSpeaking;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const LearnSpeakButton({
    super.key,
    required this.isSpeaking,
    required this.color,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: isSpeaking ? 30 : 16, spreadRadius: isSpeaking ? 4 : 0, offset: const Offset(0, 6))],
        ),
        child: Icon(isSpeaking ? Icons.volume_up_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 38),
      ),
    );
  }
}
