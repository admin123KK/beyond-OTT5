// wallet_recharge_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/styles.dart';

class WalletRechargeScreen extends StatelessWidget {
  const WalletRechargeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.colorBlack,
      appBar: AppBar(
        backgroundColor: MyColor.colorBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Wallet Recharge",
          style: mulishSemiBold.copyWith(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Balance Card
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: BoxDecoration(
              color: MyColor.colorBlack.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.wallet,
                  color: Colors.white70,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  "Total Balance",
                  style: mulishMedium.copyWith(
                      color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "NRS. 0.0 /–",
                  style: mulishBold.copyWith(color: Colors.white, fontSize: 36),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () {
                    Get.toNamed(RouteHelper.walletTopUpScreen);
                  },
                  icon:
                      const Icon(Icons.add_circle_outline, color: Colors.white),
                  label: Text(
                    "Top-up Wallet",
                    style: mulishSemiBold.copyWith(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white38),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ],
            ),
          ),

          // Statement Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "My Wallet Statement",
              style: mulishSemiBold.copyWith(color: Colors.white, fontSize: 18),
            ),
          ),
          const SizedBox(height: 30),

          Expanded(
            child: Center(
              child: Text(
                "No wallet transactions.",
                style:
                    mulishRegular.copyWith(color: Colors.white54, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
