import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/my_images.dart'; // Import your images
import 'package:play_lab/core/utils/styles.dart';

class PaymentMethodScreen extends StatefulWidget {
  static const String route = '/paymentmethod_screen';

  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  late final String amount;

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
    amount = Get.arguments?.toString() ?? "0";
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
                    Text(amount,
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

          // Payment Methods with Real Images
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: methods.length,
              itemBuilder: (context, index) {
                final method = methods[index];

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
                        Get.snackbar(
                          "Selected",
                          "Opening ${method['name']} for NRS $amount",
                          backgroundColor: MyColor.primaryColor,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 3),
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                        // Add real payment gateway here later
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            // Real Logo Image
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

                            // Name & Subtitle
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
