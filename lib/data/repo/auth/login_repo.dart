import 'dart:convert';
import 'package:get/get.dart';
import 'package:play_lab/constants/method.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/helper/shared_pref_helper.dart';
import 'package:play_lab/core/utils/url_container.dart';
import 'package:play_lab/data/model/auth/verification/email_verification_model.dart';
import 'package:play_lab/data/model/global/response_model/response_model.dart';
import 'package:play_lab/data/services/api_service.dart';
import 'package:play_lab/view/components/show_custom_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginRepo extends GetConnect {
  final SharedPreferences sharedPreferences;
  final ApiClient apiClient;

  LoginRepo({required this.sharedPreferences, required this.apiClient});

  // Normal Email/Password Login
  Future<ResponseModel> loginUser(String email, String password) async {
    Map<String, String> map = {'username': email, 'password': password};
    String url = '${UrlContainer.baseUrl}${UrlContainer.loginEndPoint}';
    return await apiClient.request(url, Method.postMethod, map,
        passHeader: false);
  }

  // Google / Facebook Social Login
  Future<ResponseModel> socialLogin({
    required bool isGmail,
    required String token,
    required String email,
    required String name,
    required String id,
  }) async {
    Map<String, String> map = {
      'provider': isGmail ? 'google' : 'facebook',
      'access_token': token,
      'email': email,
      'id': id,
      'name': name,
    };
    String url = '${UrlContainer.baseUrl}${UrlContainer.socialLoginEndPoint}';
    return await apiClient.request(url, Method.postMethod, map,
        passHeader: false);
  }

  // Forget Password - Step 1 (Send email/phone)
  Future<String> forgetPassword(String type, String value) async {
    final map = {'type': type, 'value': value};
    String url =
        '${UrlContainer.baseUrl}${UrlContainer.forgetPasswordEndPoint}';

    final response = await apiClient.request(
      url,
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
    String url =
        '${UrlContainer.baseUrl}${UrlContainer.passwordVerifyEndPoint}';

    final response = await apiClient.request(url, Method.postMethod, map,
        isOnlyAcceptType: true);
    EmailVerificationModel model =
        EmailVerificationModel.fromJson(jsonDecode(response.responseJson));

    if (model.message?.success != null) {
      model.setCode(200);
      return model;
    } else {
      model.setCode(400);
      return model;
    }
  }

  // Reset Password (Final Step)
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

    String url = '${UrlContainer.baseUrl}${UrlContainer.resetPasswordEndPoint}';
    ResponseModel response = await apiClient
        .request(url, Method.postMethod, map, isOnlyAcceptType: true);

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

  // ─────────────────────────────────────────────────────────────
  // PUSH NOTIFICATION TOKEN HANDLING (Firebase 100% REMOVED)
  // ─────────────────────────────────────────────────────────────

  /// Save device token locally (for future push system)
  Future<void> saveDeviceToken(String token) async {
    await sharedPreferences.setString(
        SharedPreferenceHelper.fcmDeviceKey, token);
  }

  /// Send saved token to your backend
  Future<bool> sendDeviceTokenToServer() async {
    String? token =
        sharedPreferences.getString(SharedPreferenceHelper.fcmDeviceKey);
    if (token == null || token.isEmpty) return false;

    String url = '${UrlContainer.baseUrl}${UrlContainer.deviceTokenEndPoint}';
    Map<String, String> map = {'token': token};

    ResponseModel response =
        await apiClient.request(url, Method.postMethod, map, passHeader: true);
    return response.statusCode == 200;
  }

  /// Call this method when you implement push (OneSignal, Pusher, etc.)
  /// For now: does nothing → no crash, no Firebase
  Future<void> initializePushToken() async {
    // Placeholder — safe & clean
    // Later: get token from OneSignal, your server, etc.
    // Then call: saveDeviceToken(token) → sendDeviceTokenToServer()
    return;
  }
}
