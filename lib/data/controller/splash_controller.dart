import 'dart:convert';
import 'package:get/get.dart';
import 'package:play_lab/core/helper/shared_pref_helper.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/data/repo/auth/general_setting_repo.dart';
import 'package:play_lab/data/repo/splash/splash_repo.dart';
import 'package:play_lab/view/components/show_custom_snackbar.dart';

import '../../constants/my_strings.dart';
import '../model/global/response_model/response_model.dart';
import 'localization/localization_controller.dart';

class SplashController extends GetxController implements GetxService {
  SplashRepo splashRepo;
  GeneralSettingRepo gsRepo;
  LocalizationController localizationController;

  bool isLoading = true;

  SplashController({
    required this.splashRepo,
    required this.gsRepo,
    required this.localizationController,
  });

  Future<void> gotoNextPage() async {
    // 1. Load general settings (app config, base URL, etc.)
    await gsRepo.getGeneralSetting();
    isLoading = false;
    update();

    // 2. Initialize default language if not set
    await initSharedData();
    localizationController.loadCurrentLanguage();

    // 3. Check if user has seen onboarding before
    bool hasSeenOnboarding = splashRepo.apiClient.sharedPreferences
            .getBool(SharedPreferenceHelper.seenOnboardingKey) ??
        false;

    // 4. First time user → Show Onboarding
    if (!hasSeenOnboarding) {
      ResponseModel response = await splashRepo.getOnboardingData();
      if (response.statusCode == 200) {
        Get.offAndToNamed(RouteHelper.onboardScreen, arguments: response);
      } else {
        // Even if API fails, don't block user — go to onboarding with local data
        Get.offAndToNamed(RouteHelper.onboardScreen);
      }
      return;
    }

    // 5. Returning user → Go directly to Login (or Home when auth is ready)
    // For now: go to LoginScreen (safe & standard)
    Get.offAndToNamed(RouteHelper.loginScreen);

    // Later, when you have real auth:
    // String? token = splashRepo.apiClient.sharedPreferences.getString(SharedPreferenceHelper.accessTokenKey);
    // Get.offAndToNamed(token != null && token.isNotEmpty ? RouteHelper.bottomNavBar : RouteHelper.loginScreen);
  }

  // Save that user has seen onboarding (call this from Onboarding Screen when "Get Started" is pressed)
  void completeOnboarding() {
    splashRepo.apiClient.sharedPreferences
        .setBool(SharedPreferenceHelper.seenOnboardingKey, true);
  }

  Future<bool> initSharedData() async {
    final pref = gsRepo.apiClient.sharedPreferences;

    if (!pref.containsKey(SharedPreferenceHelper.countryCode)) {
      pref.setString(SharedPreferenceHelper.countryCode,
          MyStrings.myLanguages[0].countryCode);
    }
    if (!pref.containsKey(SharedPreferenceHelper.langCode)) {
      pref.setString(SharedPreferenceHelper.langCode,
          MyStrings.myLanguages[0].languageCode);
    }
    if (!pref.containsKey(SharedPreferenceHelper.seenOnboardingKey)) {
      pref.setBool(SharedPreferenceHelper.seenOnboardingKey, false);
    }

    return true;
  }

  // Optional: Keep language loading if your backend supports dynamic languages
  // Or remove this method entirely if you use only local JSON
  Future<void> loadLanguage() async {
    localizationController.loadCurrentLanguage();
    // Add dynamic language loading here later if needed
  }
}
