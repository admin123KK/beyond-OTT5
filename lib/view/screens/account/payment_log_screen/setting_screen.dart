import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';
import 'package:play_lab/view/screens/account/payment_log_screen/active_session.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.colorBlack,
      appBar: const CustomAppBar(
        title: "Settings",
        bgColor: Colors.transparent,
        isShowBackBtn: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
        child: Column(
          children: [
            // Security & Sessions – Clickable
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Get.to(() => const SecuritySessionsScreen());
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1F1F),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: MyColor.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.lock_outline_rounded,
                          color: MyColor.primaryColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Security & Sessions",
                              style: mulishSemiBold.copyWith(
                                  color: Colors.white, fontSize: 16.5)),
                          const SizedBox(height: 3),
                          Text("Manage Sessions & Login options",
                              style: mulishMedium.copyWith(
                                  color: Colors.white60, fontSize: 13.5)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: Colors.white54, size: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Security & Sessions Screen
class SecuritySessionsScreen extends StatelessWidget {
  const SecuritySessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.colorBlack,
      appBar: const CustomAppBar(
        title: "Security & Sessions",
        bgColor: Colors.transparent,
        isShowBackBtn: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
        child: Column(
          children: [
            // MANAGE SESSIONS CARD – NOW GOES TO ACTIVE DEVICE SCREEN
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Get.to(() =>
                    const ActiveDeviceScreen()); // Now opens ActiveDeviceScreen
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1F1F),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: MyColor.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.phone_android_outlined,
                          color: MyColor.primaryColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Manage Sessions",
                              style: mulishSemiBold.copyWith(
                                  color: Colors.white, fontSize: 16.5)),
                          const SizedBox(height: 3),
                          Text("Remove sessions for different devices.",
                              style: mulishMedium.copyWith(
                                  color: Colors.white60, fontSize: 13.5)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: Colors.white54, size: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
