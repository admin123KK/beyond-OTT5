// File: lib/view/components/my_google_pay_button.dart  (or wherever it was)

import 'package:flutter/material.dart';

/// This widget is temporarily disabled because Google Pay is not active.
/// It shows nothing so the layout doesn't break.
class MyGooglePayButton extends StatelessWidget {
  const MyGooglePayButton({
    super.key,
    required this.price,
    required this.planName,
  });

  final String price;
  final String planName;

  @override
  Widget build(BuildContext context) {
    // Returns empty space - completely invisible and takes no space
    return const SizedBox.shrink();

    // Or if you want to show a message while developing:
    // return const Padding(
    //   padding: EdgeInsets.only(top: 15),
    //   child: Text(
    //     'Google Pay temporarily disabled',
    //     style: TextStyle(color: Colors.grey, fontSize: 12),
    //   ),
    // );
  }
}
