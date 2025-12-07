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
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  String title = "Loading...";
  String description = "Connecting...";
  String streamUrl = "";
  String posterUrl =
      "https://image.tmdb.org/t/p/w1280/8cdWjvZQUExUUTzyp4t6EDMUB2u.jpg";
  bool isLoading = true;
  bool isBuffering = false;

  @override
  void initState() {
    super.initState();
    final int channelId = Get.arguments as int;
    loadAndPlay(channelId);
  }

  Future<void> loadAndPlay(int id) async {
    try {
      final res = await http.get(
        Uri.parse("https://ott.beyondtechnepal.com/api/live-television/all"),
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final channel = (json['data']['televisions']['data'] as List)
            .firstWhere((c) => c['id'] == id, orElse: () => null);

        if (channel != null) {
          setState(() {
            title = channel['title'] ?? "Live TV";
            description = channel['description'] ?? "Live streaming now";
            streamUrl = channel['url'] ?? "";
            final img = channel['image'] ?? "";
            posterUrl = img.isNotEmpty
                ? "https://ott.beyondtechnepal.com/assets/images/television/$img"
                : posterUrl;
            isLoading = false;
          });

          if (streamUrl.isNotEmpty) {
            _playStream(streamUrl);
          }
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        description = "Check internet";
      });
    }
  }

  void _playStream(String url) {
    _videoController?.dispose();
    _chewieController?.dispose();

    _videoController = VideoPlayerController.network(
      url,
      formatHint: VideoFormat.hls,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _videoController!.initialize().then((_) {
      _videoController!.play();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false, // LIVE STREAM = NO LOOPING
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: MyColor.primaryColor,
          handleColor: MyColor.primaryColor,
          backgroundColor: Colors.grey.shade900,
          bufferedColor: Colors.white24,
        ),
      );

      // THIS IS THE MAGIC: Manual control over play/pause
      _videoController!.addListener(() {
        final buffering = _videoController!.value.isBuffering;
        if (buffering != isBuffering) {
          setState(() => isBuffering = buffering);
        }

        // If user pauses and plays again → force restart if needed
        if (!_videoController!.value.isPlaying &&
            _videoController!.value.position > Duration.zero) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted && !_videoController!.value.isPlaying) {
              _videoController!.play();
            }
          });
        }
      });

      setState(() {});
    }).catchError((e) {
      setState(() {
        isLoading = false;
        description = "Stream not available";
      });
    });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
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
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black87],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50,
                      left: 20,
                      right: 20,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black45,
                                blurRadius: 20,
                                spreadRadius: 5)
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: isLoading
                              ? Container(
                                  color: Colors.black87,
                                  child: const Center(
                                      child: CircularProgressIndicator(
                                          color: MyColor.primaryColor)))
                              : _chewieController != null
                                  ? Stack(
                                      children: [
                                        Chewie(controller: _chewieController!),
                                        if (isBuffering)
                                          Container(
                                            color: Colors.black54,
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                  color: MyColor.primaryColor),
                                            ),
                                          ),
                                      ],
                                    )
                                  : Container(
                                      color: Colors.black87,
                                      child: const Center(
                                          child: CircularProgressIndicator(
                                              color: MyColor.primaryColor))),
                        ),
                      ),
                    ),
                  ],
                ),
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
                                borderRadius: BorderRadius.circular(30)),
                            child: const Text("LIVE",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text("Channel Description",
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(description,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              height: 1.5)),
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
                      shape: BoxShape.circle),
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
