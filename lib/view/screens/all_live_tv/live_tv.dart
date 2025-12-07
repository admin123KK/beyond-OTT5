// all_live_tv_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/core/route/route.dart';

class AllLiveTvScreen extends StatefulWidget {
  const AllLiveTvScreen({super.key});

  @override
  State<AllLiveTvScreen> createState() => _AllLiveTvScreenState();
}

class _AllLiveTvScreenState extends State<AllLiveTvScreen> {
  List<dynamic> channels = [];
  bool isLoading = true;

  // CHANGE THIS: Set which channels are subscribed (by ID)
  final List<int> subscribedChannelIds = [
    1,
    2
  ]; // Kantipur & Test are subscribed

  @override
  void initState() {
    super.initState();
    fetchChannels();
  }

  Future<void> fetchChannels() async {
    try {
      final res = await http.get(
        Uri.parse("https://ott.beyondtechnepal.com/api/live-television"),
        headers: {'Accept': 'application/json'},
      );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text("All Live TV", style: TextStyle(color: Colors.white)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Premium Channels Pack
                  _buildPack(
                    title: "Premium Channels",
                    channels: channels,
                    isPremium: true,
                  ),
                  const SizedBox(height: 30),
                  // Sports Pack (example)
                  _buildPack(
                    title: "Sports Pack Channels",
                    channels: channels,
                    isPremium: false,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  Widget _buildPack(
      {required String title,
      required List<dynamic> channels,
      required bool isPremium}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isPremium ? Colors.purple.shade700 : Colors.pink,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  isPremium ? "Subscribed" : "Subscribe Now",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: channels.length,
            itemBuilder: (ctx, i) {
              final ch = channels[i];
              final int id = ch['id'];
              final bool isSubscribed = subscribedChannelIds.contains(id);

              return GestureDetector(
                onTap: isSubscribed
                    ? () {
                        Get.toNamed(RouteHelper.liveTvDetailsScreen,
                            arguments: id);
                      }
                    : null, // Locked
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isSubscribed ? Icons.live_tv : Icons.lock,
                            color: isSubscribed ? Colors.white70 : Colors.grey,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ch['title'] ?? "Channel",
                            style: TextStyle(
                              color: isSubscribed
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ],
                      ),
                      if (!isSubscribed)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
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
