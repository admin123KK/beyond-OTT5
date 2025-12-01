// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/my_images.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/screens/account/chagne_password/change_password.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  // Controllers for editable fields
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController mobileController;
  late TextEditingController countryController;
  late TextEditingController addressController;

  // Initial values
  String firstName = "Sky";
  String lastName = "Karki";
  String email = "sky@example.com";
  String mobile = "+977 9812345678";
  String country = "Nepal";
  String address = "Kathmandu, Nepal";

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: firstName);
    lastNameController = TextEditingController(text: lastName);
    emailController = TextEditingController(text: email);
    mobileController = TextEditingController(text: mobile);
    countryController = TextEditingController(text: country);
    addressController = TextEditingController(text: address);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    countryController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    if (_isEditing) {
      setState(() {
        firstName = firstNameController.text.trim();
        lastName = lastNameController.text.trim();
        email = emailController.text.trim();
        mobile = mobileController.text.trim();
        country = countryController.text.trim();
        address = addressController.text.trim();
      });
      Get.snackbar("Success", "Profile updated successfully!",
          backgroundColor: Colors.green, colorText: Colors.white);
    }
    setState(() => _isEditing = !_isEditing);
  }

  void _cancelEdit() {
    firstNameController.text = firstName;
    lastNameController.text = lastName;
    emailController.text = email;
    mobileController.text = mobile;
    countryController.text = country;
    addressController.text = address;
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool showBackButton = Get.routing.previous != '/';

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
        title: Text(
          _isEditing ? "Edit Profile" : "Profile",
          style: mulishSemiBold.copyWith(color: Colors.white, fontSize: 18),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: _toggleEditMode,
              icon: const Icon(Icons.edit, color: Colors.white),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Picture
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white24,
                  child: ClipOval(
                    child: Image.asset(
                      MyImages.profile,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.person,
                          size: 60, color: Colors.white60),
                    ),
                  ),
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () => Get.snackbar(
                          "Camera", "Profile picture change coming soon!"),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: MyColor.primaryColor,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: MyColor.colorBlack, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),
            Text(
              "Username: skykarki_fbtwl",
              style: mulishSemiBold.copyWith(color: Colors.white, fontSize: 18),
            ),

            const SizedBox(height: 30),

            // Editable Fields
            _buildEditableField("First Name", firstNameController),
            _buildEditableField("Last Name", lastNameController),
            _buildEditableField("Email Address", emailController),
            _buildEditableField("Mobile Number", mobileController),
            _buildEditableField("Country", countryController),
            _buildEditableField("Address", addressController),

            const SizedBox(height: 40),

            // Action Buttons
            if (_isEditing)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _toggleEditMode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColor.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Save Changes",
                          style: mulishSemiBold.copyWith(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancelEdit,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white24, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Cancel",
                          style:
                              mulishSemiBold.copyWith(color: Colors.white70)),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _toggleEditMode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColor.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Edit Profile",
                          style: mulishSemiBold.copyWith(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.to(() =>
                            const ChangePasswordScreen()); // THIS WORKS PERFECTLY
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: MyColor.primaryColor, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Change Password",
                          style: mulishSemiBold.copyWith(
                              color: MyColor.primaryColor)),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
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
            enabled: _isEditing,
            style: mulishSemiBold.copyWith(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              filled: true,
              fillColor: _isEditing
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
