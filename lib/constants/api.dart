class ApiConstants {
  ApiConstants._();

  static const String baseUrl = "https://ott.beyondtechnepal.com";
  static const String registerEndpoint = "$baseUrl/api/register";
  static const String loginEndpoint = "$baseUrl/api/login";
  static const String socialLoginEndpoint = "$baseUrl/api/password/email";
  static const String forgotPasswordEndpoint = "$baseUrl/api/password/email";
  static const String verifyCodeEndpoint = "$baseUrl/api/password/verify-code";
  static const String resetPasswordEndpoint = "$baseUrl/api/password/reset";
  static const String deviceTokenEndpoint = "$baseUrl/api/device-token";
  static const String deviceDashboardEndpoint = "$baseUrl/api/dashboard";
  static const String deviceGetLogoEndpoint = "$baseUrl/api/logo";
  static const String deviceMoviesEndpoint = "$baseUrl/api/movies";
  static const String deviceSlidersEndpoint = "$baseUrl/api/sliders";
  static const String deviceLiveTVEndpoint =
      "$baseUrl /api/live-television/atll";
  static const String deviceFeaturedEndpoint =
      "$baseUrl/api/section/featuredapi/sliders";
  static const String deviceRecentSectionEndpoint =
      "$baseUrl/api/section/recent";
  static const String deviceLatestEndpoint = "$baseUrl/api/section/latest";
  static const String deviceTrailerEndpoint = "$baseUrl/api/section/trailer";
  static const String logoutEndpoint = "$baseUrl/api/logout";

  static const String getInfoEndpoint = "$baseUrl/api/user-info";
  static const String updateProfileEndpoint = "$baseUrl/api/profile-setting";
  static const String submitInfoEndpoint = "$baseUrl/api/user-data-submit";

  static const String verifyStatusEndpoint = "$baseUrl/api/authorization";
  static const String sendEmailEndpoint = "$baseUrl/api/password/email";
  static const String verifyEmailEndpoint = "$baseUrl/api/verify-email";

  static const String policiesEndpoint = "$baseUrl/api/policies";
}
