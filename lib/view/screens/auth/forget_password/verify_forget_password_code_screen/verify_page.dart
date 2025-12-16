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
import 'package:play_lab/core/utils/util.dart';
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';
import 'package:play_lab/view/components/auth_image.dart';
import 'package:play_lab/view/components/bg_widget/bg_image_widget.dart';
import 'package:play_lab/view/components/buttons/rounded_button.dart';
import 'package:play_lab/view/components/buttons/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyPageScreen extends StatefulWidget {
  const VerifyPageScreen({super.key});

  @override
  State<VerifyPageScreen> createState() => _VerifyPageScreenState();
}

class _VerifyPageScreenState extends State<VerifyPageScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  String? _userEmail; // To show the email (optional)

  @override
  void initState() {
    super.initState();
    MyUtil.changeTheme();
    _loadUserEmailAndSendCode(); // Automatically fetch email and send code on page load
  }

  Future<void> _loadUserEmailAndSendCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      setState(() {
        _errorMessage = "Session expired. Please login again.";
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.verifyEmailEndpoint), // e.g., /api/verify/email
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
        final String email =
            jsonResponse['data']?['email'] ?? "your registered email";

        await prefs.setString('forget_pass_email', email);

        setState(() {
          _userEmail = email;
        });

        Get.snackbar(
          "Code Sent!",
          "Verification code sent to your email",
          backgroundColor: MyColor.primaryColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 4),
        );

        Get.offAndToNamed(RouteHelper.codeVerifyScreen);
      } else {
        String error = "Something went wrong";
        if (jsonResponse['message'] is String) {
          error = jsonResponse['message'];
        } else if (jsonResponse['message']?['error'] is List) {
          error = jsonResponse['message']['error'][0];
        } else if (jsonResponse['message']?['error'] is String) {
          error = jsonResponse['message']['error'];
        }
        setState(() => _errorMessage = error);
      }
    } catch (e) {
      setState(() => _errorMessage = "No internet connection");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const MyBgWidget(image: MyImages.onboardingBG),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: const CustomAppBar(
            fromAuth: true,
            isShowBackBtn: true,
            title: MyStrings.verifyEmail,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                const AuthImageWidget(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.07),

                // Description
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    'We have sent a verification code to your registered email.\nPlease check your inbox.',
                    style: TextStyle(
                      color: MyColor.t2,
                      fontSize: Dimensions.authTextSize,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 45),

                if (_isLoading)
                  const RoundedLoadingButton()
                else if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Sending code automatically...',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 40),

                // Optional: Retry button if error
                if (_errorMessage != null)
                  RoundedButton(
                    text: "Retry",
                    press: _loadUserEmailAndSendCode,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
