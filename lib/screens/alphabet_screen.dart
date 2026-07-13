import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/alphabet_controller.dart';
import '../core/app_colors.dart';
import '../widgets/animated_background.dart';
import '../widgets/learn_widgets.dart';

class AlphabetScreen extends StatelessWidget {
  const AlphabetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AlphabetController>();

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
                if (c.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                final size = MediaQuery.of(context).size;
                return Column(
                  children: [
                    const LearnTopBar(title: 'Alphabets'),
                    LearnProgressBar(
                      current: c.index.value + 1,
                      total: c.total,
                      activeColor: c.current.gradient[0],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ScaleTransition(
                              scale: c.cardScale,
                              child: LearnMainCard(
                                text: c.current.letter,
                                gradient: c.current.gradient,
                                fontSize: size.width * 0.28,
                              ),
                            ),
                            ScaleTransition(
                              scale: c.emojiScale,
                              child: LearnEmojiCard(emoji: c.current.emoji),
                            ),
                            LearnWordLabel(word: c.current.word),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                LearnNavButton(icon: Icons.arrow_back_ios_new_rounded, onTap: c.index.value > 0 ? c.prev : null),
                                LearnSpeakButton(
                                  isSpeaking: c.isSpeaking.value,
                                  color: c.current.gradient[0],
                                  onTap: c.speak,
                                  onLongPress: () => _showVoicePicker(c),
                                ),
                                LearnNavButton(icon: Icons.arrow_forward_ios_rounded, onTap: c.index.value < c.total - 1 ? c.next : null),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showVoicePicker(AlphabetController c) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 14),
            const Text('🎙️ Choose Voice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.subtitlePurple)),
            const SizedBox(height: 10),
            Obx(() => ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: Get.height * 0.38),
                  child: c.voices.isEmpty
                      ? const Padding(padding: EdgeInsets.all(20), child: Text('No voices found'))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: c.voices.length,
                          itemBuilder: (_, i) {
                            final v = c.voices[i];
                            final selected = c.selectedVoice.value?['name'] == v['name'];
                            return ListTile(
                              onTap: () { c.setVoice(v); Get.back(); },
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              tileColor: selected ? AppColors.voiceSelectedBg : null,
                              leading: CircleAvatar(
                                backgroundColor: selected ? AppColors.voiceSelected : Colors.grey[200],
                                child: Icon(Icons.record_voice_over_rounded, color: selected ? Colors.white : Colors.grey[600], size: 18),
                              ),
                              title: Text(v['name'] ?? '', style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? AppColors.voiceSelected : Colors.black87)),
                              subtitle: Text(v['locale'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                              trailing: selected ? const Icon(Icons.check_circle_rounded, color: AppColors.voiceSelected) : null,
                            );
                          },
                        ),
                )),
          ],
        ),
      ),
    );
  }
}
