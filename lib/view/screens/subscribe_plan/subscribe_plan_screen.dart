import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/styles.dart';

class SubscribePlanScreen extends StatelessWidget {
  const SubscribePlanScreen({super.key});

  final List<Map<String, dynamic>> dummyPlans = const [
    {
      "name": "Basic Plan",
      "duration": "30",
      "price": "रू499",
      "isPopular": false,
      "planId": "1",
      "subId": "101"
    },
    {
      "name": "Pro Plan",
      "duration": "90",
      "price": "रू1299",
      "isPopular": true,
      "planId": "2",
      "subId": "102"
    },
    {
      "name": "Premium Plan",
      "duration": "365",
      "price": "रू3999",
      "isPopular": false,
      "planId": "3",
      "subId": "103"
    },
    {
      "name": "Family Plan",
      "duration": "180",
      "price": "रू2499",
      "isPopular": false,
      "planId": "4",
      "subId": "104"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.secondaryColor,
      appBar: AppBar(
        title: Text(
          MyStrings.subscribePLan,
          style: mulishSemiBold.copyWith(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ListView.builder(
          itemCount: dummyPlans.length,
          itemBuilder: (context, index) {
            final plan = dummyPlans[index];
            final bool isPopular = plan['isPopular'] == true;

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isPopular
                      ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                      : [MyColor.primaryColor500, MyColor.primaryColor],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    // Optional: Show selected plan
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("You selected: ${plan['name']}"),
                        backgroundColor: MyColor.primaryColor,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Popular Badge
                        if (isPopular)
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "MOST POPULAR",
                                style: mulishBold.copyWith(
                                    color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ),

                        const SizedBox(height: 8),

                        // Plan Name
                        Text(
                          plan['name'],
                          style: mulishBold.copyWith(
                              fontSize: 19, color: Colors.white),
                        ),

                        const SizedBox(height: 8),

                        // Duration & Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${plan['duration']} Days",
                              style: mulishMedium.copyWith(
                                  color: Colors.white70, fontSize: 14),
                            ),
                            Text(
                              plan['price'],
                              style: mulishBold.copyWith(
                                  color: Colors.white, fontSize: 26),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Subscribe Now Button → Go to Deposit Screen
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.toNamed(
                                RouteHelper
                                    .depositScreen, // Make sure this route is added in your RouteHelper
                                arguments: [
                                  plan['price'], // Price
                                  plan['name'], // Plan Name
                                  plan['subId'], // Subscription ID (dummy)
                                  plan['planId'], // Plan ID (dummy)
                                ],
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: MyColor.primaryColor,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Subscribe Now",
                              style: mulishSemiBold.copyWith(
                                fontSize: 15,
                                color: MyColor.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
