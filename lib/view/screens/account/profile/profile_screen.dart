import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/data/controller/account/profile_controller.dart';
import 'package:play_lab/data/repo/account/profile_repo.dart';
import 'package:play_lab/data/services/api_service.dart';
import 'package:play_lab/view/screens/bottom_nav_pages/home/home_screen.dart';
import 'body/body.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Safe one-time initialization
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProfileRepo(apiClient: Get.find()));
    Get.put(ProfileController(profileRepo: Get.find()));

    return Scaffold(
      backgroundColor: MyColor.secondaryColor,
      appBar: AppBar(
        title: Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              },
              child: Icon(Icons.arrow_back_ios),
            ),
            const SizedBox(
              width: 10,
            ),
            const Text(
              'Profile',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
      body: GetBuilder<ProfileController>(
        builder: (controller) => const Body(),
      ),
    );
  }
}
