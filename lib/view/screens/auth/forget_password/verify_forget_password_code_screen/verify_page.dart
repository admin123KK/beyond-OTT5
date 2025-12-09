// verify_page_screen.dart
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
import 'package:play_lab/view/components/buttons/rounded_button.dart';
import 'package:play_lab/view/components/buttons/rounded_loading_button.dart';
import 'package:play_lab/view/components/custom_text_field.dart';

class VerifyPageScreen extends StatefulWidget {
  const VerifyPageScreen({super.key});

  @override
  State<VerifyPageScreen> createState() => _VerifyPageScreenState();
}

class _VerifyPageScreenState extends State<VerifyPageScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _emailError; // To show error below field

  Future<void> _sendVerificationCode() async {
    // Reset error
    setState(() => _emailError = null);

    if (!_formKey.currentState!.validate()) return;

    final String email = _emailController.text.trim();

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.sendEmailEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "email": email,
        }),
      );

      final json = jsonDecode(response.body);

      if (response.statusCode == 200 && json['status'] == 'success') {
        Get.snackbar(
          "Success",
          "Verification code sent to your email!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Navigate to OTP screen
        Get.toNamed(
          RouteHelper.verifyEmailScreen,
          arguments: email,
        );
      } else {
        setState(() {
          _emailError = json['message']?['error']?[0] ??
              "Could not send code. Try again.";
        });
      }
    } catch (e) {
      setState(() {
        _emailError = "No internet connection";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
        title: Text(
          "Verify Account",
          style: mulishBold.copyWith(color: Colors.white, fontSize: 20),
        ),
      ),
      body: Stack(
        children: [
          const MyBgWidget(image: MyImages.onboardingBG),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
            child: Column(
              children: [
                const AuthImageWidget(),
                const SizedBox(height: 50),

                Text(
                  "To verify your account, please provide your registered email address. We will send a verification code.",
                  textAlign: TextAlign.center,
                  style: mulishMedium.copyWith(
                      color: Colors.white70, fontSize: 16),
                ),

                const SizedBox(height: 40),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _emailController,
                        hintText: "Enter your email",
                        isShowBorder: true,
                        fillColor: MyColor.textFiledFillColor,
                        inputType: TextInputType.emailAddress,
                        inputAction: TextInputAction.done,
                        onChanged: (value) {
                          if (_emailError != null) {
                            setState(() => _emailError = null);
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your email";
                          }
                          if (!GetUtils.isEmail(value)) {
                            return "Please enter a valid email";
                          }
                          return null;
                        },
                      ),

                      // Show error below field (just like Forget Password)
                      if (_emailError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _emailError!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 13),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Submit Button
                _isLoading
                    ? const RoundedLoadingButton()
                    : RoundedButton(
                        text: "Submit",
                        press: _sendVerificationCode,
                      ),

                const SizedBox(height: 40),

                // OR Divider
                Row(
                  children: const [
                    Expanded(child: Divider(color: Colors.white38)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("OR",
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600)),
                    ),
                    Expanded(child: Divider(color: Colors.white38)),
                  ],
                ),

                const SizedBox(height: 30),

                // Login Now Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Get.offAllNamed(RouteHelper.loginScreen),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: MyColor.primaryColor, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      "Login Now",
                      style: mulishBold.copyWith(
                          color: MyColor.primaryColor, fontSize: 16),
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
