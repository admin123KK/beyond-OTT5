import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/helper/shared_pref_helper.dart';
import 'package:play_lab/data/model/auth/registration_response_model.dart';
import 'package:play_lab/data/model/authorization/authorization_response_model.dart';
import 'package:play_lab/view/components/show_custom_snackbar.dart';
import '../../../constants/method.dart';
import '../../../core/utils/url_container.dart';
import '../../model/account/profile_response_model.dart';
import '../../model/account/user_post_model/user_post_model.dart';
import '../../model/global/response_model/response_model.dart';
import '../../services/api_service.dart';

class ProfileRepo {
  ApiClient apiClient;

  ProfileRepo({required this.apiClient});

  // Update Profile (with or without image)
  Future<bool> updateProfile(UserPostModel m, String callFrom) async {
    apiClient.initToken();
    String url =
        '${UrlContainer.baseUrl}${callFrom == 'profile' ? UrlContainer.updateProfileEndPoint : UrlContainer.profileCompleteEndPoint}';
    var request = http.MultipartRequest('POST', Uri.parse(url));

    Map<String, String> map = {
      'firstname': m.firstName ?? '',
      'lastname': m.lastName ?? '',
      'address': m.address ?? '',
      'zip': m.zip ?? '',
      'state': m.state ?? "",
      'city': m.city ?? '',
    };

    request.headers
        .addAll(<String, String>{'Authorization': 'Bearer ${apiClient.token}'});

    if (m.image != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        m.image!.path,
        filename: m.image!.path.split('/').last,
      ));
    }

    request.fields.addAll(map);

    try {
      http.StreamedResponse response = await request.send();
      String jsonResponse = await response.stream.bytesToString();
      AuthorizationResponseModel model =
          AuthorizationResponseModel.fromJson(jsonDecode(jsonResponse));

      if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        CustomSnackbar.showCustomSnackbar(
            errorList: [],
            msg: model.message?.success ?? [MyStrings.success],
            isError: false);
        return true;
      } else {
        CustomSnackbar.showCustomSnackbar(
            errorList: model.message?.error ?? [MyStrings.requestFailed.tr],
            msg: [],
            isError: true);
        return false;
      }
    } catch (e) {
      CustomSnackbar.showCustomSnackbar(
          errorList: [MyStrings.requestFailed.tr], msg: [], isError: true);
      return false;
    }
  }

  // Complete Profile (after signup)
  Future<RegistrationResponseModel> completeProfile(UserPostModel m) async {
    apiClient.initToken();
    String url =
        '${UrlContainer.baseUrl}${UrlContainer.profileCompleteEndPoint}';
    final map = modelToMap(m);

    final res =
        await apiClient.request(url, Method.postMethod, map, passHeader: true);
    final json = jsonDecode(res.responseJson);
    return RegistrationResponseModel.fromJson(json);
  }

  // Get country list
  Future<dynamic> getCountryList() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.countryEndPoint}';
    return await apiClient.request(url, Method.getMethod, null);
  }

  // Load user profile info
  Future<ProfileResponseModel> loadProfileInfo() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.getProfileEndPoint}';

    ResponseModel responseModel =
        await apiClient.request(url, Method.getMethod, null, passHeader: true);

    if (responseModel.statusCode == 200) {
      ProfileResponseModel model =
          ProfileResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      if (model.status == 'success') {
        String userImage = model.data?.user?.image ?? '';
        await apiClient.sharedPreferences
            .setString(SharedPreferenceHelper.userImageKey, userImage);
        return model;
      }
    }
    return ProfileResponseModel();
  }

  // ────────────────────────────────────────────────────────────────
  // PUSH NOTIFICATION TOKEN HANDLING (Firebase Completely Removed)
  // ────────────────────────────────────────────────────────────────

  // Save device token locally (for future push system)
  Future<void> saveDeviceToken(String token) async {
    await apiClient.sharedPreferences
        .setString(SharedPreferenceHelper.fcmDeviceKey, token);
  }

  // Send device token to your backend (call this when you have a token)
  Future<bool> sendDeviceTokenToServer(String deviceToken) async {
    if (deviceToken.isEmpty) return false;

    String url = '${UrlContainer.baseUrl}${UrlContainer.deviceTokenEndPoint}';
    Map<String, String> map = {'token': deviceToken};

    ResponseModel response =
        await apiClient.request(url, Method.postMethod, map, passHeader: true);

    return response.statusCode == 200;
  }

  // Placeholder: Call this when you implement push later (OneSignal, your own, etc.)
  Future<bool> initializePushNotificationToken() async {
    // Example placeholder — do nothing now
    // Later: get token from OneSignal, your backend, etc.
    String savedToken = apiClient.sharedPreferences
            .getString(SharedPreferenceHelper.fcmDeviceKey) ??
        '';

    if (savedToken.isNotEmpty) {
      await sendDeviceTokenToServer(savedToken);
    }
    return true;
  }

  // Helper map
  Map<String, dynamic> modelToMap(UserPostModel model) {
    return {
      'firstname': model.firstName ?? '',
      'lastname': model.lastName ?? '',
      'address': model.address ?? '',
      'zip': model.zip ?? '',
      'state': model.state ?? "",
      'city': model.city ?? '',
      'mobile': model.mobile ?? '',
      'email': model.email ?? '',
      'username': model.username ?? '',
      'country_code': model.countryCode ?? '',
      'country': model.country ?? '',
      "mobile_code": model.mobileCode ?? '',
    };
  }
}
