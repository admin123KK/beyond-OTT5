// login_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
import 'package:play_lab/view/components/custom_text_form_field.dart';
import 'package:play_lab/view/will_pop_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // Fake login delay
    setState(() => _isLoading = false);

    Get.snackbar("Success", "Login successful!".tr,
        backgroundColor: MyColor.primaryColor, colorText: Colors.white);

    // CORRECT ROUTE — Pick ONE that exists in your RouteHelper
    Get.offAllNamed(RouteHelper.homeScreen); // Most common
    // Get.offAllNamed(RouteHelper.homeScreen);
    // Get.offAllNamed(RouteHelper.bottomNavScreen);
    // Get.offAllNamed(RouteHelper.navBarScreen);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopWidget(
      nextRoute: '',
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
                      InputTextFieldWidget(
                        fillColor: Colors.grey[600]!.withOpacity(0.3),
                        hintTextColor: Colors.white,
                        controller: _emailController,
                        hintText: MyStrings.enterUserNameOrEmail.tr,
                        validator: (value) => value!.isEmpty
                            ? MyStrings.kEmailNullError.tr
                            : null,
                      ),
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 30),
                      _isLoading
                          ? const RoundedLoadingButton()
                          : RoundedButton(
                              text: MyStrings.signIn.tr,
                              press: _login,
                            ),
                      const SizedBox(height: 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            MyStrings.notAccount.tr,
                            style: mulishSemiBold.copyWith(
                              color: MyColor.colorWhite,
                              fontSize: Dimensions.fontLarge,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () =>
                                Get.toNamed(RouteHelper.registrationScreen),
                            child: Text(
                              MyStrings.signUp.tr,
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
