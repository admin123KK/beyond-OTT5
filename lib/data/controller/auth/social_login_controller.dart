// social_login_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:play_lab/constants/constant_helper.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/helper/shared_pref_helper.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/data/repo/auth/social_login_repo.dart';
import 'package:play_lab/view/components/show_custom_snackbar.dart';
import 'package:play_lab/view/package/signin_with_linkdin/signin_with_linkedin.dart';

class SocialLoginController extends GetxController {
  final SocialLoginRepo repo;

  SocialLoginController({required this.repo});

  final GoogleSignIn googleSignIn = GoogleSignIn();

  bool isGoogleSignInLoading = false;
  // bool facebookLoginLoading = false;  → REMOVED
  bool isLinkedinLoading = false;

  // Google Sign-In → Still Working (Demo Mode)
  Future<void> signInWithGoogle() async {
    try {
      isGoogleSignInLoading = true;
      update();

      await googleSignIn.signOut();
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        CustomSnackbar.showCustomSnackbar(
          errorList: ["Login cancelled"],
          msg: [],
          isError: false,
        );
        isGoogleSignInLoading = false;
        update();
        return;
      }

      CustomSnackbar.showCustomSnackbar(
        errorList: [],
        msg: ["Google login successful!"],
        isError: false,
      );

      final prefs = repo.apiClient.sharedPreferences;
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
      isGoogleSignInLoading = false;
      update();
    }
  }

  // FACEBOOK LOGIN COMPLETELY DISABLED
  // No function, no loading, no crash risk
  Future<void> signInWithFacebook() async {
    CustomSnackbar.showCustomSnackbar(
      errorList: [],
      msg: ["Facebook login is temporarily disabled"],
      isError: false,
    );
  }

  // LinkedIn Sign-In → Still Working
  Future<void> signInWithLinkedin(BuildContext context) async {
    try {
      isLinkedinLoading = true;
      update();

      final credentials = repo.apiClient.getSocialCredentialsConfigData();
      final redirectUrl =
          "${repo.apiClient.getSocialCredentialsRedirectUrl()}/linkedin";

      await SignInWithLinkedIn.signIn(
        context,
        config: LinkedInConfig(
          clientId: credentials.linkedin?.clientId ?? '',
          clientSecret: credentials.linkedin?.clientSecret ?? '',
          scope: ['openid', 'profile', 'email'],
          redirectUrl: redirectUrl,
        ),
        onGetUserProfile: (token, user) async {
          CustomSnackbar.showCustomSnackbar(
            errorList: [],
            msg: ["LinkedIn login successful!"],
            isError: false,
          );

          final prefs = repo.apiClient.sharedPreferences;
          prefs
            ..setBool(SharedPreferenceHelper.rememberMeKey, true)
            ..setString(
                SharedPreferenceHelper.accessTokenKey, "linkedin_demo_token")
            ..setString(SharedPreferenceHelper.userNameKey,
                user.name ?? "LinkedIn User")
            ..setString(SharedPreferenceHelper.userEmailKey,
                user.email ?? "linkedin@example.com");

          Get.offAllNamed(RouteHelper.homeScreen);
        },
        onSignInError: (error) {
          CustomSnackbar.showCustomSnackbar(
            errorList: [error.description ?? "LinkedIn login failed"],
            msg: [],
            isError: true,
          );
        },
      );
    } catch (e) {
      PrintHelper.printHelper('LinkedIn Error: $e');
      CustomSnackbar.showCustomSnackbar(
        errorList: [MyStrings.somethingWentWrong],
        msg: [],
        isError: true,
      );
    } finally {
      isLinkedinLoading = false;
      update();
    }
  }

  // Dummy method (no backend call)
  Future<void> socialLoginUser({
    required String accessToken,
    required String provider,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Check if social login is enabled (Facebook now returns false)
  bool checkSocialAuthActiveOrNot({String provider = 'all'}) {
    final config = repo.apiClient.getSocialCredentialsConfigData();

    if (provider == 'google') return config.google?.status == '1';
    if (provider == 'facebook') return false; // ← Always disabled
    if (provider == 'linkedin') return config.linkedin?.status == '1';

    return config.google?.status == '1' || config.linkedin?.status == '1';
  }

  @override
  void onClose() {
    googleSignIn.disconnect();
    super.onClose();
  }
}
