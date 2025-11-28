import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/helper/shared_pref_helper.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/my_images.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/data/repo/auth/login_repo.dart';
import 'package:play_lab/data/services/api_service.dart';

class NavigationDrawerWidget extends StatelessWidget {
  const NavigationDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = Get.find<ApiClient>();
    final loginRepo = Get.find<LoginRepo>();

    String name = loginRepo.sharedPreferences
            .getString(SharedPreferenceHelper.userFullNameKey) ??
        "Guest User";
    String email = loginRepo.sharedPreferences
            .getString(SharedPreferenceHelper.userEmailKey) ??
        "guest@example.com";
    String imagePath = loginRepo.sharedPreferences
            .getString(SharedPreferenceHelper.userImageKey) ??
        '';
    String balance = "NRS. 0/-"; // You can make this dynamic later

    return Drawer(
      backgroundColor: const Color(0xFF1E1E2A),
      child: Column(
        children: [
          // Header with Profile & Balance
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E2A),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: MyColor.primaryColor,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : "A",
                        style: mulishBold.copyWith(
                            fontSize: 28, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: mulishSemiBold.copyWith(
                                color: Colors.white, fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            email,
                            style: mulishRegular.copyWith(
                                color: Colors.white70, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Balance Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D3A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            MyStrings.balance,
                            style: mulishMedium.copyWith(
                                color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            balance,
                            style: mulishBold.copyWith(
                                color: Colors.white, fontSize: 20),
                          ),
                        ],
                      ),
                      Image.asset(
                        MyImages.walletImage,
                        height: 36,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  title: MyStrings.profile,
                  onTap: () => Get.toNamed(RouteHelper.profileScreen),
                ),
                _buildDrawerItem(
                  icon: Icons.subscriptions_outlined,
                  title: MyStrings.subscribeNow,
                  onTap: () => Get.toNamed(RouteHelper.subscribeScreen),
                ),
                _buildDrawerItem(
                  icon: Icons.card_giftcard,
                  title: "Package",
                  onTap: () => Get.toNamed(RouteHelper.paymentHistoryScreen),
                ),
                _buildDrawerItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: MyStrings.walletRecharge,
                  onTap: () => Get.toNamed(RouteHelper.walletRecharge),
                ),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: MyStrings.profileSetting,
                  onTap: () => Get.toNamed(RouteHelper.profileScreen),
                ),
                _buildDrawerItem(
                  icon: Icons.contact_support_outlined,
                  title: MyStrings.contactUs,
                  onTap: () => Get.toNamed(RouteHelper.allTicketScreen),
                ),
                _buildDrawerItem(
                  icon: Icons.privacy_tip_outlined,
                  title: MyStrings.policies,
                  onTap: () => Get.toNamed(RouteHelper.privacyScreen),
                ),
              ],
            ),
          ),

          // Sign Out Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColor.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  MyStrings.logout,
                  style: mulishSemiBold.copyWith(
                      color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon, color: Colors.white70, size: 26),
      title: Text(
        title.tr,
        style: mulishMedium.copyWith(color: Colors.white, fontSize: 16),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
      onTap: () {
        Get.back(); // Close drawer
        onTap();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      hoverColor: MyColor.primaryColor.withOpacity(0.1),
    );
  }
}
