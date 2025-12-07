// all_live_tv_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/my_color.dart';

class AllLiveTvScreen extends StatefulWidget {
  const AllLiveTvScreen({super.key});

  @override
  State<AllLiveTvScreen> createState() => _AllLiveTvScreenState();
}

class _AllLiveTvScreenState extends State<AllLiveTvScreen> {
  List<dynamic> channels = [];
  bool isLoading = true;

  // Only these channels are subscribed (Premium)
  final List<int> subscribedChannelIds = [1, 2]; // Kantipur & Test

  @override
  void initState() {
    super.initState();
    fetchChannels();
  }

  Future<void> fetchChannels() async {
    try {
      final res = await http.get(
        Uri.parse("https://ott.beyondtechnepal.com/api/live-television/all"),
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

  void _showSubscribeDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, color: Colors.pink, size: 60),
              const SizedBox(height: 20),
              const Text(
                "Subscribe Now to Unlock",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Get access to premium sports channels and more!",
                style: TextStyle(color: Colors.white70, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text("Cancel",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.snackbar("Info", "Subscription coming soon!",
                            backgroundColor: MyColor.primaryColor);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColor.primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text("Subscribe Now",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
          ? const Center(
              child: CircularProgressIndicator(color: MyColor.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Premium Channels (Subscribed - No Dialog)
                  _buildPack(
                    title: "Premium Channels",
                    channels: channels,
                    isPremium: true,
                  ),
                  const SizedBox(height: 30),

                  // Sports Pack (Locked - SHOW DIALOG)
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

  Widget _buildPack({
    required String title,
    required List<dynamic> channels,
    required bool isPremium,
  }) {
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

              // Premium Pack: play if subscribed
              // Sports Pack: show dialog if not subscribed
              final bool canPlay = isPremium ? isSubscribed : false;

              return GestureDetector(
                onTap: () {
                  if (canPlay) {
                    Get.toNamed(RouteHelper.liveTvDetailsScreen, arguments: id);
                  } else {
                    _showSubscribeDialog(); // Only for Sports Pack
                  }
                },
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
                            canPlay ? Icons.live_tv : Icons.lock,
                            color: canPlay ? Colors.white70 : Colors.grey,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ch['title'] ?? "Channel",
                            style: TextStyle(
                              color:
                                  canPlay ? Colors.white : Colors.grey.shade600,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ],
                      ),
                      if (!canPlay)
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
