// lib/view/screens/live_tv/all_live_tv_screen.dart

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';
import 'package:play_lab/view/screens/live_tv_details/image_helper.dart';

class AllLiveTvScreen extends StatefulWidget {
  const AllLiveTvScreen({super.key});

  @override
  State<AllLiveTvScreen> createState() => _AllLiveTvScreenState();
}

class _AllLiveTvScreenState extends State<AllLiveTvScreen> {
  List<dynamic> channels = [];
  bool isLoading = true;

  // Update based on user subscription
  final List<int> subscribedChannelIds = [1, 2]; // Kantipur & Test

  @override
  void initState() {
    super.initState();
    fetchChannels();
  }

  Future<void> fetchChannels() async {
    try {
      setState(() => isLoading = true);
      final res = await http.get(
        Uri.parse("https://ott.beyondtechnepal.com/api/live-television/all"),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        setState(() {
          channels = json['data']['televisions']['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _showSubscribeDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_open, color: Colors.pinkAccent, size: 70),
              const SizedBox(height: 20),
              const Text("Unlock Premium Channels",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text("Subscribe to watch all premium live TV channels",
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed(RouteHelper.subscribeScreen);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColor.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Subscribe Now",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final premiumChannels =
        channels.where((c) => subscribedChannelIds.contains(c['id'])).toList();
    final sportsChannels =
        channels.where((c) => !subscribedChannelIds.contains(c['id'])).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(title: MyStrings.allTV),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: MyColor.primaryColor))
          : RefreshIndicator(
              onRefresh: fetchChannels,
              color: MyColor.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Premium Channels
                    if (premiumChannels.isNotEmpty)
                      _buildSection(
                        title: "Premium Channels",
                        badgeText: "Subscribed",
                        badgeColor: const Color(0xFF9C27B0), // Purple
                        channels: premiumChannels,
                        isSubscribed: true,
                      ),

                    const SizedBox(height: 24),

                    // Sports Pack
                    if (sportsChannels.isNotEmpty)
                      _buildSection(
                        title: "Sports Pack Channels",
                        badgeText: "Subscribe Now",
                        badgeColor: const Color(0xFFE91E63), // Pink
                        channels: sportsChannels,
                        isSubscribed: false,
                      ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSection({
    required String title,
    required String badgeText,
    required Color badgeColor,
    required List<dynamic> channels,
    required bool isSubscribed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: badgeColor, borderRadius: BorderRadius.circular(30)),
                child: Text(badgeText,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: channels.length,
            itemBuilder: (ctx, i) {
              final ch = channels[i];
              final String name = ch['title'] ?? "Channel";
              final bool isKantipur = name.toLowerCase().contains("kanti");

              return GestureDetector(
                onTap: () => isSubscribed
                    ? Get.toNamed(RouteHelper.liveTvDetailsScreen,
                        arguments: ch['id'])
                    : _showSubscribeDialog(),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4)),
                      ]),
                  padding: const EdgeInsets.all(9),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Channel Logo
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: ImageUrlHelper.tv(ch['image']),
                              height: 80,
                              width: 80,
                              fit: BoxFit.contain,
                              placeholder: (_, __) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.live_tv, size: 40)),
                              errorWidget: (_, __, ___) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.live_tv, size: 40)),
                            ),
                          ),
                          // const SizedBox(height: 12),
                          // Text(
                          //   name,
                          //   style: TextStyle(
                          //     color: isKantipur
                          //         ? const Color(0xFF00A0E3)
                          //         : Colors.black87,
                          //     fontSize: 13,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          //   textAlign: TextAlign.center,
                          //   maxLines: 2,
                          //   overflow: TextOverflow.ellipsis,
                          // ),
                        ],
                      ),

                      // HD Badge
                      if (name.toLowerCase().contains("kanti") ||
                          name.toLowerCase().contains("test"))
                        Positioned(
                          top: 0,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text("HD",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),

                      // Lock Icon for unsubscribed
                      if (!isSubscribed)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                                color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.lock,
                                color: Colors.white, size: 18),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
