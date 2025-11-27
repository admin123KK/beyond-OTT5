import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:play_lab/data/controller/localization/localization_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart'; // ← NEW: Replaced keep_screen_on
import 'constants/my_strings.dart';
import 'core/di_service/di_service.dart' as di_service;
import 'core/helper/messages.dart';
import 'core/route/route.dart';
import 'core/theme/dark.dart';
import 'core/utils/my_color.dart';
import 'data/controller/auth/auth/signup_controller.dart';
import 'data/controller/auth/login_controller.dart';
import 'data/controller/auth/social_login_controller.dart';
import 'data/repo/auth/general_setting_repo.dart';
import 'data/repo/auth/login_repo.dart';
import 'data/repo/auth/signup_repo.dart';
import 'data/repo/auth/social_login_repo.dart';
import 'data/services/api_service.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Google Mobile Ads
  MobileAds.instance.initialize();

  // 2. Dependency Injection + Localization
  Map<String, Map<String, String>> languages = await di_service.init();

  // 3. Allow self-signed certificates
  HttpOverrides.global = MyHttpOverrides();

  // 4. System UI Overlay Style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: MyColor.colorGrey3,
    statusBarColor: MyColor.secondaryColor,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // 5. Keep screen on using wakelock_plus (Best practice in 2025)
  await WakelockPlus.enable(); // ← This replaces KeepScreenOn.turnOn(true)

  // 6. Register all GetX dependencies
  await _setupGetXDependencies();

  runApp(MyApp(languages: languages));
}

Future<void> _setupGetXDependencies() async {
  final sharedPreferences = Get.find<SharedPreferences>();

  Get.put(ApiClient(sharedPreferences: sharedPreferences));

  Get.put(GeneralSettingRepo(
      apiClient: Get.find(), sharedPreferences: sharedPreferences));
  Get.put(
      LoginRepo(apiClient: Get.find(), sharedPreferences: sharedPreferences));
  Get.put(SignupRepo(apiClient: Get.find()));
  Get.put(SocialLoginRepo(apiClient: Get.find()));

  Get.lazyPut(() => LoginController(loginRepo: Get.find()));
  Get.lazyPut(() => SignUpController(
      signUpRepo: Get.find(), sharedPreferences: sharedPreferences));
  Get.lazyPut(() => SocialLoginController(repo: Get.find()));
}

class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>> languages;

  const MyApp({super.key, required this.languages});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationController>(
      builder: (localizeController) {
        return GetMaterialApp(
          title: MyStrings.appName,
          initialRoute: RouteHelper.splashScreen,
          defaultTransition: Transition.topLevel,
          transitionDuration: const Duration(milliseconds: 500),
          getPages: RouteHelper.routes,
          navigatorKey: Get.key,
          theme: dark,
          debugShowCheckedModeBanner: false,
          locale: localizeController.locale,
          translations: Messages(languages: languages),
          fallbackLocale: Locale(
            localizeController.locale.languageCode,
            localizeController.locale.countryCode,
          ),
        );
      },
    );
  }
}
