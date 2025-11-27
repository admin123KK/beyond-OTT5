// lib/view/screens/splash/splash_screen.dart (or wherever it is)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/my_images.dart';

import '../../../data/controller/localization/localization_controller.dart';
import '../../../data/controller/splash_controller.dart';
import '../../../data/repo/auth/general_setting_repo.dart';
import '../../../data/repo/splash/splash_repo.dart';
import '../../../data/services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Initialize required dependencies
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(SplashRepo(apiClient: Get.find()));
    Get.put(GeneralSettingRepo(
        sharedPreferences: Get.find(), apiClient: Get.find()));
    Get.put(LocalizationController(sharedPreferences: Get.find()));
    final controller = Get.put(SplashController(
      splashRepo: Get.find(),
      gsRepo: Get.find(),
      localizationController: Get.find(),
    ));

    // Make status bar transparent during splash
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: MyColor.transparentColor,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: MyColor.transparentColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    // Auto navigate after 2 seconds OR immediately when ready
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        controller.gotoNextPage(); // This will now decide where to go
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor:
            MyColor.primaryColor, // Or your splash background color
        body: Center(
          child: Image.asset(
            MyImages.logo, // Your app logo
            height: 180,
            width: 180,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
