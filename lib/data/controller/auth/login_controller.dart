// lib/data/controller/auth/login_controller.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/helper/shared_pref_helper.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/data/model/global/response_model/response_model.dart';
import 'package:play_lab/data/repo/auth/login_repo.dart';
import 'package:play_lab/view/components/show_custom_snackbar.dart';

class LoginController extends GetxController {
  final LoginRepo loginRepo;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool remember = true;

  LoginController({required this.loginRepo});

  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      CustomSnackbar.showCustomSnackbar(
        errorList: [MyStrings.enterUserNameOrEmail],
        msg: [],
        isError: true,
      );
      return;
    }

    isLoading = true;
    update();

    try {
      final ResponseModel response = await loginRepo.loginUser(email, password);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.responseJson); // CORRECT FIELD

        final String remark = json['remark']?.toString() ?? '';
        final String status = json['status']?.toString() ?? '';

        if (status == 'success' || remark == 'success') {
          // SUCCESS LOGIN
          final token = json['data']['access_token']?.toString() ?? '';
          final user = json['data']['user'];

          final prefs = loginRepo.apiClient.sharedPreferences;
          await prefs
            ..setBool(SharedPreferenceHelper.rememberMeKey, remember)
            ..setString(SharedPreferenceHelper.accessTokenKey, token)
            ..setString(SharedPreferenceHelper.accessTokenType, "Bearer")
            ..setString(
                SharedPreferenceHelper.userEmailKey, user['email'] ?? email)
            ..setString(SharedPreferenceHelper.userFullNameKey,
                "${user['firstname'] ?? ''} ${user['lastname'] ?? ''}".trim())
            ..setString(
                SharedPreferenceHelper.userIDKey, user['id'].toString());

          final successMsg =
              json['message']?['success']?[0] ?? MyStrings.success.tr;
          CustomSnackbar.showCustomSnackbar(
              errorList: [], msg: [successMsg], isError: false);

          Get.offAllNamed(RouteHelper.homeScreen);
        } else {
          // FAILED LOGIN
          String errorMsg = MyStrings.kInvalidEmailError.tr;

          if (json['message']?['error'] is List &&
              json['message']['error'].isNotEmpty) {
            errorMsg = json['message']['error'][0];
          } else if (json['message']?['error'] is String) {
            errorMsg = json['message']['error'];
          } else if (remark == 'unauthorized_user') {
            errorMsg = "Unauthorized user";
          }

          CustomSnackbar.showCustomSnackbar(
              errorList: [errorMsg], msg: [], isError: true);
        }
      } else {
        CustomSnackbar.showCustomSnackbar(
          errorList: [response.message],
          msg: [],
          isError: true,
        );
      }
    } catch (e) {
      CustomSnackbar.showCustomSnackbar(
        errorList: [MyStrings.somethingWentWrong],
        msg: [],
        isError: true,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  void changeRememberMe() {
    remember = !remember;
    update();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
