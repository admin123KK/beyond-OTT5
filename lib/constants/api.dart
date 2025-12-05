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
      "$baseUrl /api/live-television/{{scope}}";
  static const String deviceFeaturedEndpoint =
      "$baseUrl/api/section/featuredapi/sliders";
  static const String deviceRecentSectionEndpoint =
      "$baseUrl/api/section/recent";
  static const String deviceLatestEndpoint = "$baseUrl/api/section/latest";
  static const String deviceTrailerEndpoint = "$baseUrl/api/section/trailer";
}
