import 'package:esewa_flutter_sdk/esewa_config.dart';
// eSewa Official SDK (make sure it's added as local dependency as explained before)
import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';
import 'package:esewa_flutter_sdk/esewa_payment.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/my_images.dart';
import 'package:play_lab/core/utils/styles.dart';

class PaymentMethodScreen extends StatefulWidget {
  static const String route = '/paymentmethod_screen';

  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  late final String amount;
  String? username; // Optional: if you passed it

  // Test Credentials - Replace with your real ones in production
  static const String CLIENT_ID =
      "JB0BBQ4aD0UqIThFJwAKBgAXEUkEGQUBBAwdOgABHD4DChwUAB0R";
  static const String SECRET_KEY = "BhwIWQQADhIYSxILExMcAgFXFhcOBwAKBgAXEQ==";

  final List<Map<String, dynamic>> methods = const [
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
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is List && args.isNotEmpty) {
      amount = args[0].toString();
      username = args.length > 1 ? args[1].toString() : null;
    } else {
      amount = "0";
    }
  }

  void _initiateEsewaPayment() {
    final String uniqueProductId =
        DateTime.now().millisecondsSinceEpoch.toString();
    final String productName = "Wallet Top Up - $username";

    try {
      EsewaFlutterSdk.initPayment(
        esewaConfig: EsewaConfig(
          environment: Environment.test, // Change to .live in production
          clientId: CLIENT_ID,
          secretId: SECRET_KEY,
        ),
        esewaPayment: EsewaPayment(
          productId: uniqueProductId,
          productName: productName,
          productPrice: amount,
          callbackUrl: '',
        ),
        onPaymentSuccess: (result) {
          debugPrint("eSewa SUCCESS: $result");
          _verifyAndShowSuccess();
        },
        onPaymentFailure: (data) {
          debugPrint("eSewa FAILURE: $data");
          Get.snackbar("Payment Failed", "Transaction was not completed.",
              backgroundColor: Colors.red, colorText: Colors.white);
        },
        onPaymentCancellation: (data) {
          debugPrint("eSewa CANCELLED: $data");
          Get.snackbar("Cancelled", "You cancelled the payment.",
              backgroundColor: Colors.orange, colorText: Colors.white);
        },
      );
    } catch (e) {
      debugPrint("eSewa EXCEPTION: $e");
      Get.snackbar("Error", "Failed to start eSewa payment.");
    }
  }

  // Optional: Verify transaction on your backend or via eSewa API
  void _verifyAndShowSuccess() async {
    // TODO: Call your backend API to credit wallet after successful payment
    // For now, show success UI
    Get.dialog(
      AlertDialog(
        backgroundColor: MyColor.colorBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            Text("Payment Successful!",
                style: mulishBold.copyWith(color: Colors.white, fontSize: 22)),
            const SizedBox(height: 12),
            Text("NRS $amount has been added to your wallet.",
                textAlign: TextAlign.center,
                style:
                    mulishMedium.copyWith(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Get.back(); // Close dialog
                Get.back(); // Go back to previous screen (or home)
                Get.back(); // Optional: go back again if needed
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColor.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Done", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.colorBlack,
      appBar: AppBar(
        backgroundColor: MyColor.colorBlack,
        elevation: 0,
        title: Text(
          "Payment",
          style: mulishSemiBold.copyWith(color: Colors.white, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "CANCEL",
              style: mulishMedium.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Paying For",
                        style: mulishRegular.copyWith(color: Colors.white60)),
                    Text("NRS",
                        style: mulishRegular.copyWith(color: Colors.white60)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("PlayLab Wallet",
                        style: mulishBold.copyWith(
                            color: Colors.white, fontSize: 22)),
                    Text("रू$amount",
                        style: mulishBold.copyWith(
                            color: MyColor.primaryColor, fontSize: 34)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Text(
            "Select an option to continue",
            style: mulishMedium.copyWith(color: Colors.white54, fontSize: 15),
          ),
          const SizedBox(height: 30),

          // Payment Methods List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: methods.length,
              itemBuilder: (context, index) {
                final method = methods[index];
                final bool isEsewa = method['name'] == "eSewa";

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        if (isEsewa) {
                          _initiateEsewaPayment();
                        } else {
                          Get.snackbar(
                            "Coming Soon",
                            "${method['name']} integration is under development.",
                            backgroundColor: MyColor.primaryColor,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 3),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                method['image'],
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Text(
                                      method['name'][0],
                                      style: mulishBold.copyWith(
                                          color: Colors.grey, fontSize: 28),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    method['name'],
                                    style: mulishBold.copyWith(
                                        color: Colors.white, fontSize: 19),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    method['subtitle'],
                                    style: mulishRegular.copyWith(
                                        color: Colors.white60, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                color: Colors.white38, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Cancel Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white38, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                "Cancel",
                style:
                    mulishSemiBold.copyWith(color: Colors.white, fontSize: 17),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
