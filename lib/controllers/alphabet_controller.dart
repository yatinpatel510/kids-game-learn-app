import 'package:get/get.dart';
import '../models/alphabet_model.dart';
import '../core/app_constants.dart';
import '../core/firestore_service.dart';
import 'base_learn_controller.dart';

class AlphabetController extends BaseLearnController {
  final items = <AlphabetModel>[].obs;
  final voices = <Map<String, String>>[].obs;
  final selectedVoice = Rxn<Map<String, String>>();

  AlphabetModel get current => items[index.value];

  @override
  int get total => items.length;

  @override
  String get categoryId => 'alphabets';

  @override
  String itemIdAt(int i) => items.isEmpty ? '' : items[i].letter;

  @override
  String get currentSpeakText => items.isEmpty ? '' : current.speakText;

  @override
  void onInit() {
    _loadData().then((_) {
      super.onInit();
      _loadVoices();
    });
  }

  Future<void> _loadData() async {
    final catDef = AppConstants.learnCategories.firstWhere((c) => c.id == 'alphabets');
    final list = await FirestoreService.instance.fetchCategoryItems(catDef);
    items.value = list.map(AlphabetModel.fromJson).toList();
  }

  Future<void> _loadVoices() async {
    final raw = await tts.getVoices;
    if (raw == null) return;
    voices.value = (raw as List)
        .map((v) => Map<String, String>.from(v as Map))
        .where((v) => (v['locale'] ?? '').startsWith('en'))
        .toList();
  }

  void setVoice(Map<String, String> v) async {
    await tts.setVoice(v);
    selectedVoice.value = v;
    speak();
  }

  @override
  Future<void> speak() async {
    if (isSpeaking.value || items.isEmpty) return;
    isSpeaking.value = true;
    if (selectedVoice.value != null) {
      await tts.setVoice(selectedVoice.value!);
    } else if (voices.isNotEmpty) {
      await tts.setVoice(voices.first);
    }
    await tts.setLanguage('en-US');
    await tts.setSpeechRate(0.42);
    await tts.setPitch(1.5);
    await tts.setVolume(1.0);
    tts.setCompletionHandler(() => isSpeaking.value = false);
    await tts.speak(currentSpeakText);
  }
}
