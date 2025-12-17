import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/api.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/my_images.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/core/utils/util.dart';
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';
import 'package:play_lab/view/components/bg_widget/bg_image_widget.dart';
import 'package:play_lab/view/components/buttons/rounded_button.dart';
import 'package:play_lab/view/components/buttons/rounded_loading_button.dart';
import 'package:play_lab/view/components/otp_field_widget/otp_field_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailVerifyAccount extends StatefulWidget {
  const EmailVerifyAccount({super.key});

  @override
  State<EmailVerifyAccount> createState() => _EmailVerifyAccountState();
}

class _EmailVerifyAccountState extends State<EmailVerifyAccount> {
  String _otpCode = '';
  bool _isLoading = false;
  bool _isResendLoading = false;
  String? _errorMessage;
  String? _authToken; // To store Bearer token

  @override
  void initState() {
    super.initState();
    MyUtil.changeTheme();
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    _loadAuthToken();
  }

  // Load Bearer token from SharedPreferences
  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _authToken = prefs.getString('auth_token') ??
          prefs.getString('token') ??
          prefs.getString('access_token');
      // Try common key names used in apps
    });

    if (_authToken == null || _authToken!.isEmpty) {
      Get.snackbar(
          "Error", "Authentication token not found. Please login again.");
    }
  }

  // AUTO SUBMIT WHEN 6 DIGITS ARE ENTERED
  void _checkAndSubmit() {
    if (_otpCode.length == 6) {
      _verifyCode();
    }
  }

  // Verify the OTP code with Bearer Token
  Future<void> _verifyCode() async {
    if (_otpCode.length != 6) {
      setState(() => _errorMessage = "Please enter 6-digit code");
      return;
    }

    if (_authToken == null || _authToken!.isEmpty) {
      setState(() => _errorMessage = "Authentication failed. Token missing.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.verifyEmailCodeEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_authToken', // ← FIXED: Bearer Token Added
        },
        body: jsonEncode({
          "code": _otpCode,
        }),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('verified_otp_code', _otpCode);

        Get.snackbar(
          "Verified!",
          "Code verified successfully",
          backgroundColor: MyColor.primaryColor,
          colorText: Colors.white,
        );

        Get.offAllNamed(RouteHelper.homeScreen);
      } else {
        final error = jsonResponse['message']?['error']?[0] ??
            jsonResponse['message'] ??
            "Invalid or expired code";
        setState(() => _errorMessage = error);
      }
    } catch (e) {
      setState(() => _errorMessage = "Network error. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Resend Code with Bearer Token (if required by your backend)
  Future<void> _resendCode() async {
    if (_authToken == null || _authToken!.isEmpty) {
      Get.snackbar("Error", "Cannot resend: Authentication token missing.");
      return;
    }

    setState(() => _isResendLoading = true);

    try {
      final response = await http.post(
        Uri.parse(ApiConstants
            .forgotPasswordEndpoint), // or resend verification endpoint
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_authToken', // ← Bearer Token for Resend
        },
        body: jsonEncode({
          "type": "email",
          // Some backends allow resend without email if token identifies user
        }),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
        Get.snackbar(
          "Sent!",
          "New verification code has been sent",
          backgroundColor: MyColor.primaryColor,
          colorText: Colors.white,
        );
      } else {
        final msg = jsonResponse['message'] ?? "Failed to resend code";
        Get.snackbar("Failed", msg);
      }
    } catch (e) {
      Get.snackbar("Error", "No internet connection");
    } finally {
      if (mounted) setState(() => _isResendLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const MyBgWidget(image: MyImages.onboardingBG),
        PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: const CustomAppBar(
              fromAuth: true,
              isShowBackBtn: true,
              title: MyStrings.verifyCode,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                  Center(
                    child: Image.asset(
                      MyImages.emailVerifyImage,
                      height: 100,
                      width: 100,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      "Enter the verification code",
                      style: mulishRegular.copyWith(color: MyColor.textColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  OTPFieldWidget(
                    onChanged: (value) {
                      _otpCode = value;
                      if (_errorMessage != null) {
                        setState(() => _errorMessage = null);
                      }
                      _checkAndSubmit(); // Auto submit on 6 digits
                    },
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? const RoundedLoadingButton()
                      : RoundedButton(
                          text: MyStrings.verify.tr,
                          press: _verifyCode,
                        ),
                  const SizedBox(height: 40),
                  Text(
                    MyStrings.didNotReceiveCode.tr,
                    style: mulishRegular.copyWith(color: MyColor.textColor),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _isResendLoading ? null : _resendCode,
                    child: _isResendLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            MyStrings.resend.tr,
                            style: mulishBold.copyWith(
                              color: MyColor.primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
