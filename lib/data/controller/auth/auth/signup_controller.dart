// sign_up_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/helper/shared_pref_helper.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/data/model/auth/error_model.dart';
import 'package:play_lab/data/model/auth/sign_up_model/sign_up_model.dart';
import 'package:play_lab/data/repo/auth/signup_repo.dart';
import 'package:play_lab/view/components/show_custom_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpController extends GetxController {
  final SignupRepo signUpRepo;
  final SharedPreferences sharedPreferences;

  SignUpController({required this.signUpRepo, required this.sharedPreferences});

  bool isLoading = false;
  bool agreeTC = false;
  bool checkPasswordStrength = false;

  // Focus Nodes
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  final FocusNode firstNameFocusNode = FocusNode();
  final FocusNode lastNameFocusNode = FocusNode();

  // Text Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cPasswordController = TextEditingController();
  final TextEditingController fNameController = TextEditingController();
  final TextEditingController lNameController = TextEditingController();

  final List<String?> errors = [];

  final RegExp regex =
      RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');

  List<ErrorModel> passwordValidationRules = [
    ErrorModel(text: MyStrings.hasUpperLetter.tr, hasError: true),
    ErrorModel(text: MyStrings.hasLowerLetter.tr, hasError: true),
    ErrorModel(text: MyStrings.hasDigit.tr, hasError: true),
    ErrorModel(text: MyStrings.hasSpecialChar.tr, hasError: true),
    ErrorModel(text: MyStrings.minSixChar.tr, hasError: true),
  ];

  @override
  void onInit() {
    super.onInit();
    checkPasswordStrength =
        signUpRepo.apiClient.getGSData().data?.generalSetting?.securePassword ==
            '1';
  }

  // Direct go to Home (demo mode)
  void goToHomeDirectly() {
    final prefs = sharedPreferences;
    prefs
      ..setBool(SharedPreferenceHelper.rememberMeKey, true)
      ..setString(SharedPreferenceHelper.accessTokenKey, "demo_signup_token")
      ..setString(SharedPreferenceHelper.userNameKey,
          "${fNameController.text} ${lNameController.text}".trim())
      ..setString(SharedPreferenceHelper.userEmailKey, emailController.text)
      ..setString(SharedPreferenceHelper.userFullNameKey,
          "${fNameController.text} ${lNameController.text}".trim());

    Get.offAllNamed(RouteHelper.homeScreen);
  }

  // Email/Password Signup → No backend → Go Home
  Future<void> signUpUser() async {
    if (!agreeTC) {
      return;
    }
    if (!validateFields()) return;

    isLoading = true;
    update();

    await Future.delayed(const Duration(seconds: 1));

    CustomSnackbar.showCustomSnackbar(
      errorList: [],
      msg: ["Account created successfully!"],
      isError: false,
    );

    goToHomeDirectly();

    isLoading = false;
    update();
  }

  bool validateFields() {
    errors.clear();
    if (fNameController.text.trim().isEmpty)
      addError(error: MyStrings.kFirstNameNullError);
    if (lNameController.text.trim().isEmpty)
      addError(error: MyStrings.kLastNameNullError);
    if (emailController.text.trim().isEmpty)
      addError(error: MyStrings.kEmailNullError);
    if (passwordController.text.isEmpty)
      addError(error: MyStrings.kInvalidPassError);
    if (cPasswordController.text != passwordController.text)
      addError(error: MyStrings.kMatchPassError);
    if (checkPasswordStrength && !regex.hasMatch(passwordController.text)) {
      addError(error: MyStrings.invalidPassMsg.tr);
    }
    update();
    return errors.isEmpty;
  }

  void addError({String? error}) {
    if (error != null && !errors.contains(error)) {
      errors.add(error);
      update();
    }
  }

  void updateValidationList(String value) {
    passwordValidationRules[0].hasError = !value.contains(RegExp(r'[A-Z]'));
    passwordValidationRules[1].hasError = !value.contains(RegExp(r'[a-z]'));
    passwordValidationRules[2].hasError = !value.contains(RegExp(r'[0-9]'));
    passwordValidationRules[3].hasError =
        !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    passwordValidationRules[4].hasError = value.length < 6;
    update();
  }

  void updateAgreeTC() {
    agreeTC = !agreeTC;
    update();
  }

  SignUpModel getUserData() {
    return SignUpModel(
      firstName: fNameController.text.trim(),
      lastName: lNameController.text.trim(),
      email: emailController.text.trim(),
      agree: agreeTC,
      password: passwordController.text,
    );
  }

  // Google Sign-In → Still Working (Demo Mode)
  bool isEmailLoginLoading = false;

  Future<void> signInWithGoogle() async {
    try {
      isEmailLoginLoading = true;
      update();

      final googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        isEmailLoginLoading = false;
        update();
        return;
      }

      CustomSnackbar.showCustomSnackbar(
        errorList: [],
        msg: ["Google signup successful!"],
        isError: false,
      );

      final prefs = sharedPreferences;
      prefs
        ..setBool(SharedPreferenceHelper.rememberMeKey, true)
        ..setString(SharedPreferenceHelper.accessTokenKey, "google_demo_token")
        ..setString(SharedPreferenceHelper.userNameKey,
            googleUser.displayName ?? "Google User")
        ..setString(SharedPreferenceHelper.userEmailKey, googleUser.email);

      Get.offAllNamed(RouteHelper.homeScreen);
    } catch (e) {
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

  // FACEBOOK SIGN-IN COMPLETELY DISABLED
  // No import, no loading state, no crash risk
  Future<void> signInWithFacebook() async {
    CustomSnackbar.showCustomSnackbar(
      errorList: [],
      msg: ["Facebook signup is temporarily disabled"],
      isError: false,
    );
  }

  void clearAllData() {
    agreeTC = false;
    errors.clear();
    fNameController.clear();
    lNameController.clear();
    emailController.clear();
    passwordController.clear();
    cPasswordController.clear();
    update();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    cPasswordController.dispose();
    fNameController.dispose();
    lNameController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    super.onClose();
  }
}
