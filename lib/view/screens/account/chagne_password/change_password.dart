// change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants/my_strings.dart';
import '../../../../core/utils/my_color.dart';
import '../../../components/app_bar/custom_appbar.dart';
import '../../../components/buttons/rounded_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  // Focus Nodes
  final FocusNode _currentPassFocus = FocusNode();
  final FocusNode _newPassFocus = FocusNode();
  final FocusNode _confirmPassFocus = FocusNode();

  // Password Visibility
  bool _isNewPassVisible = false;
  bool _isConfirmPassVisible = false;

  // Error Messages
  String? _currentPassError;
  String? _newPassError;
  String? _confirmPassError;

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    _currentPassFocus.dispose();
    _newPassFocus.dispose();
    _confirmPassFocus.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    setState(() {
      _currentPassError = null;
      _newPassError = null;
      _confirmPassError = null;
    });

    String currentPass = _currentPassController.text.trim();
    String newPass = _newPassController.text.trim();
    String confirmPass = _confirmPassController.text.trim();

    bool hasError = false;

    if (currentPass.isEmpty) {
      _currentPassError = MyStrings.currentPassNullError;
      hasError = true;
    }
    if (newPass.isEmpty) {
      _newPassError = MyStrings.kPassNullError;
      hasError = true;
    } else if (newPass.length < 6) {
      _newPassError = "Password must be at least 6 characters";
      hasError = true;
    }
    if (confirmPass.isEmpty) {
      _confirmPassError = "Please confirm your password";
      hasError = true;
    } else if (newPass != confirmPass) {
      _confirmPassError = MyStrings.kMatchPassError;
      hasError = true;
    }

    if (!hasError) {
      // Success - Simulate password change
      Get.snackbar(
        "Success",
        "Password changed successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

      // Optional: Go back after success
      Future.delayed(const Duration(seconds: 1), () {
        Get.back();
      });
    } else {
      setState(() {}); // Show errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.colorBlack,
      appBar: const CustomAppBar(
        title: MyStrings.changePassword,
        bgColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: MyColor.secondaryColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: MyColor.primaryColor.withOpacity(0.3), width: 1),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Update your password securely",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 30),

                // Current Password
                const Text("Current Password",
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _currentPassController,
                  focusNode: _currentPassFocus,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Enter current password",
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    errorText: _currentPassError,
                    errorStyle: const TextStyle(color: Colors.redAccent),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  onSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_newPassFocus),
                ),
                const SizedBox(height: 20),

                // New Password
                const Text("New Password",
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _newPassController,
                  focusNode: _newPassFocus,
                  obscureText: !_isNewPassVisible,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Enter new password",
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    errorText: _newPassError,
                    errorStyle: const TextStyle(color: Colors.redAccent),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _isNewPassVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white70),
                      onPressed: () => setState(
                          () => _isNewPassVisible = !_isNewPassVisible),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  onSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_confirmPassFocus),
                ),
                const SizedBox(height: 20),

                // Confirm Password
                const Text("Confirm New Password",
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _confirmPassController,
                  focusNode: _confirmPassFocus,
                  obscureText: !_isConfirmPassVisible,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Re-type new password",
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    errorText: _confirmPassError,
                    errorStyle: const TextStyle(color: Colors.redAccent),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _isConfirmPassVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white70),
                      onPressed: () => setState(
                          () => _isConfirmPassVisible = !_isConfirmPassVisible),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  onSubmitted: (_) => _validateAndSubmit(),
                ),
                const SizedBox(height: 40),

                // Change Password Button
                SizedBox(
                  width: double.infinity,
                  child: RoundedButton(
                    text: MyStrings.changePassword,
                    press: _validateAndSubmit,
                    color: MyColor.primaryColor,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
