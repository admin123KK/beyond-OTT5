// profile_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/api.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/my_images.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSubmitting = false;

  // Controllers
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController mobileController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController zipController;
  late TextEditingController countryCodeController;
  late TextEditingController dialCodeController;
  late TextEditingController countryNameController;

  // User Data
  String firstName = '';
  String lastName = '';
  String email = '';
  String userName = '';
  String mobile = '';
  String address = '';
  String city = '';
  String state = '';
  String zip = '';
  String dialCode = '';
  String countryCode = '';
  String countryName = '';
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
    countryCodeController = TextEditingController();
    dialCodeController = TextEditingController();
    countryNameController = TextEditingController();

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
    countryNameController.dispose();
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
          'Authorization': 'Bearer $token',
          'Accept': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final user = json['data']['user'];

        setState(() {
          firstName = user['firstname'] ?? '';
          lastName = user['lastname'] ?? '';
          userName = user['username'] ?? '';
          email = user['email'] ?? '';
          mobile = user['mobile'] ?? '';
          address = user['address'] ?? '';
          city = user['city'] ?? '';
          state = user['state'] ?? '';
          zip = user['zip'] ?? '';
          dialCode = user['dial_code'] ?? '';
          countryCode = user['country_code'] ?? '';
          countryName = user['country'] ?? user['country_name'] ?? '';

          isEmailVerified = (user['ev'] ?? 0) == 1;
          isMobileVerified = (user['sv'] ?? 0) == 1;

          // Fill controllers
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
          countryNameController.text = countryName;

          _isLoading = false;
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Check internet connection");
      setState(() => _isLoading = false);
    }
  }

  // MAIN SAVE FUNCTION - CALLS BOTH APIs
  Future<void> _submitProfile() async {
    final token = await _getToken();
    if (token == null) return;

    setState(() => _isSubmitting = true);

    bool successContact = false;
    bool successName = false;
    String errorMsg = "";

    // API 1: submitInfoEndpoint
    try {
      final body = {
        "country_code": countryCodeController.text.trim().toUpperCase(),
        "country": countryNameController.text.trim(),
        "mobile_code": dialCodeController.text.trim().replaceAll('+', ''),
        "mobile": mobileController.text.trim(),
        "username": userName,
        "address": addressController.text.trim(),
        "city": cityController.text.trim(),
        "state": stateController.text.trim(),
        "zip": zipController.text.trim(),
      };

      final resp = await http.post(
        Uri.parse(ApiConstants.submitInfoEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final jsonResp = jsonDecode(resp.body);
      if (resp.statusCode == 200 && jsonResp['status'] == 'success') {
        successContact = true;
      } else {
        errorMsg = jsonResp['message']?['error']?[0] ?? "Contact update failed";
      }
    } catch (e) {
      errorMsg = "Failed to update contact";
    }

    // API 2: updateProfileEndpoint (Name + Address)
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse(ApiConstants.updateProfileEndpoint));
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['firstname'] = firstNameController.text.trim();
      request.fields['lastname'] = lastNameController.text.trim();
      request.fields['address'] = addressController.text.trim();
      request.fields['city'] = cityController.text.trim();
      request.fields['state'] = stateController.text.trim();
      request.fields['zip'] = zipController.text.trim();

      final streamedResp = await request.send();
      final resp = await http.Response.fromStream(streamedResp);
      final jsonResp = jsonDecode(resp.body);

      if (resp.statusCode == 200 &&
          (jsonResp['status'] == 'success' ||
              jsonResp['message']?.toString().contains('success') == true)) {
        successName = true;
      }
    } catch (e) {
      // Ignore if name update fails
    }

    // Final Result
    if (successContact || successName) {
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
        countryName = countryNameController.text.trim();
        _isEditing = false;
      });
      Get.snackbar("Success", "Profile updated successfully!",
          backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar("Failed", errorMsg, backgroundColor: Colors.red);
    }

    setState(() => _isSubmitting = false);
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
    countryNameController.text = countryName;
    setState(() => _isEditing = false);
  }

  // Temporary Verify Now Action (will be replaced later)
  void _onVerifyNowPressed() {
    Get.snackbar("Coming Soon", "Verification page is under development",
        backgroundColor: Colors.orange, colorText: Colors.white);
    // Later: Get.toNamed(RouteHelper.verifyAccountScreen);
  }

  @override
  Widget build(BuildContext context) {
    final bool showBackButton = Get.routing.previous != '/';
    final bool isVerified = isEmailVerified && isMobileVerified;

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
                onPressed: () => Get.back())
            : null,
        title: Text(_isEditing ? "Edit Profile" : "Profile",
            style: mulishSemiBold.copyWith(color: Colors.white, fontSize: 18)),
        actions: [
          if (!_isEditing)
            IconButton(
                onPressed: _toggleEdit,
                icon: const Icon(Icons.edit, color: Colors.white))
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
                        size: 60, color: Colors.white60))),

            const SizedBox(height: 16),
            Text("$firstName $lastName",
                style:
                    mulishSemiBold.copyWith(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('#$userName',
                  style: mulishMedium.copyWith(
                      color: Colors.white70, fontSize: 14)),
              const SizedBox(width: 8),
              Icon(isVerified ? Icons.verified : Icons.info_outline,
                  color: isVerified ? Colors.green : Colors.orange, size: 18),
              if (!isVerified) const SizedBox(width: 6),
              if (!isVerified)
                Text("Not Verified",
                    style: mulishMedium.copyWith(
                        color: Colors.orange, fontSize: 13)),
            ]),

            const SizedBox(height: 30),

            _buildField("First Name", firstNameController),
            _buildField("Last Name", lastNameController),
            _buildField("Email Address", emailController, enabled: false),
            _buildField("Mobile Number", mobileController),
            _buildField("Address", addressController),
            _buildField("City", cityController),
            _buildField("State", stateController),
            _buildField("ZIP Code", zipController),
            _buildField("Country Code (e.g. NP)", countryCodeController),
            _buildField("Dial Code (e.g. +977)", dialCodeController),
            _buildField("Country (e.g. Nepal)", countryNameController),

            const SizedBox(height: 40),

            // BUTTONS LOGIC
            if (_isEditing)
              Row(children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _toggleEdit,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: MyColor.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text("Save Changes",
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
                            side: const BorderSide(
                                color: Colors.white24, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        child: const Text("Cancel",
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600)))),
              ])
            else
              Row(children: [
                InkWell(
                  onTap: _toggleEdit,
                  child: Container(
                    height: 35,
                    width: 150,
                    decoration: BoxDecoration(
                        color: MyColor.primaryColor,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Center(
                        child: Text(
                      'Edit Profile',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.white),
                    )),
                  ),
                ),

                // Show "Verify Now" only if NOT verified
                if (!isVerified) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _onVerifyNowPressed,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.orange, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Verify Now",
                          style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ]),

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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: mulishMedium.copyWith(color: Colors.white70, fontSize: 14)),
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
      ]),
    );
  }
}
