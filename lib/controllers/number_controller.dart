import 'package:get/get.dart';
import '../models/number_model.dart';
import '../core/app_constants.dart';
import '../core/firestore_service.dart';
import 'base_learn_controller.dart';

class NumberController extends BaseLearnController {
  final items = <NumberModel>[].obs;

  NumberModel get current => items[index.value];

  @override
  int get total => items.length;

  @override
  String get categoryId => 'numbers';

  @override
  String itemIdAt(int i) => items.isEmpty ? '' : '${items[i].number}';

  @override
  String get currentSpeakText => items.isEmpty ? '' : current.speakText;

  @override
  void onInit() {
    _loadData().then((_) => super.onInit());
  }

  Future<void> _loadData() async {
    final catDef = AppConstants.learnCategories.firstWhere((c) => c.id == 'numbers');
    final list = await FirestoreService.instance.fetchCategoryItems(catDef);
    items.value = list.map(NumberModel.fromJson).toList();
  }
}
