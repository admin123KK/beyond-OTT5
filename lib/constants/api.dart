// lib/constants/api_constants.dart
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = "https://ott.beyondtechnepal.com";
  static const String registerEndpoint = "$baseUrl/api/register";
  static const String loginEndpoint = "$baseUrl/api/login";
  static const String socialLoginEndpoint = "$baseUrl/api/social-login";
  static const String forgotPasswordEndpoint = "$baseUrl/api/password/email";
  static const String verifyCodeEndpoint = "$baseUrl/api/password/verify";
  static const String resetPasswordEndpoint = "$baseUrl/api/password/reset";
  static const String deviceTokenEndpoint = "$baseUrl/api/device-token";
}
