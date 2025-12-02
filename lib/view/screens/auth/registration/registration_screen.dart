import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_lab/data/model/auth/register_repo.dart';
import 'package:play_lab/view/will_pop_widget.dart';

import '../../../../constants/my_strings.dart';
import '../../../../core/route/route.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_images.dart';
import '../../../../core/utils/styles.dart';
import '../../../components/auth_image.dart';
import '../../../components/bg_widget/bg_image_widget.dart';
import '../../../components/bottom_Nav/bottom_nav.dart';
import '../../../components/buttons/rounded_button.dart';
import '../../../components/buttons/rounded_loading_button.dart';
import '../../../components/custom_text_form_field.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _agreeTC = false;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeTC) {
      Get.snackbar(
        "Error".tr,
        MyStrings.policies.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    final repo = RegisterRepo();
    final response = await repo.registerUser(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    setState(() => _isLoading = false);

    // SUCCESS CHECK – Works with your real backend response
    bool isSuccess = response.remark == "success" ||
        response.status == "success" ||
        (response.data?.accessToken != null &&
            response.data!.accessToken!.isNotEmpty);

    if (isSuccess) {
      // SUCCESS – Show message + Go to Home
      Get.snackbar(
        "Success".tr,
        "Account created successfully!".tr,
        backgroundColor: MyColor.primaryColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(12),
      );

      // Navigate to Home / Bottom Navigation
      Get.offAllNamed(RouteHelper.loginScreen);
      // Or use: RouteHelper.homeScreen if you have it
    } else {
      // ERROR – Show real backend message
      String errorMsg = "Registration failed. Please try again.";

      if (response.message?.error != null &&
          response.message!.error!.isNotEmpty) {
        errorMsg = response.message!.error!.join("\n");
      } else if (response.message?.success != null &&
          response.message!.success!.isNotEmpty) {
        errorMsg = response.message!.success!.join("\n");
      }

      Get.snackbar(
        "Error".tr,
        errorMsg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 8),
        margin: const EdgeInsets.all(12),
      );
    }
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

                      // First Name
                      InputTextFieldWidget(
                        fillColor: Colors.grey[600]!.withOpacity(0.3),
                        hintTextColor: Colors.white,
                        controller: _firstNameController,
                        hintText: "First Name",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your first name".tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Last Name
                      InputTextFieldWidget(
                        fillColor: Colors.grey[600]!.withOpacity(0.3),
                        hintTextColor: Colors.white,
                        controller: _lastNameController,
                        hintText: "Last Name",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your last name".tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

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
                      GestureDetector(
                        onTap: () => Get.offAllNamed(RouteHelper.loginScreen),
                        child: Text(
                          MyStrings.signIn.tr,
                          style: mulishBold.copyWith(
                            color: MyColor.primaryColor,
                            fontSize: 18,
                          ),
                        ),
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
