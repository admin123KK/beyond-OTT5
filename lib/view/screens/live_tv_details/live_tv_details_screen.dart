// live_tv_details_screen.dart
import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/core/utils/my_color.dart';
import 'package:video_player/video_player.dart';

class LiveTvDetailsScreen extends StatefulWidget {
  const LiveTvDetailsScreen({super.key});

  @override
  State<LiveTvDetailsScreen> createState() => _LiveTvDetailsScreenState();
}

class _LiveTvDetailsScreenState extends State<LiveTvDetailsScreen> {
  ChewieController? _chewieController;
  VideoPlayerController? _videoPlayerController;

  String title = "Loading...";
  String description = "Fetching channel details...";
  String streamUrl = "";
  String posterUrl =
      "https://image.tmdb.org/t/p/w1280/8cdWjvZQUExUUTzyp4t6EDMUB2u.jpg";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final int channelId = Get.arguments as int;
    fetchChannelAndPlay(channelId);
  }

  Future<void> fetchChannelAndPlay(int id) async {
    try {
      final res = await http.get(
        Uri.parse("https://ott.beyondtechnepal.com/api/live-television/all"),
        headers: {'Accept': 'application/json'},
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final channel = (json['data']['televisions']['data'] as List)
            .firstWhere((c) => c['id'] == id, orElse: () => null);

        if (channel != null) {
          setState(() {
            title = channel['title'] ?? "Live Channel";
            description = channel['description'] ?? "No description available.";
            streamUrl = channel['url'] ?? "";
            final img = channel['image'] ?? "";
            posterUrl = img.isNotEmpty
                ? "https://ott.beyondtechnepal.com/assets/images/television/$img"
                : posterUrl;
            isLoading = false;
          });

          if (streamUrl.isNotEmpty) {
            _initializePlayer(streamUrl);
          }
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        description = "Failed to load channel";
      });
    }
  }

  void _initializePlayer(String url) {
    _videoPlayerController = VideoPlayerController.network(url);

    _videoPlayerController!.initialize().then((_) {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: true,
        allowFullScreen: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: MyColor.primaryColor,
          handleColor: MyColor.primaryColor,
          backgroundColor: Colors.grey.shade900,
          bufferedColor: Colors.white24,
        ),
        // Custom Controls with +15 / -15 sec buttons
        cupertinoProgressColors: ChewieProgressColors(
          playedColor: MyColor.primaryColor,
          handleColor: MyColor.primaryColor,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.white30,
        ),
        // Modern way to add custom buttons
      );

      // Add custom overlay buttons on top of player
      _chewieController!.addListener(() {
        if (_chewieController!.isFullScreen) {
          // You can add PiP or other logic here later
        }
      });

      if (mounted) setState(() {});
    }).catchError((e) {
      setState(() {
        isLoading = false;
        description = "Stream failed to load";
      });
    });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.secondaryColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Background + Player
                Stack(
                  children: [
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(posterUrl),
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.9)
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Live Player Box
                    Positioned(
                      top: 50,
                      left: 20,
                      right: 20,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            const BoxShadow(
                                color: Colors.black45,
                                blurRadius: 20,
                                spreadRadius: 5),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: isLoading
                              ? Container(
                                  color: Colors.black87,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                        color: MyColor.primaryColor),
                                  ),
                                )
                              : _chewieController != null
                                  ? Chewie(controller: _chewieController!)
                                  : Container(
                                      color: Colors.black87,
                                      child: const Center(
                                        child: Text(
                                          "Stream Not Available",
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 16),
                                        ),
                                      ),
                                    ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Title + LIVE Badge
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: MyColor.primaryColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              "LIVE",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Channel Description Label
                      const Text(
                        "Channel Description",
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 15, height: 1.5),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: MyColor.bodyTextColor),
                const SizedBox(height: 100),
              ],
            ),
          ),

          // Back Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 16),
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black45, blurRadius: 10)
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
