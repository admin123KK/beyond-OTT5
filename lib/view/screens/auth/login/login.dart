// login_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/api.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/dimensions.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/my_images.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/components/auth_image.dart';
import 'package:play_lab/view/components/bg_widget/bg_image_widget.dart';
import 'package:play_lab/view/components/bottom_Nav/bottom_nav.dart';
import 'package:play_lab/view/components/buttons/rounded_button.dart';
import 'package:play_lab/view/components/buttons/rounded_loading_button.dart';
import 'package:play_lab/view/components/custom_text_form_field.dart'; // fixed typo
import 'package:play_lab/view/will_pop_widget.dart';
import 'package:shared_preferences/shared_preferences.dart'; // We'll save token

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.loginEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "username": _usernameController.text.trim(),
          "password": _passwordController.text,
          "is_web": false, // As per your API
        }),
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
        // Success! Save token and user data
        final String token = jsonResponse['data']['access_token'];
        final int userId = jsonResponse['data']['user']['id'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        await prefs.setInt('user_id', userId);
        await prefs.setBool('is_logged_in', true);

        Get.offAllNamed(RouteHelper.homeScreen);
        Get.snackbar(
          "Welcome Back!",
          jsonResponse['message']['success'][0],
          backgroundColor: MyColor.primaryColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
        );
      } else {
        // Failed login
        String errorMsg = "Login failed";
        if (jsonResponse['message'] != null) {
          if (jsonResponse['message'] is Map &&
              jsonResponse['message']['error'] != null) {
            errorMsg = jsonResponse['message']['error'][0];
          } else if (jsonResponse['message'] is Map &&
              jsonResponse['message']['success'] == null) {
            errorMsg = "Invalid credentials";
          }
        }
        setState(() {
          _errorMessage = errorMsg;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "No internet connection or server error";
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopWidget(
      nextRoute: '',
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        bottomNavigationBar: const CustomBottomNav(currentIndex: 4),
        body: Stack(
          children: [
            const MyBgWidget(image: MyImages.onboardingBG),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.09),
                    const AuthImageWidget(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.06),

                    // Username or Email Field
                    InputTextFieldWidget(
                      fillColor: Colors.grey[600]!.withOpacity(0.3),
                      hintTextColor: Colors.white,
                      controller: _usernameController,
                      hintText: MyStrings.enterUserNameOrEmail.tr,
                      validator: (value) =>
                          value!.isEmpty ? MyStrings.kEmailNullError.tr : null,
                    ),

                    const SizedBox(height: 12),

                    // Password Field
                    InputTextFieldWidget(
                      fillColor: Colors.grey[600]!.withOpacity(0.3),
                      hintTextColor: Colors.white,
                      isPassword: true,
                      controller: _passwordController,
                      hintText: MyStrings.enterYourPassword_.tr,
                      validator: (value) =>
                          value!.isEmpty ? MyStrings.kPassNullError.tr : null,
                    ),

                    const SizedBox(height: 15),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () =>
                            Get.toNamed(RouteHelper.forgetPasswordScreen),
                        child: Text(
                          MyStrings.forgetYourPassword.tr,
                          style: mulishSemiBold.copyWith(
                            color: MyColor.primaryColor,
                            fontSize: Dimensions.fontDefault,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Error Message Box
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade400),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Login Button
                    _isLoading
                        ? const RoundedLoadingButton()
                        : RoundedButton(
                            text: MyStrings.signIn.tr,
                            press: _loginUser,
                          ),

                    const SizedBox(height: 50),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          MyStrings.notAccount.tr,
                          style: mulishSemiBold.copyWith(
                              color: MyColor.colorWhite,
                              fontSize: Dimensions.fontLarge),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () =>
                              Get.toNamed(RouteHelper.registrationScreen),
                          child: Text(
                            MyStrings.signUp.tr,
                            style: mulishBold.copyWith(
                                color: MyColor.primaryColor, fontSize: 18),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
