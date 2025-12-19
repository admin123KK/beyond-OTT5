import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/screens/subscribe_plan/add_deposit_screen/payement_method.dart'; // Assuming this is your PaymentMethodScreen (AddDepositScreen)
import 'package:shared_preferences/shared_preferences.dart'; // Add this package if not already: shared_preferences: ^2.3.2

class WalletTopUpScreen extends StatefulWidget {
  const WalletTopUpScreen({super.key});

  @override
  State<WalletTopUpScreen> createState() => _WalletTopUpScreenState();
}

class _WalletTopUpScreenState extends State<WalletTopUpScreen> {
  final TextEditingController amountController = TextEditingController();

  String username = "Loading..."; // Will be updated after decoding token

  @override
  void initState() {
    super.initState();
    _loadUsernameFromToken();
  }

  Future<void> _loadUsernameFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(
        'token'); // Adjust key if your token is saved under different key (common: 'auth_token', 'bearer_token', etc.)

    if (token == null || token.isEmpty) {
      setState(() => username = "Guest");
      return;
    }

    try {
      final Map<String, dynamic> payload = _parseJwtPayload(token);
      // Common keys for username: 'username', 'name', 'email', 'sub'
      final String? fetchedUsername = payload['username'] ??
          payload['name'] ??
          payload['email'] ??
          payload['sub'] ??
          "Unknown User";

      setState(() => username = fetchedUsername!);
    } catch (e) {
      setState(() => username = "Invalid Token");
    }
  }

  Map<String, dynamic> _parseJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT token');
    }

    String normalizedPayload =
        parts[1].replaceAll('-', '+').replaceAll('_', '/');

    switch (normalizedPayload.length % 4) {
      case 2:
        normalizedPayload += '==';
        break;
      case 3:
        normalizedPayload += '=';
        break;
    }

    final String decoded = utf8.decode(base64Url.decode(normalizedPayload));
    return json.decode(decoded) as Map<String, dynamic>;
  }

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Username Field (now dynamic)
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
                username,
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

                  // Pass amount (and optionally username) to next screen
                  Get.to(() => PaymentMethodScreen(),
                      arguments: [amount, username]);
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
