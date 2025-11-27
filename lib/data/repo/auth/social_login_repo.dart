import 'package:play_lab/constants/method.dart';
import 'package:play_lab/core/helper/shared_pref_helper.dart';
import 'package:play_lab/core/utils/url_container.dart';
import 'package:play_lab/data/model/global/response_model/response_model.dart';
import 'package:play_lab/data/services/api_service.dart';

class SocialLoginRepo {
  final ApiClient apiClient;

  SocialLoginRepo({required this.apiClient});

  /// Social Login (Google / Facebook / LinkedIn) – works perfectly without Firebase
  Future<ResponseModel> socialLoginUser({
    required String accessToken,
    required String provider, // "google" | "facebook" | "linkedin"
  }) async {
    final Map<String, String> map = {
      'token': accessToken,
      'provider': provider,
    };

    String url = '${UrlContainer.baseUrl}${UrlContainer.socialLoginEndPoint}';
    return await apiClient.request(url, Method.postMethod, map,
        passHeader: false);
  }

  // ─────────────────────────────────────────────────────────────
  // PUSH NOTIFICATION TOKEN HANDLING – 100% FIREBASE REMOVED
  // ─────────────────────────────────────────────────────────────

  /// Save device token locally (for future push system – OneSignal, your own FCM, etc.)
  Future<void> saveDeviceToken(String token) async {
    await apiClient.sharedPreferences
        .setString(SharedPreferenceHelper.fcmDeviceKey, token);
  }

  /// Send saved token to your backend
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

  /// Call this after successful social login when you add push notifications later
  Future<void> initializePushNotificationToken() async {
    // Placeholder – safe, clean, no crash
    // Later: get token from OneSignal / your backend → save + send
    return;
  }
}
