// all_live_tv_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';
import 'package:play_lab/view/components/buttons/category_button.dart';

class AllLiveTvScreen extends StatefulWidget {
  const AllLiveTvScreen({super.key});

  @override
  State<AllLiveTvScreen> createState() => _AllLiveTvScreenState();
}

class _AllLiveTvScreenState extends State<AllLiveTvScreen> {
  // Fake Live TV Categories
  final List<Map<String, dynamic>> tvCategories = [
    {
      'name': 'Premium Channels',
      'price': '9.99',
      'isSubscribed': true,
      'channels': [
        {
          'title': 'HBO Live',
          'image':
              'https://image.tmdb.org/t/p/w500/2OMB0ynKlyI2OKdFzy91SlJ9dPq.jpg'
        },
        {
          'title': 'Starz HD',
          'image':
              'https://image.tmdb.org/t/p/w500/8zXj8k5vL6wAwrwQ1yW5dX3f2gN.jpg'
        },
        {
          'title': 'Showtime',
          'image':
              'https://image.tmdb.org/t/p/w500/7r3DkknR5x9vF9nS8S3t3y2l.jpg'
        },
        {
          'title': 'Cinemax',
          'image':
              'https://image.tmdb.org/t/p/w500/5n2e7k7vR8s9t0u1v2w3x4y5z.jpg'
        },
      ]
    },
    {
      'name': 'Sports Pack',
      'price': '14.99',
      'isSubscribed': false,
      'channels': [
        {
          'title': 'ESPN Live',
          'image': 'https://image.tmdb.org/t/p/w500/3k3nW1p0v3x5y6z7a8b9c0d.jpg'
        },
        {
          'title': 'Sky Sports',
          'image': 'https://image.tmdb.org/t/p/w500/4m5n6o7p8q9r0s1t2u3v4w.jpg'
        },
        {
          'title': 'BeIN Sports',
          'image': 'https://image.tmdb.org/t/p/w500/5o6p7q8r9s0t1u2v3w4x5y.jpg'
        },
      ]
    },
    {
      'name': 'Kids Zone',
      'price': '4.99',
      'isSubscribed': true,
      'channels': [
        {
          'title': 'Cartoon Network',
          'image': 'https://image.tmdb.org/t/p/w500/6p7q8r9s0t1u2v3w4x5y6z.jpg'
        },
        {
          'title': 'Disney Channel',
          'image': 'https://image.tmdb.org/t/p/w500/7q8r9s0t1u2v3w4x5y6z7a.jpg'
        },
        {
          'title': 'Nickelodeon',
          'image': 'https://image.tmdb.org/t/p/w500/8r9s0t1u2v3w4x5y6z7a8b.jpg'
        },
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.colorBlack,
      appBar: const CustomAppBar(
        title: MyStrings.allTV,
        bgColor: MyColor.colorBlack,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: tvCategories.length,
        itemBuilder: (context, index) {
          final category = tvCategories[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 25),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: MyColor.colorBlack2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: MyColor.borderColor, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${category['name']} Channels",
                      style: mulishBold.copyWith(
                          color: Colors.white, fontSize: 18),
                    ),
                    if (!category['isSubscribed'])
                      CategoryButton(
                        text: "Subscribe Now",
                        press: () {
                          Get.dialog(
                            AlertDialog(
                              backgroundColor: MyColor.colorBlack2,
                              title: Text("Subscribe to ${category['name']}",
                                  style: const TextStyle(color: Colors.white)),
                              content: Text(
                                "Monthly Price: \$${category['price']}\n\nGet access to all premium live channels instantly!",
                                style: const TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text("Cancel",
                                      style: TextStyle(color: Colors.grey)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: MyColor.primaryColor),
                                  onPressed: () {
                                    Get.back();
                                    Get.snackbar("Success",
                                        "Subscribed to ${category['name']}!",
                                        backgroundColor: MyColor.primaryColor);
                                  },
                                  child: const Text("Subscribe"),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: MyColor.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Subscribed",
                          style: mulishSemiBold.copyWith(
                              color: MyColor.primaryColor, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Live TV Grid
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: List.generate(category['channels'].length, (i) {
                    final channel = category['channels'][i];
                    return GestureDetector(
                      onTap: () {
                        if (category['isSubscribed']) {
                          Get.toNamed(RouteHelper.liveTvDetailsScreen);
                        } else {
                          Get.snackbar("Locked",
                              "Please subscribe to watch this channel",
                              backgroundColor: Colors.red);
                        }
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: MyColor.colorBlack,
                          border: Border.all(color: MyColor.borderColor),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                channel['image'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.live_tv,
                                      color: Colors.white70, size: 30),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              channel['title'],
                              style: mulishSemiBold.copyWith(
                                  color: Colors.white, fontSize: 10),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
