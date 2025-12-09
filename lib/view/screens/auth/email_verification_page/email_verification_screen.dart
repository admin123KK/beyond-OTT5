// email_verification_screen.dart ← EXACT SAME NAME
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

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  String? _email;
  String _otpCode = '';
  bool _isLoading = false;
  bool _isResendLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    MyUtil.changeTheme();
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('forget_pass_email') ?? '';
    });
  }

  // AUTO SUBMIT WHEN 6 DIGITS ARE ENTERED
  void _checkAndAutoSubmit() {
    if (_otpCode.length == 6 && !_isLoading) {
      _verifyCode(); // AUTO SUBMIT!
    }
  }

  // Verify the code + SAVE IT for next screen
  Future<void> _verifyCode() async {
    if (_otpCode.length != 6) {
      setState(() => _errorMessage = "Please enter 6-digit code");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.verifyCodeEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({
          "code": _otpCode,
          "email": _email,
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

        Get.offAndToNamed(RouteHelper.resetPasswordScreen);
      } else {
        final error =
            jsonResponse['message']?['error']?[0] ?? "Invalid or expired code";
        setState(() => _errorMessage = error);
      }
    } catch (e) {
      setState(() => _errorMessage = "Network error. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Resend Code
  Future<void> _resendCode() async {
    if (_email == null || _email!.isEmpty) {
      Get.snackbar("Error", "Email not found!");
      return;
    }

    setState(() => _isResendLoading = true);

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.forgotPasswordEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({
          "type": "email",
          "value": _email,
        }),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
        Get.snackbar("Sent!", "New code sent to $_email",
            backgroundColor: MyColor.primaryColor, colorText: Colors.white);
      } else {
        Get.snackbar("Failed", "Could not resend code");
      }
    } catch (e) {
      Get.snackbar("Error", "No internet");
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
              title: MyStrings.emailVerification,
              isShowBackBtn: true,
              fromAuth: true,
              textColor: MyColor.colorWhite,
              bgColor: Colors.transparent,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                  Center(
                      child: Image.asset(MyImages.emailVerifyImage,
                          height: 100, width: 100)),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: mulishRegular.copyWith(color: MyColor.textColor),
                        children: [
                          const TextSpan(
                              text: "We sent a verification code to\n"),
                          TextSpan(
                              text: _email ?? "your email",
                              style: mulishBold.copyWith(
                                  color: MyColor.primaryColor)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // AUTO SUBMIT ON 6TH DIGIT
                  OTPFieldWidget(
                    onChanged: (value) {
                      _otpCode = value;
                      if (_errorMessage != null) {
                        setState(() => _errorMessage = null);
                      }
                      _checkAndAutoSubmit(); // AUTO SUBMIT HERE!
                    },
                  ),

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(_errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center),
                    ),
                  const SizedBox(height: 30),

                  // Button still works as backup
                  _isLoading
                      ? const RoundedLoadingButton()
                      : RoundedButton(
                          text: MyStrings.verify.tr,
                          press: _verifyCode,
                        ),

                  const SizedBox(height: 40),
                  Text(MyStrings.didNotReceiveCode.tr,
                      style: mulishRegular.copyWith(color: MyColor.textColor)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _isResendLoading ? null : _resendCode,
                    child: _isResendLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(MyStrings.resend.tr,
                            style: mulishBold.copyWith(
                                color: MyColor.primaryColor,
                                decoration: TextDecoration.underline)),
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
