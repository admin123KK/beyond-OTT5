// lib/view/screens/settings/active_device_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';

class ActiveDeviceScreen extends StatelessWidget {
  const ActiveDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.colorBlack,
      appBar: const CustomAppBar(
        title: "Manage Session",
        bgColor: Colors.transparent,
        isShowBackBtn: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Text
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 12),
            child: Text(
              "Active Login Sessions",
              style: mulishSemiBold.copyWith(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
          ),

          // Active Device Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  // Device Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: MyColor.primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.phone_android,
                      color: MyColor.primaryColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Device Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "AC2001",
                          style: mulishSemiBold.copyWith(
                            color: Colors.white,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "android",
                          style: mulishMedium.copyWith(
                            color: Colors.white60,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Thu, Nov 27, 2025 10:32",
                          style: mulishMedium.copyWith(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Active Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green, width: 1),
                    ),
                    child: Text(
                      "Active",
                      style: mulishSemiBold.copyWith(
                        color: Colors.green,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Clear All Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Get.defaultDialog(
                    backgroundColor: MyColor.colorBlack.withOpacity(0.95),
                    title: "Clear All Sessions?",
                    titleStyle:
                        mulishBold.copyWith(color: Colors.white, fontSize: 18),
                    middleText:
                        "This will log out all devices except this one.",
                    middleTextStyle: const TextStyle(color: Colors.white70),
                    radius: 16,
                    confirmTextColor: Colors.white,
                    cancelTextColor: MyColor.primaryColor,
                    buttonColor: MyColor.primaryColor,
                    textConfirm: "Clear All",
                    textCancel: "Cancel",
                    onConfirm: () {
                      Get.back();
                      Get.snackbar(
                        "Sessions Cleared",
                        "All other devices have been logged out",
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    },
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: MyColor.primaryColor, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Clear All",
                  style: mulishSemiBold.copyWith(
                    color: MyColor.primaryColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
