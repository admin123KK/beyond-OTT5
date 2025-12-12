import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/api.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/my_images.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/components/auth_image.dart';
import 'package:play_lab/view/components/bg_widget/bg_image_widget.dart';
import 'package:play_lab/view/components/bottom_Nav/bottom_nav.dart';
import 'package:play_lab/view/components/buttons/rounded_button.dart';
import 'package:play_lab/view/components/buttons/rounded_loading_button.dart';
import 'package:play_lab/view/components/custom_text_form_field.dart';
import 'package:play_lab/view/will_pop_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.error_outline_rounded,
            color: Colors.red, size: 40),
        title: Text("Login Failed",
            style: mulishBold.copyWith(color: Colors.white, fontSize: 20)),
        content: Text(message,
            style: mulishSemiBold.copyWith(color: Colors.white70),
            textAlign: TextAlign.center),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: MyColor.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child:
                  Text("OK", style: mulishBold.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // Check verification status after login
  Future<void> _checkVerificationStatus(String token, String email) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.verifyStatusEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        // If already verified → go home
        if (json['remark'] == 'already_verified') {
          Get.offAllNamed(RouteHelper.homeScreen);
          return;
        }
      }

      // If not verified → show dialog
      _showVerificationDialog(email);
    } catch (e) {
      // If API fails, assume not verified and show dialog
      _showVerificationDialog(email);
    }
  }

  // Beautiful Verification Alert Dialog
  void _showVerificationDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.verified_user,
                color: MyColor.primaryColor, size: 32),
            const SizedBox(width: 12),
            Text("Verify Your Account",
                style: mulishBold.copyWith(color: Colors.white, fontSize: 20)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Your account is not verified yet.\nPlease verify your email to continue.",
              style: mulishMedium.copyWith(color: Colors.white70, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              email,
              style: mulishSemiBold.copyWith(
                  color: MyColor.primaryColor, fontSize: 14),
            ),
          ],
        ),
        actions: [
          // Later Button
          TextButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed(RouteHelper.homeScreen);
            },
            child: Text("Later",
                style: mulishSemiBold.copyWith(color: Colors.white70)),
          ),

          // Verify Now Button
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(RouteHelper.verifyEmailScreen, arguments: email);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColor.primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text("Verify Now",
                style: mulishBold.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Normal Email/Password Login
  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.loginEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({
          "username": _usernameController.text.trim(),
          "password": _passwordController.text,
          "is_web": false,
        }),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
        final token = jsonResponse['data']['access_token'];
        final userId = jsonResponse['data']['user']['id'];
        final email = jsonResponse['data']['user']['email'] ?? '';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        await prefs.setInt('user_id', userId);
        await prefs.setBool('is_logged_in', true);

        Get.snackbar(
          "Welcome Back!",
          jsonResponse['message']['success'][0],
          backgroundColor: MyColor.primaryColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );

        // Check verification status
        _checkVerificationStatus(token, email);
      } else {
        String errorMsg =
            jsonResponse['message']?['error']?[0] ?? "Invalid credentials";
        _showErrorDialog(errorMsg);
      }
    } catch (e) {
      _showErrorDialog("No internet or server error");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Google Sign-In
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final String? accessToken = googleAuth.accessToken ?? googleAuth.idToken;

      if (accessToken == null) {
        _showErrorDialog("Failed to get Google token");
        setState(() => _isLoading = false);
        return;
      }

      final response = await http.post(
        Uri.parse(ApiConstants.socialLoginEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({
          "provider": "google",
          "token": accessToken,
          "email": googleUser.email,
          "name": googleUser.displayName ?? "",
          "id": googleUser.id,
        }),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
        final token = jsonResponse['data']['access_token'];
        final userId = jsonResponse['data']['user']['id'];
        final email = jsonResponse['data']['user']['email'] ?? '';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        await prefs.setInt('user_id', userId);
        await prefs.setBool('is_logged_in', true);

        Get.snackbar("Welcome!", "Signed in with Google",
            backgroundColor: MyColor.primaryColor, colorText: Colors.white);

        // Check verification status for Google login too
        _checkVerificationStatus(token, email);
      } else {
        String error =
            jsonResponse['message']?['error']?[0] ?? "$e Google login failed";
        _showErrorDialog(error);
      }
    } catch (e) {
      _showErrorDialog("$e Google Sign-In failed. Try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                    InputTextFieldWidget(
                      fillColor: Colors.grey[600]!.withOpacity(0.3),
                      hintTextColor: Colors.white,
                      controller: _usernameController,
                      hintText: MyStrings.enterUserNameOrEmail.tr,
                      validator: (v) =>
                          v!.isEmpty ? MyStrings.kEmailNullError.tr : null,
                    ),
                    const SizedBox(height: 12),
                    InputTextFieldWidget(
                      fillColor: Colors.grey[600]!.withOpacity(0.3),
                      hintTextColor: Colors.white,
                      isPassword: true,
                      controller: _passwordController,
                      hintText: MyStrings.enterYourPassword_.tr,
                      validator: (v) =>
                          v!.isEmpty ? MyStrings.kPassNullError.tr : null,
                    ),
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () =>
                            Get.toNamed(RouteHelper.forgetPasswordScreen),
                        child: Text(
                          MyStrings.forgetYourPassword.tr,
                          style: mulishSemiBold.copyWith(
                              color: MyColor.primaryColor,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                    _isLoading
                        ? const RoundedLoadingButton()
                        : RoundedButton(
                            text: MyStrings.signIn.tr, press: _loginUser),
                    const SizedBox(height: 35),
                    const Row(
                      children: [
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
                    const SizedBox(height: 25),
                    GestureDetector(
                      onTap: _isLoading ? null : _handleGoogleSignIn,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4))
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(MyImages.gmailIcon,
                                height: 28, width: 28),
                            const SizedBox(width: 14),
                            Text("Continue with Google",
                                style: mulishBold.copyWith(
                                    color: Colors.black87, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(MyStrings.notAccount.tr,
                            style: mulishSemiBold.copyWith(
                                color: MyColor.colorWhite)),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () =>
                              Get.toNamed(RouteHelper.registrationScreen),
                          child: Text(MyStrings.signUp.tr,
                              style: mulishBold.copyWith(
                                  color: MyColor.primaryColor, fontSize: 18)),
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
