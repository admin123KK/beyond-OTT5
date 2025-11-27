import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/view/components/show_custom_snackbar.dart';

import '../../../model/auth/verification/email_verification_model.dart';
import '../../../repo/auth/login_repo.dart';

class ForgetPasswordController extends GetxController {
  final LoginRepo loginRepo;

  ForgetPasswordController({required this.loginRepo});

  // Form state
  String email = '';
  String password = '';
  String confirmPassword = '';
  String currentText = '';
  List<String> errors = [];
  bool isLoading = false;
  bool isResendLoading = false;
  bool hasError = false;
  bool remember = false;

  // Focus Nodes
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  // Password strength
  bool checkPasswordStrength = false;
  final RegExp regex =
      RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');

  // Add / Remove Errors
  void addError({required String error}) {
    if (!errors.contains(error)) {
      errors.add(error);
      update();
    }
  }

  void removeError({required String error}) {
    if (errors.contains(error)) {
      errors.remove(error);
      update();
    }
  }

  void clearErrors() {
    errors.clear();
    update();
  }

  // Submit Forget Password (Returns true if success)
  Future<bool> submitForgetPassCode() async {
    if (email.isEmpty) {
      addError(error: MyStrings.kEmailNullError);
      return false;
    }

    removeError(error: MyStrings.kEmailNullError);
    clearErrors(); // Clear previous errors

    isLoading = true;
    update();

    try {
      String value = email.trim();
      String type = value.contains('@') ? 'email' : 'username';

      String? responseEmail = await loginRepo.forgetPassword(type, value);

      if (responseEmail != null && responseEmail.isNotEmpty) {
        // Success: Navigate to verification screen
        Get.toNamed(RouteHelper.verifyPassCodeScreen, arguments: responseEmail);
        CustomSnackbar.showCustomSnackbar(
          errorList: [],
          msg: [MyStrings.resend.tr],
          isError: false,
        );
        isLoading = false;
        update();
        return true;
      } else {
        // API returned empty → treat as error
        addError(error: MyStrings.somethingWentWrong);
        CustomSnackbar.showCustomSnackbar(
          errorList: [MyStrings.requestFailed],
          msg: [],
          isError: true,
        );
        isLoading = false;
        update();
        return false;
      }
    } catch (e) {
      addError(error: MyStrings.somethingWentWrong);
      CustomSnackbar.showCustomSnackbar(
        errorList: [MyStrings.somethingWentWrong],
        msg: [],
        isError: true,
      );
      isLoading = false;
      update();
      return false;
    }
  }

  // Resend Code
  Future<void> resendForgetPassCode() async {
    isResendLoading = true;
    update();

    String value = email.trim();
    String type = 'email'; // or detect again

    await loginRepo.forgetPassword(type, value);

    isResendLoading = false;
    update();

    CustomSnackbar.showCustomSnackbar(
      errorList: [],
      msg: [MyStrings.resendCodeFail.tr],
      isError: false,
    );
  }

  // Verify Code
  Future<void> verifyForgetPasswordCode(String code) async {
    if (code.isEmpty) {
      CustomSnackbar.showCustomSnackbar(
          errorList: [MyStrings.emailVerification], msg: [], isError: true);
      return;
    }

    isLoading = true;
    update();

    EmailVerificationModel model = await loginRepo.verifyForgetPassCode(code);

    if (model.status == 'success') {
      Get.offAndToNamed(RouteHelper.resetPasswordScreen, arguments: email);
      CustomSnackbar.showCustomSnackbar(
        errorList: [],
        msg: [MyStrings.success],
        isError: false,
      );
    } else {
      CustomSnackbar.showCustomSnackbar(
        errorList: model.message?.error ?? [MyStrings.verificationFailed],
        msg: [],
        isError: true,
      );
    }

    isLoading = false;
    update();
  }

  // Reset Password
  Future<void> resetPassword() async {
    if (password.isEmpty || confirmPassword.isEmpty) {
      addError(error: MyStrings.kPassNullError);
      return;
    }

    if (password != confirmPassword) {
      addError(error: MyStrings.kMatchPassError);
      return;
    }

    if (checkPasswordStrength && !regex.hasMatch(password)) {
      addError(error: MyStrings.kInvalidPassError);
      return;
    }

    isLoading = true;
    update();

    EmailVerificationModel model =
        await loginRepo.resetPassword(email, password);

    isLoading = false;
    update();

    if (model.code == 200 || model.status == 'success') {
      Get.offAllNamed(RouteHelper.loginScreen);
      CustomSnackbar.showCustomSnackbar(
        errorList: [],
        msg: [MyStrings.changePassword],
        isError: false,
      );
    } else {
      CustomSnackbar.showCustomSnackbar(
        errorList: model.message?.error ?? [MyStrings.requestFailed],
        msg: [],
        isError: true,
      );
    }
  }

  // Clear all data
  void clearAllData() {
    email = '';
    password = '';
    confirmPassword = '';
    currentText = '';
    errors.clear();
    isLoading = false;
    update();
  }

  @override
  void onClose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.onClose();
  }
}
