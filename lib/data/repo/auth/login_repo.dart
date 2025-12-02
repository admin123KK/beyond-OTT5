// lib/data/repo/auth/login_repo.dart

import 'dart:convert';

import 'package:get/get.dart';
import 'package:play_lab/constants/api.dart';
import 'package:play_lab/constants/method.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/helper/shared_pref_helper.dart';
import 'package:play_lab/data/model/auth/verification/email_verification_model.dart';
import 'package:play_lab/data/model/global/response_model/response_model.dart';
import 'package:play_lab/data/services/api_service.dart';
import 'package:play_lab/view/components/show_custom_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginRepo extends GetConnect {
  final SharedPreferences sharedPreferences;
  final ApiClient apiClient;

  LoginRepo({required this.sharedPreferences, required this.apiClient});

  // CLEAN & FINAL LOGIN — NO CAPTCHA, WITH application/json HEADER
  Future<ResponseModel> loginUser(String email, String password) async {
    final Map<String, String> body = {
      'username': email,
      'password': password,
      'is_web': 'false',
      // g-recaptcha-response COMPLETELY REMOVED — mobile login works without it
    };

    // This sends: Content-Type: application/json automatically
    return await apiClient.request(
      ApiConstants.loginEndpoint,
      Method.postMethod,
      body,
      passHeader:
          true, // This ensures headers including application/json are sent
    );
  }

  // Social Login
  Future<ResponseModel> socialLogin({
    required bool isGmail,
    required String token,
    required String email,
    required String name,
    required String id,
  }) async {
    final Map<String, String> body = {
      'provider': isGmail ? 'google' : 'facebook',
      'access_token': token,
      'email': email,
      'id': id,
      'name': name,
    };

    return await apiClient.request(
      ApiConstants.socialLoginEndpoint,
      Method.postMethod,
      body,
      passHeader: true,
    );
  }

  // Forget Password
  Future<String> forgetPassword(String type, String value) async {
    final map = {'type': type, 'value': value};

    final response = await apiClient.request(
      ApiConstants.forgotPasswordEndpoint,
      Method.postMethod,
      map,
      isOnlyAcceptType: true,
      passHeader: true,
    );

    EmailVerificationModel model =
        EmailVerificationModel.fromJson(jsonDecode(response.responseJson));

    if (model.message?.success != null) {
      sharedPreferences.setString(
          SharedPreferenceHelper.userEmailKey, model.data?.email ?? '');
      sharedPreferences.setString(
          SharedPreferenceHelper.resetPassTokenKey, model.data?.token ?? '');

      CustomSnackbar.showCustomSnackbar(
        errorList: [],
        msg: [
          '${MyStrings.passwordResetEmailSendTo.tr} ${model.data?.email ?? MyStrings.yourEmail.tr}'
        ],
        isError: false,
      );
      return model.data?.email ?? '';
    } else {
      CustomSnackbar.showCustomSnackbar(
        errorList: model.message?.error ?? [MyStrings.somethingWentWrong],
        msg: [],
        isError: true,
      );
      return '';
    }
  }

  // Verify Reset Code
  Future<EmailVerificationModel> verifyForgetPassCode(String code) async {
    String? email =
        sharedPreferences.getString(SharedPreferenceHelper.userEmailKey) ?? '';
    Map<String, String> map = {'code': code, 'email': email};

    final response = await apiClient.request(
      ApiConstants.verifyCodeEndpoint,
      Method.postMethod,
      map,
      isOnlyAcceptType: true,
      passHeader: true,
    );

    EmailVerificationModel model =
        EmailVerificationModel.fromJson(jsonDecode(response.responseJson));
    model.setCode(model.message?.success != null ? 200 : 400);
    return model;
  }

  // Reset Password
  Future<EmailVerificationModel> resetPassword(
      String email, String password) async {
    String token =
        sharedPreferences.getString(SharedPreferenceHelper.resetPassTokenKey) ??
            '';

    Map<String, String> map = {
      'token': token,
      'email': email,
      'password': password,
      'password_confirmation': password,
    };

    ResponseModel response = await apiClient.request(
      ApiConstants.resetPasswordEndpoint,
      Method.postMethod,
      map,
      isOnlyAcceptType: true,
      passHeader: true,
    );

    EmailVerificationModel model =
        EmailVerificationModel.fromJson(jsonDecode(response.responseJson));

    if (model.message?.success != null) {
      CustomSnackbar.showCustomSnackbar(
          errorList: [], msg: model.message?.success ?? [], isError: false);
      model.setCode(200);
    } else {
      CustomSnackbar.showCustomSnackbar(
          errorList: model.message?.error ?? [], msg: [], isError: true);
      model.setCode(400);
    }
    return model;
  }

  // Device Token
  Future<bool> sendDeviceTokenToServer() async {
    String? token =
        sharedPreferences.getString(SharedPreferenceHelper.fcmDeviceKey);
    if (token == null || token.isEmpty) return false;

    Map<String, String> map = {'token': token};

    ResponseModel response = await apiClient.request(
      ApiConstants.deviceTokenEndpoint,
      Method.postMethod,
      map,
      passHeader: true,
    );
    return response.statusCode == 200;
  }

  Future<void> saveDeviceToken(String token) async {
    await sharedPreferences.setString(
        SharedPreferenceHelper.fcmDeviceKey, token);
  }

  Future<void> initializePushToken() async => null;
}
