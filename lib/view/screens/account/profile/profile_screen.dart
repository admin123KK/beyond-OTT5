// profile_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/my_images.dart';
import 'package:play_lab/core/utils/styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if this screen was pushed (from drawer) or is root (main tab)
    final bool showBackButton = Get.routing.previous != '/'; // Very reliable

    return Scaffold(
      backgroundColor: MyColor.colorBlack,
      appBar: AppBar(
        backgroundColor: MyColor.colorBlack,
        elevation: 0,
        automaticallyImplyLeading: false, // We control it manually
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 20),
                onPressed: () => Get.back(),
              )
            : null, // No back button when it's main tab
        title: Text(
          "Profile",
          style: mulishSemiBold.copyWith(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // === Your existing profile UI starts here ===
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
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: MyColor.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: MyColor.colorBlack, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Text(
              "Username : skykarki_fbtwl",
              style: mulishSemiBold.copyWith(color: Colors.white, fontSize: 18),
            ),

            const SizedBox(height: 30),

            _buildProfileField("First Name", "Sky"),
            _buildProfileField("Last Name", "Karki"),
            _buildProfileField("Email Address", "sky@example.com"),
            _buildProfileField("Mobile Number", "+977 9812345678"),
            _buildProfileField("Country", "Nepal"),
            _buildProfileField("Address", "Kathmandu, Nepal"),

            const SizedBox(height: 40),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Get.snackbar("Info", "Edit Profile coming soon!"),
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
                    onPressed: () =>
                        Get.toNamed('/change_password'), // Add route later
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
            // === End of UI ===
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  mulishMedium.copyWith(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(value,
                style:
                    mulishSemiBold.copyWith(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
