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
import 'package:play_lab/view/components/custom_text_form_field.dart';

class VerifyPageScreen extends StatefulWidget {
  const VerifyPageScreen({super.key});

  @override
  State<VerifyPageScreen> createState() => _VerifyPageScreenState();
}

class _VerifyPageScreenState extends State<VerifyPageScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _sendVerificationCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.sendEmailEndpoint), // CORRECT ENDPOINT
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "email": _emailController.text.trim(),
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

        // Navigate to OTP Screen with Email
        Get.toNamed(
          RouteHelper.codeVerifyScreen,
          arguments: _emailController.text.trim(),
        );
      } else {
        Get.snackbar(
          "Failed",
          json['message']?['error']?[0] ?? "Could not send verification code",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "No internet connection",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
                  child: InputTextFieldWidget(
                    fillColor: Colors.grey[600]!.withOpacity(0.4),
                    hintTextColor: Colors.white70,
                    controller: _emailController,
                    hintText: "Enter your email",
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
                  children: [
                    const Expanded(child: Divider(color: Colors.white38)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "OR",
                        style: mulishSemiBold.copyWith(color: Colors.white70),
                      ),
                    ),
                    const Expanded(child: Divider(color: Colors.white38)),
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
