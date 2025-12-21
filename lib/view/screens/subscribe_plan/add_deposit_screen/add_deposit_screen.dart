import 'dart:convert';
import 'package:esewa_flutter_sdk/esewa_config.dart';
import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';
import 'package:esewa_flutter_sdk/esewa_payment.dart';
import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/my_images.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';

class AddDepositScreen extends StatefulWidget {
  const AddDepositScreen({super.key});

  @override
  State<AddDepositScreen> createState() => _AddDepositScreenState();
}

class _AddDepositScreenState extends State<AddDepositScreen> {
  int selectedIndex = 0;

  // Test credentials - REPLACE with your real merchant clientId & secretKey in production
  static const String CLIENT_ID =
      "JB0BBQ4aD0UqIThFJwAKBgAXEUkEGQUBBAwdOgABHD4DChwUAB0R";
  static const String SECRET_KEY = "BhwIWQQADhIYSxILExMcAgFXFhcOBwAKBgAXEQ==";

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

    // Extract numeric amount (remove 'रू' and any commas)
    final String amountStr = price.replaceAll(RegExp(r'[^\d.]'), '');

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
            // Plan Summary Card (unchanged)
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

            // Payment Method Cards (unchanged)
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
                  if (selectedIndex == 1) {
                    // eSewa selected (index 1)
                    _initiateEsewaPayment(amountStr, planName);
                  } else {
                    // For other methods, keep old behavior or implement similarly
                    _showSuccessDialog(context, planName, price);
                  }
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

  void _initiateEsewaPayment(String amount, String productName) {
    final String uniqueProductId = DateTime.now()
        .millisecondsSinceEpoch
        .toString(); // Unique transaction UUID

    try {
      EsewaFlutterSdk.initPayment(
        esewaConfig: EsewaConfig(
          environment:
              Environment.test, // Change to Environment.live in production
          clientId: CLIENT_ID,
          secretId: SECRET_KEY,
        ),
        esewaPayment: EsewaPayment(
          productId: uniqueProductId,
          productName: productName,
          productPrice: amount,
          callbackUrl: '',
        ),
        onPaymentSuccess: (EsewaPaymentSuccessResult data) {
          debugPrint(":::eSewa SUCCESS::: => $data");
          verifyTransactionStatus(data, productName, "रू$amount");
          _showSuccessDialog(context, '', '$amount');
        },
        onPaymentFailure: (data) {
          debugPrint(":::eSewa FAILURE::: => $data");
          Get.snackbar(
              "Payment Failed", "Transaction failed. Please try again.");
        },
        onPaymentCancellation: (data) {
          debugPrint(":::eSewa CANCELLATION::: => $data");
          Get.snackbar("Payment Cancelled", "You cancelled the payment.");
        },
      );
    } on Exception catch (e) {
      debugPrint("eSewa EXCEPTION : ${e.toString()}");
      Get.snackbar("Error", "Failed to initiate payment.");
    }
  }

  Future<void> verifyTransactionStatus(
      EsewaPaymentSuccessResult result, String planName, String price) async {
    // Call eSewa transaction status verification API
    final url = Uri.parse(
        'https://rc.esewa.com.np/api/epay/transaction/status/'); // Use production URL in live
    final response = await http.get(url, headers: {
      'product_code': 'EPAYTEST', // Your merchant code (EPAYTEST for test)
      'total_amount': result.totalAmount ?? '',
      'transaction_uuid': result.productId ?? '',
    });

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final status = jsonResponse['transactionDetails']?['status'] ??
          jsonResponse['status'];

      if (status == 'COMPLETE' || status == 'SUCCESS') {
        // Payment verified successfully
        _showSuccessDialog(context, planName, price);
        // TODO: Call your backend to activate subscription
      } else {
        Get.snackbar("Verification Failed", "Transaction not completed.");
      }
    } else {
      Get.snackbar("Verification Error", "Could not verify transaction.");
    }
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
