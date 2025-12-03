// reset_password_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/api.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/dimensions.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/my_images.dart';
import 'package:play_lab/core/utils/util.dart';
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';
import 'package:play_lab/view/components/auth_image.dart';
import 'package:play_lab/view/components/bg_widget/bg_image_widget.dart';
import 'package:play_lab/view/components/buttons/rounded_button.dart';
import 'package:play_lab/view/components/buttons/rounded_loading_button.dart';
import 'package:play_lab/view/components/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;

  String? _email;
  String? _verifiedOtpCode; // ← We now store the 6-digit code here

  @override
  void initState() {
    super.initState();
    MyUtil.changeTheme();
    _loadEmailAndOtpCode(); // ← Load both email & verified code
  }

  // Load saved email and the 6-digit code that user entered in previous screen
  Future<void> _loadEmailAndOtpCode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('forget_pass_email');
      _verifiedOtpCode = prefs.getString(
          'verified_otp_code'); // ← This was saved in EmailVerificationScreen
    });

    // Optional debug (remove later)
    // print("Loaded Email: $_email");
    // print("Loaded OTP Code: $_verifiedOtpCode");
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      setState(() => _errorMessage = "Passwords do not match");
      return;
    }

    if (_email == null ||
        _verifiedOtpCode == null ||
        _verifiedOtpCode!.isEmpty) {
      setState(() =>
          _errorMessage = "Session expired. Please try forgot password again.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.resetPasswordEndpoint), // /api/password/reset
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "token": _verifiedOtpCode, // ← Send the same 6-digit code
          "email": _email,
          "password": password,
          "password_confirmation": confirmPassword,
        }),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
        // Clear everything
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('forget_pass_email');
        await prefs.remove('verified_otp_code');

        Get.snackbar(
          "Success!",
          "Password changed successfully!",
          backgroundColor: MyColor.primaryColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );

        Get.offAllNamed(RouteHelper.loginScreen); // ← Back to login
      } else {
        String error = jsonResponse['message']?['error']?[0] ??
            jsonResponse['message']?['error'] ??
            "Failed to reset password";
        setState(() => _errorMessage = error);
      }
    } catch (e) {
      setState(() => _errorMessage = "No internet connection");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
              title: MyStrings.resetPassword,
              fromAuth: true,
              isShowBackBtn: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                    const AuthImageWidget(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.07),

                    Text(
                      MyStrings.resetLabelText.tr,
                      style: const TextStyle(
                          color: MyColor.t2, fontSize: Dimensions.authTextSize),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // New Password
                    CustomTextField(
                      controller: _passwordController,
                      hintText: MyStrings.password.tr,
                      isPassword: true,
                      isShowSuffixIcon: true,
                      fillColor: MyColor.textFiledFillColor,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return MyStrings.kPassNullError.tr;
                        if (value.length < 6)
                          return "Password must be at least 6 characters";
                        return null;
                      },
                      onChanged: null,
                    ),

                    const SizedBox(height: 15),

                    // Confirm Password
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hintText: MyStrings.confirmPassword.tr,
                      isPassword: true,
                      isShowSuffixIcon: true,
                      fillColor: MyColor.textFiledFillColor,
                      inputAction: TextInputAction.done,
                      validator: (value) {
                        if (value != _passwordController.text)
                          return MyStrings.kMatchPassError.tr;
                        return null;
                      },
                      onChanged: null,
                    ),

                    const SizedBox(height: 20),

                    // Error Message
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          _errorMessage!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 30),

                    // Submit Button
                    _isLoading
                        ? const RoundedLoadingButton()
                        : RoundedButton(
                            text: MyStrings.submit.tr,
                            press: _resetPassword,
                          ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
