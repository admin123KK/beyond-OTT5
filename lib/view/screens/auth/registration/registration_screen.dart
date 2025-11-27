import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_lab/view/will_pop_widget.dart';

import '../../../../constants/my_strings.dart';
import '../../../../core/route/route.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_images.dart';
import '../../../../core/utils/styles.dart';
import '../../../components/auth_image.dart';
import '../../../components/bg_widget/bg_image_widget.dart';
import '../../../components/bottom_Nav/bottom_nav.dart';
import '../../../components/buttons/rounded_button.dart';
import '../../../components/buttons/rounded_loading_button.dart';
import '../../../components/custom_text_form_field.dart'; // Same as Login uses

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _agreeTC = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTC) {
      // Get.snackbar("Error", MyStrings.pleaseAgreeWithPolicies.tr,
      //     backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // Fake delay
    setState(() => _isLoading = false);

    Get.snackbar("Success", "Account created successfully!".tr,
        backgroundColor: MyColor.primaryColor, colorText: Colors.white);

    Get.offAllNamed(RouteHelper.loginScreen);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopWidget(
      nextRoute: RouteHelper.loginScreen,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        bottomNavigationBar: const CustomBottomNav(currentIndex: 4),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              // Same background as Login
              const MyBgWidget(image: MyImages.onboardingBG),

              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.09),
                      const AuthImageWidget(),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.06),

                      // Email
                      InputTextFieldWidget(
                        fillColor: Colors.grey[600]!.withOpacity(0.3),
                        hintTextColor: Colors.white,
                        controller: _emailController,
                        hintText: MyStrings.email.tr,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return MyStrings.kEmailNullError.tr;
                          }
                          if (!MyStrings.emailValidatorRegExp.hasMatch(value)) {
                            return MyStrings.kInvalidEmailError.tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Password
                      InputTextFieldWidget(
                        fillColor: Colors.grey[600]!.withOpacity(0.3),
                        hintTextColor: Colors.white,
                        isPassword: true,
                        controller: _passwordController,
                        hintText: MyStrings.password.tr,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return MyStrings.kPassNullError.tr;
                          }
                          if (value.length < 6) {
                            return "Password must be at least 6 characters".tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Confirm Password
                      InputTextFieldWidget(
                        fillColor: Colors.grey[600]!.withOpacity(0.3),
                        hintTextColor: Colors.white,
                        isPassword: true,
                        controller: _confirmPasswordController,
                        hintText: MyStrings.confirmPassword.tr,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return MyStrings.kMatchPassError.tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Agree to Terms
                      Row(
                        children: [
                          Checkbox(
                            value: _agreeTC,
                            activeColor: MyColor.primaryColor,
                            side: const BorderSide(
                                color: Colors.white, width: 1.5),
                            onChanged: (val) => setState(() => _agreeTC = val!),
                          ),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: '${MyStrings.iAgreeWith.tr} ',
                                style: mulishRegular.copyWith(
                                    color: Colors.white70),
                                children: [
                                  TextSpan(
                                    text: MyStrings.policies.tr,
                                    style: mulishSemiBold.copyWith(
                                      color: MyColor.primaryColor,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => Get.toNamed(
                                          RouteHelper.privacyScreen),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Sign Up Button
                      _isLoading
                          ? const RoundedLoadingButton()
                          : RoundedButton(
                              text: MyStrings.signUp.tr,
                              press: _signUp,
                            ),

                      const SizedBox(height: 50),

                      // Already have account?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Text(
                          //   MyStrings.alreadyHaveAccount,
                          //   style: mulishSemiBold.copyWith(
                          //     color: MyColor.colorWhite,
                          //     fontSize: Dimensions.fontLarge,
                          //   ),
                          // ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () =>
                                Get.offAllNamed(RouteHelper.loginScreen),
                            child: Text(
                              MyStrings.signIn.tr,
                              style: mulishBold.copyWith(
                                color: MyColor.primaryColor,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.06),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
