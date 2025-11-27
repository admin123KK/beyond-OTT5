// login_controller.dart
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:play_lab/constants/constant_helper.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/helper/shared_pref_helper.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/data/repo/auth/login_repo.dart';
import 'package:play_lab/view/components/show_custom_snackbar.dart';

class LoginController extends GetxController {
  final LoginRepo loginRepo;

  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool remember = true;

  // Google loading state
  bool isEmailLoginLoading = false;

  // Facebook is now DISABLED (no loading state needed)
  // bool facebookLoginLoading = false; → REMOVED

  LoginController({required this.loginRepo});

  void forgetPassword() {
    Get.toNamed(RouteHelper.forgetPasswordScreen);
  }

  // Direct login → No backend → Instant Home (Perfect for demo)
  void goToHomeScreenDirectly() {
    final prefs = loginRepo.apiClient.sharedPreferences;
    prefs
      ..setBool(SharedPreferenceHelper.rememberMeKey, true)
      ..setString(SharedPreferenceHelper.accessTokenKey, "demo_token_123")
      ..setString(SharedPreferenceHelper.userNameKey, "Demo User")
      ..setString(SharedPreferenceHelper.userFullNameKey, "Demo User")
      ..setString(
          SharedPreferenceHelper.userEmailKey,
          emailController.text.isNotEmpty
              ? emailController.text
              : "demo@example.com");

    Get.offAllNamed(RouteHelper.homeScreen);
  }

  // Email/Password Login (Demo Mode)
  Future<void> loginUser() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      return;
    }

    isLoading = true;
    update();

    await Future.delayed(const Duration(seconds: 1));

    CustomSnackbar.showCustomSnackbar(
      errorList: [],
      msg: ["Login successful!"],
      isError: false,
    );

    goToHomeScreenDirectly();

    isLoading = false;
    update();
  }

  // Google Sign-In (Still Working)
  Future<void> signInWithGoogle() async {
    try {
      isEmailLoginLoading = true;
      update();

      final googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        CustomSnackbar.showCustomSnackbar(
          errorList: ["Login cancelled"],
          msg: [],
          isError: false,
        );
        return;
      }

      CustomSnackbar.showCustomSnackbar(
        errorList: [],
        msg: ["Google login successful!"],
        isError: false,
      );

      final prefs = loginRepo.apiClient.sharedPreferences;
      prefs
        ..setBool(SharedPreferenceHelper.rememberMeKey, true)
        ..setString(SharedPreferenceHelper.accessTokenKey, "google_demo_token")
        ..setString(SharedPreferenceHelper.userNameKey,
            googleUser.displayName ?? "Google User")
        ..setString(SharedPreferenceHelper.userEmailKey, googleUser.email)
        ..setString(SharedPreferenceHelper.userFullNameKey,
            googleUser.displayName ?? "Google User");

      Get.offAllNamed(RouteHelper.homeScreen);
    } catch (e) {
      PrintHelper.printHelper('Google Error: $e');
      CustomSnackbar.showCustomSnackbar(
        errorList: [MyStrings.somethingWentWrong],
        msg: [],
        isError: true,
      );
    } finally {
      isEmailLoginLoading = false;
      update();
    }
  }

  // FACEBOOK LOGIN COMPLETELY DISABLED
  // No function, no loading, no risk of crash or permission prompt
  // You can re-enable later by just uncommenting & adding back flutter_facebook_auth

  // Optional: Show message if someone tries to use it from UI
  void signInWithFacebook() {
    CustomSnackbar.showCustomSnackbar(
      errorList: [],
      msg: ["Facebook login is temporarily disabled"],
      isError: false,
    );
  }

  void changeRememberMe() {
    remember = !remember;
    update();
  }

  void clearAllSharedData() {
    loginRepo.apiClient.sharedPreferences
      ..setBool(SharedPreferenceHelper.rememberMeKey, false)
      ..remove(SharedPreferenceHelper.accessTokenKey)
      ..remove(SharedPreferenceHelper.userNameKey)
      ..remove(SharedPreferenceHelper.userEmailKey);

    GoogleSignIn().signOut();
    // FacebookAuth.instance.logOut(); → Removed (no need)
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }
}
