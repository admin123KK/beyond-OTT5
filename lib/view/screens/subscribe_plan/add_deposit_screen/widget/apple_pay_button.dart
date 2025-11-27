// File: lib/view/components/my_apple_pay_button.dart  (or wherever it is)

import 'package:flutter/material.dart';

/// Apple Pay is currently disabled in the app.
/// This widget returns nothing to keep the UI clean and prevent build errors.
class MyApplePayButton extends StatelessWidget {
  const MyApplePayButton({
    super.key,
    required this.price,
    required this.planName,
  });

  final String price;
  final String planName;

  @override
  Widget build(BuildContext context) {
    // Completely invisible — takes no space, causes no errors
    return const SizedBox.shrink();

    // Optional: Show a subtle message during development (uncomment if needed)
    /*
    return const Padding(
      padding: EdgeInsets.only(top: 15),
      child: Text(
        'Apple Pay temporarily unavailable',
        style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
        textAlign: TextAlign.center,
      ),
    );
    */
  }
}
