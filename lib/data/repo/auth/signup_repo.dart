import 'dart:convert';

import 'package:play_lab/constants/method.dart';
import 'package:play_lab/core/helper/shared_pref_helper.dart';
import 'package:play_lab/core/utils/url_container.dart';
import 'package:play_lab/data/model/auth/registration_response_model.dart';
import 'package:play_lab/data/model/auth/sign_up_model/sign_up_model.dart';
import 'package:play_lab/data/model/global/response_model/response_model.dart';
import 'package:play_lab/data/services/api_service.dart';

class SignupRepo {
  final ApiClient apiClient;

  SignupRepo({required this.apiClient});

  // Normal Email/Password Registration
  Future<RegistrationResponseModel> registerUser(SignUpModel model) async {
    final map = modelToMap(model);
    String url = '${UrlContainer.baseUrl}${UrlContainer.registrationEndPoint}';

    final res = await apiClient.request(
      url,
      Method.postMethod,
      map,
      passHeader: true,
      isOnlyAcceptType: true,
    );

    final json = jsonDecode(res.responseJson);
    return RegistrationResponseModel.fromJson(json);
  }

  // Social Login (Google / Facebook) - Still works without Firebase!
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

  // Convert SignUpModel → Map for API
  Map<String, dynamic> modelToMap(SignUpModel model) {
    return {
      'firstname': model.firstName ?? '',
      'lastname': model.lastName ?? '',
      'email': model.email ?? '',
      'agree': model.agree.toString() == 'true' ? 'true' : 'false',
      'password': model.password ?? '',
      'password_confirmation': model.password ?? '',
    };
  }

  // ─────────────────────────────────────────────────────────────
  // PUSH NOTIFICATION TOKEN HANDLING – 100% FIREBASE REMOVED
  // ─────────────────────────────────────────────────────────────

  /// Save device token locally (for future push system)
  Future<void> saveDeviceToken(String token) async {
    await apiClient.sharedPreferences
        .setString(SharedPreferenceHelper.fcmDeviceKey, token);
  }

  /// Send device token to your backend
  Future<bool> sendDeviceTokenToServer() async {
    String? token = apiClient.sharedPreferences
        .getString(SharedPreferenceHelper.fcmDeviceKey);
    if (token == null || token.isEmpty) return false;

    String url = '${UrlContainer.baseUrl}${UrlContainer.deviceTokenEndPoint}';
    Map<String, String> map = {'token': token};

    ResponseModel response =
        await apiClient.request(url, Method.postMethod, map, passHeader: true);
    return response.statusCode == 200;
  }

  /// Call this after successful signup/login when you implement push
  /// (OneSignal, Pusher, your own FCM via backend, etc.)
  Future<void> initializePushNotificationToken() async {
    // Placeholder – safe & clean
    // Later: get token from your new provider → save + send
    return;
  }
}
