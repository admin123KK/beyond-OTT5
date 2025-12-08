// profile_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/api.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/my_images.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/screens/account/chagne_password/change_password.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _isLoading = true;

  // Controllers
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController mobileController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController zipController;
  late TextEditingController countryCodeController; // Added
  late TextEditingController dialCodeController; // Added

  // User Data
  String firstName = '';
  String lastName = '';
  String email = '';
  String mobile = '';
  String address = '';
  String city = '';
  String state = '';
  String zip = '';
  String dialCode = '';
  String countryCode = '';
  bool isEmailVerified = false;
  bool isMobileVerified = false;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    mobileController = TextEditingController();
    addressController = TextEditingController();
    cityController = TextEditingController();
    stateController = TextEditingController();
    zipController = TextEditingController();
    countryCodeController = TextEditingController(); // Init
    dialCodeController = TextEditingController(); // Init

    _fetchUserProfile();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipController.dispose();
    countryCodeController.dispose();
    dialCodeController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> _fetchUserProfile() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      Get.snackbar("Error", "Please login again", backgroundColor: Colors.red);
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getInfoEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("Profile Response: ${response.statusCode}\n${response.body}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json['remark'] == 'unverified') {
          Get.snackbar(
            "Verify Account",
            "Please logout and re-login to verify your account",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 6),
          );
        }

        final user = json['data']['user'];

        setState(() {
          firstName = user['firstname'] ?? '';
          lastName = user['lastname'] ?? '';
          email = user['email'] ?? '';
          mobile = user['mobile'] ?? '';
          address = user['address'] ?? '';
          city = user['city'] ?? '';
          state = user['state'] ?? '';
          zip = user['zip'] ?? '';
          dialCode = user['dial_code'] ?? '';
          countryCode = user['country_code'] ?? '';

          isEmailVerified = (user['ev'] ?? 0) == 1;
          isMobileVerified = (user['sv'] ?? 0) == 1;

          // Fill all controllers
          firstNameController.text = firstName;
          lastNameController.text = lastName;
          emailController.text = email;
          mobileController.text = mobile;
          addressController.text = address;
          cityController.text = city;
          stateController.text = state;
          zipController.text = zip;
          countryCodeController.text = countryCode;
          dialCodeController.text = dialCode;

          _isLoading = false;
        });
      } else {
        Get.snackbar("Error", "Failed to load profile");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error: $e");
      Get.snackbar("Error", "Check internet connection");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitProfile() async {
    final token = await _getToken();
    if (token == null) return;

    final body = {
      "firstname": firstNameController.text.trim(),
      "lastname": lastNameController.text.trim(),
      "mobile": mobileController.text.trim(),
      "address": addressController.text.trim(),
      "city": cityController.text.trim(),
      "state": stateController.text.trim(),
      "zip": zipController.text.trim(),
      "country_code": countryCodeController.text.trim().toUpperCase(),
      "dial_code": dialCodeController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.submitInfoEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final json = jsonDecode(response.body);
      debugPrint("Update Response: ${response.body}");

      if (response.statusCode == 200 && json['status'] == 'success') {
        setState(() {
          firstName = firstNameController.text.trim();
          lastName = lastNameController.text.trim();
          mobile = mobileController.text.trim();
          address = addressController.text.trim();
          city = cityController.text.trim();
          state = stateController.text.trim();
          zip = zipController.text.trim();
          countryCode = countryCodeController.text.trim().toUpperCase();
          dialCode = dialCodeController.text.trim();
          _isEditing = false;
        });
        Get.snackbar("Success", "Profile updated!",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        final error = json['message']?['error']?[0] ?? "Update failed";
        Get.snackbar("Failed", error, backgroundColor: Colors.red);
      }
    } catch (e) {
      Get.snackbar("Error", "Network error");
    }
  }

  void _toggleEdit() {
    if (_isEditing) {
      _submitProfile();
    } else {
      setState(() => _isEditing = true);
    }
  }

  void _cancelEdit() {
    firstNameController.text = firstName;
    lastNameController.text = lastName;
    mobileController.text = mobile;
    addressController.text = address;
    cityController.text = city;
    stateController.text = state;
    zipController.text = zip;
    countryCodeController.text = countryCode;
    dialCodeController.text = dialCode;
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool showBackButton = Get.routing.previous != '/';

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: MyColor.colorBlack,
        body: Center(
            child: CircularProgressIndicator(color: MyColor.primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: MyColor.colorBlack,
      appBar: AppBar(
        backgroundColor: MyColor.colorBlack,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 20),
                onPressed: () => Get.back(),
              )
            : null,
        title: Text(_isEditing ? "Edit Profile" : "Profile",
            style: mulishSemiBold.copyWith(color: Colors.white, fontSize: 18)),
        actions: [
          if (!_isEditing)
            IconButton(
                onPressed: _toggleEdit,
                icon: const Icon(Icons.edit, color: Colors.white)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white24,
              child: Image.asset(MyImages.profile,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.person,
                      size: 60, color: Colors.white60)),
            ),

            const SizedBox(height: 16),
            Text("$firstName $lastName",
                style:
                    mulishSemiBold.copyWith(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(email,
                    style: mulishMedium.copyWith(
                        color: Colors.white70, fontSize: 14)),
                const SizedBox(width: 8),
                Icon(isEmailVerified ? Icons.verified : Icons.info_outline,
                    color: isEmailVerified ? Colors.green : Colors.orange,
                    size: 18),
              ],
            ),

            const SizedBox(height: 30),

            // All Fields
            _buildField("First Name", firstNameController),
            _buildField("Last Name", lastNameController),
            _buildField("Email Address", emailController, enabled: false),
            _buildField("Mobile Number", mobileController),
            _buildField("Address", addressController),
            _buildField("City", cityController),
            _buildField("State", stateController),
            _buildField("ZIP Code", zipController),

            // Country Code & Dial Code Fields (Editable)
            _buildField("Country Code (e.g. US, IN)", countryCodeController),
            _buildField("Dial Code (e.g. +1, +91)", dialCodeController),

            const SizedBox(height: 40),

            // Buttons
            if (_isEditing)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _toggleEdit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColor.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Save Changes",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancelEdit,
                      style: OutlinedButton.styleFrom(
                        side:
                            const BorderSide(color: Colors.white24, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Cancel",
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _toggleEdit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColor.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Edit Profile",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Get.to(() => const ChangePasswordScreen()),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: MyColor.primaryColor, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Change Password",
                          style: TextStyle(
                              color: MyColor.primaryColor,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  mulishMedium.copyWith(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            enabled: _isEditing && enabled,
            style: mulishSemiBold.copyWith(
                color: enabled ? Colors.white : Colors.white60, fontSize: 16),
            decoration: InputDecoration(
              filled: true,
              fillColor: _isEditing && enabled
                  ? Colors.white.withOpacity(0.12)
                  : Colors.white.withOpacity(0.08),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
          ),
        ],
      ),
    );
  }
}
