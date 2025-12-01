import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/screens/subscribe_plan/add_deposit_screen/payement_method.dart';

class WalletTopUpScreen extends StatefulWidget {
  const WalletTopUpScreen({super.key});

  @override
  State<WalletTopUpScreen> createState() => _WalletTopUpScreenState();
}

class _WalletTopUpScreenState extends State<WalletTopUpScreen> {
  final TextEditingController amountController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.colorBlack,
      appBar: AppBar(
        backgroundColor: MyColor.colorBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Wallet Top Up",
          style: mulishSemiBold.copyWith(color: Colors.white, fontSize: 18),
        ),
        // centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Username Field
            Text(
              "Username",
              style: mulishMedium.copyWith(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                "skykarki ftw",
                style:
                    mulishSemiBold.copyWith(color: Colors.white, fontSize: 17),
              ),
            ),

            const SizedBox(height: 30),

            // Amount Field
            Text(
              "Amount (NRS.)",
              style: mulishMedium.copyWith(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                hintText: "Enter Amount",
                hintStyle: TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                prefixText: "NRS ",
                prefixStyle:
                    mulishBold.copyWith(color: Colors.white70, fontSize: 18),
              ),
            ),

            const Spacer(),

            // Proceed Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final amount = amountController.text.trim();
                  if (amount.isEmpty ||
                      double.tryParse(amount) == null ||
                      double.parse(amount) <= 0) {
                    Get.snackbar(
                      "Invalid Amount",
                      "Please enter a valid amount",
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  // Navigate to Payment Method Screen
                  Get.to(() => PaymentMethodScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColor.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 12,
                  shadowColor: MyColor.primaryColor.withOpacity(0.5),
                ),
                child: Text(
                  "Proceed",
                  style: mulishBold.copyWith(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
