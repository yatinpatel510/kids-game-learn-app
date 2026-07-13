import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controllers/auth_controller.dart';
import 'controllers/config_controller.dart';
import 'controllers/wallet_controller.dart';
import 'core/firestore_service.dart';
import 'core/ad_manager.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize Firebase and AdMob
  await FirestoreService.instance.initialize();
  await AdManager.instance.initialize();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const KidsLearnApp());
}

class KidsLearnApp extends StatelessWidget {
  const KidsLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kids Learn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.nunitoTextTheme(),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.home,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
      initialBinding: BindingsBuilder(() {
        Get.put(ConfigController(), permanent: true);
        Get.put(WalletController(), permanent: true);
        Get.put(AuthController(), permanent: true);
      }),
    );
  }
}
