import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/my_images.dart'; // Your image class
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';

class AddDepositScreen extends StatefulWidget {
  const AddDepositScreen({super.key});

  @override
  State<AddDepositScreen> createState() => _AddDepositScreenState();
}

class _AddDepositScreenState extends State<AddDepositScreen> {
  int selectedIndex = 0;

  final List<Map<String, dynamic>> paymentMethods = [
    {
      "name": "Khalti",
      "subtitle": "Pay via Khalti e-payment",
      "image": MyImages.khaltiImage,
    },
    {
      "name": "eSewa",
      "subtitle": "Pay via eSewa e-payment",
      "image": MyImages.esewaImage,
    },
    {
      "name": "fonepay",
      "subtitle": "Pay via fonepay e-payment",
      "image": MyImages.fonepayImage,
    },
    {
      "name": "Stripe",
      "subtitle": "Pay via Stripe e-payment",
      "image": MyImages.stripeImage,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as List<dynamic>?;
    final String price = args?[0] as String? ?? "रू499";
    final String planName = args?[1] as String? ?? "Pro Plan";

    return Scaffold(
      backgroundColor: MyColor.colorBlack,
      appBar: const CustomAppBar(
        title: MyStrings.paymentMethods,
        bgColor: Colors.transparent,
        isShowBackBtn: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [MyColor.primaryColor500, MyColor.primaryColor],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: MyColor.primaryColor.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("You're subscribing to",
                      style: mulishMedium.copyWith(
                          color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(planName,
                      style: mulishBold.copyWith(
                          color: Colors.white, fontSize: 24)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Amount",
                          style: mulishSemiBold.copyWith(
                              color: Colors.white70, fontSize: 16)),
                      Text(price,
                          style: mulishBold.copyWith(
                              color: Colors.white, fontSize: 32)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Text("Choose Payment Method",
                style:
                    mulishSemiBold.copyWith(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 16),

            // Payment Method Cards (Like Your Image)
            ...List.generate(paymentMethods.length, (index) {
              final method = paymentMethods[index];
              final bool isSelected = selectedIndex == index;

              return GestureDetector(
                onTap: () => setState(() => selectedIndex = index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: MyColor.colorBlack,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? MyColor.primaryColor : Colors.white24,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Logo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          method['image'],
                          width: 52,
                          height: 52,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            width: 52,
                            height: 52,
                            color: Colors.white24,
                            child: Icon(Icons.payment, color: Colors.white60),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Name & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method['name'],
                              style: mulishSemiBold.copyWith(
                                  color: Colors.white, fontSize: 17),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              method['subtitle'],
                              style: mulishRegular.copyWith(
                                  color: Colors.white60, fontSize: 13),
                            ),
                          ],
                        ),
                      ),

                      // Arrow
                      Icon(
                        Icons.arrow_forward_ios,
                        color:
                            isSelected ? MyColor.primaryColor : Colors.white38,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 40),

            // Pay Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showSuccessDialog(context, planName, price);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColor.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 10,
                ),
                child: Text(
                  "Pay $price Now",
                  style: mulishBold.copyWith(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String planName, String price) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: MyColor.colorBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.green, size: 80),
            const SizedBox(height: 20),
            Text("Payment Successful!",
                style: mulishBold.copyWith(color: Colors.white, fontSize: 22)),
            const SizedBox(height: 12),
            Text("You've successfully subscribed to\n$planName",
                textAlign: TextAlign.center,
                style:
                    mulishMedium.copyWith(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 20),
            Text(price,
                style: mulishBold.copyWith(
                    color: MyColor.primaryColor, fontSize: 28)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColor.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text("Done",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
