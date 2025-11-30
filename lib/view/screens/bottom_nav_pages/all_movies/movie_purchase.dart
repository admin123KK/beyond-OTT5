// view/screen/movie_purchase_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/components/buttons/rounded_button.dart';

class MoviePurchaseScreen extends StatefulWidget {
  const MoviePurchaseScreen({super.key});

  @override
  State<MoviePurchaseScreen> createState() => _MoviePurchaseScreenState();
}

class _MoviePurchaseScreenState extends State<MoviePurchaseScreen> {
  int selectedPaymentMethod = 0; // 0 = PlayLab Wallet, 1 = Payment Gateways
  final double walletBalance = 0.0; // Replace with real API later

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final String movieTitle = args?['title'] ?? "Unknown Movie";
    final String movieImage = args?['coverImage'] ?? "";
    final double moviePrice = (args?['price'] ?? 325.0).toDouble();

    return Scaffold(
      backgroundColor: MyColor.colorBlack,
      appBar: AppBar(
        backgroundColor: MyColor.colorBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text("Movie Purchase",
            style: mulishSemiBold.copyWith(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Movie Info Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: MyColor.primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    movieImage,
                    width: 90,
                    height: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 90,
                      height: 130,
                      color: Colors.grey[800],
                      child: const Icon(Icons.movie,
                          size: 40, color: Colors.white54),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(movieTitle,
                          style: mulishBold.copyWith(
                              fontSize: 19, color: Colors.white),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 10),
                      Text("Duration (Valid After Purchase)",
                          style: mulishRegular.copyWith(
                              color: Colors.white60, fontSize: 13)),
                      Text("24 hour",
                          style: mulishSemiBold.copyWith(
                              color: MyColor.primaryColor, fontSize: 15)),
                      const SizedBox(height: 10),
                      Text("Total Price",
                          style: mulishRegular.copyWith(
                              color: Colors.white60, fontSize: 13)),
                      Text("NRS. ${moviePrice.toInt()}",
                          style: mulishBold.copyWith(
                              color: Colors.white, fontSize: 18)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Wallet Balance
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined,
                        color: Colors.white70, size: 22),
                    const SizedBox(width: 8),
                    Text("E-Wallet Balance",
                        style: mulishRegular.copyWith(color: Colors.white70)),
                  ],
                ),
                Text("NRS. ${walletBalance.toStringAsFixed(1)}/-",
                    style: mulishBold.copyWith(
                        color: MyColor.primaryColor, fontSize: 18)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Payment Method Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Payment method",
                  style: mulishSemiBold.copyWith(
                      color: Colors.white, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),

          // PlayLab Wallet
          _buildPaymentOption(
            title: "PlayLab Wallet",
            isSelected: selectedPaymentMethod == 0,
            onTap: () => setState(() => selectedPaymentMethod = 0),
          ),

          const SizedBox(height: 12),

          // Payment Gateways
          _buildPaymentOption(
            title: "Payment Gateways",
            isSelected: selectedPaymentMethod == 1,
            onTap: () => setState(() => selectedPaymentMethod = 1),
          ),

          // PPV Disclaimer - BELOW PAYMENT GATEWAYS (as you asked)
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF2D1B1B),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.orange.shade700.withOpacity(0.6)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange.shade400, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("PPV DISCLAIMER",
                            style: mulishBold.copyWith(
                                color: Colors.orange.shade400, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text("Once purchased, money will not be refunded.",
                            style: mulishRegular.copyWith(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF111118),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                RoundedButton(
                  text: "Continue to Payment",
                  press: () => _handleContinuePayment(movieTitle, moviePrice),
                  color: MyColor.primaryColor,
                  textColor: Colors.white,
                  // padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Center(
                    child: Text("Cancel",
                        style: mulishSemiBold.copyWith(
                            color: Colors.white70, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleContinuePayment(String title, double price) {
    if (selectedPaymentMethod == 0) {
      // PlayLab Wallet Selected
      if (walletBalance >= price) {
        _showSuccessDialog(title, price);
      } else {
        Get.dialog(
          AlertDialog(
            backgroundColor: const Color(0xFF1E1E2A),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text("Insufficient Balance",
                style: mulishBold.copyWith(color: Colors.white)),
            content: Text(
              "Your PlayLab Wallet balance is low. Please recharge your wallet to continue.",
              style: mulishRegular.copyWith(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text("Cancel",
                    style: const TextStyle(color: Colors.white60)),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.toNamed(RouteHelper
                      .walletTopUpScreen); // Real Wallet Top-Up Screen
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: MyColor.primaryColor),
                child: const Text("Recharge Now"),
              ),
            ],
          ),
        );
      }
    } else {
      // Payment Gateways Selected → Go to real PaymentMethodScreen
      Get.toNamed(RouteHelper.paymentMethodScreen, arguments: {
        'amount': price,
        'movieTitle': title,
        'fromMoviePurchase': true,
      });
    }
  }

  void _showSuccessDialog(String title, double price) {
    Get.dialog(
      Dialog(
        backgroundColor: MyColor.colorBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.2)),
                child: const Icon(Icons.check, size: 60, color: Colors.green),
              ),
              const SizedBox(height: 24),
              Text("Payment Successful!",
                  style:
                      mulishBold.copyWith(fontSize: 24, color: Colors.white)),
              const SizedBox(height: 12),
              Text("You've successfully subscribed to",
                  style: mulishRegular.copyWith(
                      color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 8),
              Text(title,
                  style: mulishBold.copyWith(
                      fontSize: 20, color: MyColor.primaryColor),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text("रु${price.toInt()}",
                  style: mulishBold.copyWith(
                      fontSize: 36, color: MyColor.primaryColor)),
              const SizedBox(height: 30),
              RoundedButton(
                text: "Done",
                press: () {
                  Get.back();
                  Get.back(); // Back to movie details or home
                },
                color: MyColor.primaryColor,
                textColor: Colors.white,
                width: 200,
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? MyColor.primaryColor.withOpacity(0.15)
              : const Color(0xFF1E1E2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? MyColor.primaryColor : Colors.transparent,
              width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white70, width: 2),
                color: isSelected ? MyColor.primaryColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Text(title,
                style: mulishSemiBold.copyWith(
                    color: isSelected ? MyColor.primaryColor : Colors.white,
                    fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
