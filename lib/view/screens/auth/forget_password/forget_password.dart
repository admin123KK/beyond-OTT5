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
import 'package:play_lab/view/components/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    MyUtil.changeTheme();
  }

  Future<void> _submitForgetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final String email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = MyStrings.kEmailNullError.tr);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse(
            ApiConstants.forgotPasswordEndpoint), // Your /api/password/email
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "type": "email", // or "username" if your backend supports both
          "value": email,
        }),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
        // Save email for next screen
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('forget_pass_email', email);

        // Show success snackbar
        Get.snackbar(
          "Success!",
          "Verification code sent to $email",
          backgroundColor: MyColor.primaryColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );

        // Navigate to Verify Code Screen
        Get.offAndToNamed(RouteHelper.emailVerificationScreen);
      } else {
        String error = "Something went wrong";
        if (jsonResponse['message']?['error'] is List) {
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
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
            title: MyStrings.forgetPassword,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                  const AuthImageWidget(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.07),

                  // Description
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      MyStrings.toRecover.tr,
                      style: const TextStyle(
                        color: MyColor.t2,
                        fontSize: Dimensions.authTextSize,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 45),

                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    hintText: MyStrings.emailOrUserName.tr,
                    isShowBorder: true,
                    fillColor: MyColor.textFiledFillColor,
                    inputType: TextInputType.emailAddress,
                    inputAction: TextInputAction.done,
                    onChanged: (value) {
                      if (_errorMessage != null) {
                        setState(() => _errorMessage = null);
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return MyStrings.kEmailNullError.tr;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  // Error Message
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),

                  const SizedBox(height: 25),

                  // Submit Button
                  _isLoading
                      ? const RoundedLoadingButton()
                      : RoundedButton(
                          text: MyStrings.submit.tr,
                          press: _submitForgetPassword,
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
