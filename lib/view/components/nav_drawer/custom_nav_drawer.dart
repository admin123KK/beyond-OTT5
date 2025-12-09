// navigation_drawer_widget.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/api.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/my_images.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationDrawerWidget extends StatefulWidget {
  const NavigationDrawerWidget({super.key});

  @override
  State<NavigationDrawerWidget> createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  String firstName = "Guest";
  String lastName = "";
  String userName = "guest@example.com";
  String imageUrl = "";
  String balance = "NRS. 0/-";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getInfoEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final user = json['data']['user'];

        setState(() {
          firstName = user['firstname'] ?? 'User';
          lastName = user['lastname'] ?? '';
          userName = user['username'] ?? 'No username';
          imageUrl = user['image'] != null
              ? "${ApiConstants.baseUrl}/${user['image']}"
              : '';
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Drawer fetch error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: MyColor.primaryColor.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            const Icon(Icons.logout, color: MyColor.primaryColor, size: 28),
            const SizedBox(width: 12),
            Text("Confirm Logout",
                style: mulishBold.copyWith(color: Colors.white, fontSize: 20)),
          ],
        ),
        content: Text(
          "Are you sure you want to logout?",
          style: mulishRegular.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: Text("Cancel",
                  style: mulishSemiBold.copyWith(color: Colors.white70))),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // or remove only token
              Get.offAllNamed(RouteHelper.loginScreen);
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: MyColor.primaryColor),
            child: Text("Logout",
                style: mulishSemiBold.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon, color: Colors.white70, size: 26),
      title: Text(title.tr,
          style: mulishMedium.copyWith(color: Colors.white, fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
      onTap: () {
        Get.back();
        onTap();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      hoverColor: MyColor.primaryColor.withOpacity(0.1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullName = "$firstName $lastName".trim();

    return Drawer(
      backgroundColor: const Color(0xFF1E1E2A),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: const BoxDecoration(color: Color(0xFF1E1E2A)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: MyColor.primaryColor,
                      backgroundImage:
                          imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                      child: imageUrl.isEmpty
                          ? Text(
                              fullName.isNotEmpty
                                  ? fullName[0].toUpperCase()
                                  : "G",
                              style: mulishBold.copyWith(
                                  fontSize: 28, color: Colors.white),
                            )
                          : null,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isLoading
                              ? const SizedBox(
                                  width: 100,
                                  height: 20,
                                  child: LinearProgressIndicator(
                                      color: MyColor.primaryColor),
                                )
                              : Text(
                                  fullName.isEmpty ? "Guest User" : fullName,
                                  style: mulishSemiBold.copyWith(
                                      color: Colors.white, fontSize: 18),
                                  overflow: TextOverflow.ellipsis,
                                ),
                          const SizedBox(height: 4),
                          Text(
                            "#${userName}",
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
                          Text(MyStrings.balance,
                              style: mulishMedium.copyWith(
                                  color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(balance,
                              style: mulishBold.copyWith(
                                  color: Colors.white, fontSize: 20)),
                        ],
                      ),
                      Image.asset(MyImages.walletImage,
                          height: 36, color: Colors.white70),
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
                    onTap: () => Get.toNamed(RouteHelper.profileScreen)),
                _buildDrawerItem(
                    icon: Icons.subscriptions_outlined,
                    title: MyStrings.subscribeNow,
                    onTap: () => Get.toNamed(RouteHelper.subscribeScreen)),
                _buildDrawerItem(
                    icon: Icons.card_giftcard,
                    title: MyStrings.history,
                    onTap: () =>
                        Get.toNamed(RouteHelper.watchPartyHistoryScreen)),
                _buildDrawerItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: MyStrings.walletRecharge,
                    onTap: () => Get.toNamed(RouteHelper.walletRecharge)),
                _buildDrawerItem(
                    icon: Icons.settings_outlined,
                    title: MyStrings.setting,
                    onTap: () => Get.toNamed(RouteHelper.settingScreen)),
                _buildDrawerItem(
                    icon: Icons.support_agent_sharp,
                    title: MyStrings.supportTicket,
                    onTap: () => Get.toNamed(RouteHelper.allTicketScreen)),
                _buildDrawerItem(
                    icon: Icons.privacy_tip_outlined,
                    title: MyStrings.policies,
                    onTap: () => Get.toNamed(RouteHelper.privacyScreen)),
              ],
            ),
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showLogoutDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColor.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(MyStrings.logout,
                    style: mulishSemiBold.copyWith(
                        color: Colors.white, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
