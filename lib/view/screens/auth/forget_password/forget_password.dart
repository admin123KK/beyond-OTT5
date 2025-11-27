import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/utils/dimensions.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/util.dart';
import 'package:play_lab/data/controller/auth/auth/forget_password_controller.dart';
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';
import 'package:play_lab/view/components/auth_image.dart';
import 'package:play_lab/view/components/bg_widget/bg_image_widget.dart';
import 'package:play_lab/view/components/buttons/rounded_button.dart';
import 'package:play_lab/view/components/buttons/rounded_loading_button.dart';
import 'package:play_lab/view/components/custom_text_field.dart';
import 'package:play_lab/view/components/from_errors.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    MyUtil.changeTheme();

    // Initialize controller properly
    Get.lazyPut(() => ForgetPasswordController(loginRepo: Get.find()));

    // Clear previous data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ForgetPasswordController>().clearAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const MyBgWidget(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: const CustomAppBar(
            fromAuth: true,
            isShowBackBtn: true,
            title: MyStrings.forgetPassword,
          ),
          body: GetBuilder<ForgetPasswordController>(
            builder: (controller) => SingleChildScrollView(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
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

                    // Email / Username Field
                    CustomTextField(
                      hintText: MyStrings.emailOrUserName.tr,
                      isShowBorder: true,
                      isPassword: false,
                      fillColor: MyColor.textFiledFillColor,
                      isShowSuffixIcon: false,
                      inputType: TextInputType.emailAddress,
                      inputAction: TextInputAction.done,
                      focusNode: controller.emailFocusNode,
                      onChanged: (value) {
                        controller.email = value.trim();
                        if (value.isNotEmpty) {
                          controller.removeError(
                              error: MyStrings.kEmailNullError);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          controller.addError(error: MyStrings.kEmailNullError);
                          return '';
                        }
                        controller.removeError(
                            error: MyStrings.kEmailNullError);
                        return null;
                      },
                    ),

                    const SizedBox(height: 15),
                    FormError(errors: controller.errors),
                    const SizedBox(height: 25),

                    // Submit Button
                    controller.isLoading
                        ? const RoundedLoadingButton()
                        : RoundedButton(
                            text: MyStrings.submit.tr,
                            press: () async {
                              if (_formKey.currentState!.validate()) {
                                // This is the key fix: await the Future<bool>
                                bool success =
                                    await controller.submitForgetPassCode();

                                // Optional: extra safety (in case navigation already happened inside controller)
                                if (success && mounted) {
                                  // Auto navigation already handled in controller
                                  // But you can show snackbar here if you want
                                }
                              }
                            },
                          ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
