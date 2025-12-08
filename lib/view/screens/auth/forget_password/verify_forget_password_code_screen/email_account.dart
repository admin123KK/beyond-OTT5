// email_verify_account.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/api.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/my_images.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/components/auth_image.dart';
import 'package:play_lab/view/components/bg_widget/bg_image_widget.dart';
import 'package:play_lab/view/components/buttons/rounded_button.dart'; // Fixed import
import 'package:play_lab/view/components/buttons/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailVerifyAccount extends StatefulWidget {
  @override
  State<EmailVerifyAccount> createState() => _EmailVerifyAccountState();
}

class _EmailVerifyAccountState extends State<EmailVerifyAccount> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    for (var controller in _controllers) controller.dispose();
    for (var node in _focusNodes) node.dispose();
    super.dispose();
  }

  void _moveToNext(int index) {
    if (index < 5 && _controllers[index].text.length == 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (index == 5 && _controllers.every((c) => c.text.isNotEmpty)) {
      _verifyCode(); // Auto submit when 6 digits filled
    }
  }

  void _moveToPrevious(int index) {
    if (index > 0 && _controllers[index].text.isEmpty) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Verify OTP Code
  Future<void> _verifyCode() async {
    final code = _controllers.map((c) => c.text).join();

    if (code.length != 6) {
      Get.snackbar("Invalid", "Please enter full 6-digit code",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse(ApiConstants.verifyEmailEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "code": code,
        }),
      );

      final json = jsonDecode(response.body);

      if (response.statusCode == 200 && json['status'] == 'success') {
        Get.snackbar("Success", "Email verified successfully!",
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.offAllNamed(RouteHelper.homeScreen); // Go to Home
      } else {
        Get.snackbar("Failed",
            json['message']?['error']?[0] ?? "Invalid or expired code",
            backgroundColor: Colors.red, colorText: Colors.white);
        _clearFields();
      }
    } catch (e) {
      Get.snackbar("Error", "Network error. Try again.",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Resend Code
  Future<void> _resendCode() async {
    setState(() => _isResending = true);

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.verifyEmailEndpoint),
        headers: {'Content-Type': 'application/json'},
      );

      final json = jsonDecode(response.body);

      if (response.statusCode == 200 && json['status'] == 'success') {
        Get.snackbar("Sent!", "New code sent to entered email",
            backgroundColor: Colors.green, colorText: Colors.white);
        _clearFields();
      } else {
        Get.snackbar("Failed", json['message'] ?? "Could not resend code",
            backgroundColor: Colors.red);
      }
    } catch (e) {
      Get.snackbar("Error", "Check internet connection",
          backgroundColor: Colors.red);
    } finally {
      setState(() => _isResending = false);
    }
  }

  void _clearFields() {
    for (var controller in _controllers) controller.clear();
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text("Email Verification",
            style: mulishBold.copyWith(color: Colors.white, fontSize: 20)),
      ),
      body: Stack(
        children: [
          const MyBgWidget(image: MyImages.onboardingBG),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
            child: Column(
              children: [
                const AuthImageWidget(),
                const SizedBox(height: 40),

                // Email Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  child: Image.asset(MyImages.emailVerifyImage,
                      height: 60, color: MyColor.primaryColor),
                ),

                const SizedBox(height: 30),

                Text(
                  "We sent a verification code to",
                  style: mulishMedium.copyWith(
                      color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Text(
                //   widget.ema,
                //   style: mulishBold.copyWith(
                //       color: MyColor.primaryColor, fontSize: 17),
                //   textAlign: TextAlign.center,
                // ),

                const SizedBox(height: 50),

                // 6-Digit OTP Input
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 50,
                      height: 60,
                      child: TextFormField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: mulishBold.copyWith(
                            color: Colors.white, fontSize: 22),
                        decoration: InputDecoration(
                          counterText: "",
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.15),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: MyColor.primaryColor, width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.length == 1) _moveToNext(index);
                          if (value.isEmpty) _moveToPrevious(index);
                        },
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 50),

                // Verify Button
                _isLoading
                    ? const RoundedLoadingButton()
                    : RoundedButton(text: "Verify", press: _verifyCode),

                const SizedBox(height: 30),

                // Resend Link
                GestureDetector(
                  onTap: _isResending ? null : _resendCode,
                  child: Text(
                    "Didn't receive the code?\nRESEND",
                    textAlign: TextAlign.center,
                    style: mulishSemiBold.copyWith(
                      color:
                          _isResending ? Colors.white38 : MyColor.primaryColor,
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
