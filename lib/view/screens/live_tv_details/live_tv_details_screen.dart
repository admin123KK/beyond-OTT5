import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/view/screens/live_tv_details/image_helper.dart';
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
  String posterUrl = "";
  bool isLoading = true;
  bool isBuffering = false;

  List<dynamic> allChannels = [];
  int currentChannelId = -1;

  @override
  void initState() {
    super.initState();
    final int channelId = Get.arguments as int? ?? 1;
    currentChannelId = channelId;
    fetchAllChannelsAndPlay(channelId);
  }

  Future<void> fetchAllChannelsAndPlay(int id) async {
    try {
      setState(() => isLoading = true);

      final res = await http.get(
        Uri.parse("https://ott.beyondtechnepal.com/api/live-television/all"),
        headers: {'Accept': 'application/json'},
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final List<dynamic> channels = json['data']['televisions']['data'];

        setState(() => allChannels = channels);

        final channel = channels.firstWhere(
          (c) => c['id'] == id,
          orElse: () => channels.isNotEmpty ? channels[0] : null,
        );

        if (channel != null) {
          updateChannelData(channel);
          _playStream(channel['url'] ?? "");
        } else {
          setState(() {
            description = "Channel not found";
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        description = "No internet connection";
      });
    }
  }

  void updateChannelData(dynamic channel) {
    setState(() {
      currentChannelId = channel['id'];
      title = channel['title']?.toString() ?? "Live TV";
      description = channel['description']?.toString() ?? "Live streaming now";

      // Uses the same dynamic base URL as HomeScreen
      posterUrl = ImageUrlHelper.tv(channel['image']);

      isLoading = false;
    });
  }

  void _playStream(String url) {
    if (url.isEmpty) {
      setState(() => description = "Stream URL not available");
      return;
    }

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
        looping: false,
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

      _videoController!.addListener(() {
        final buffering = _videoController!.value.isBuffering;
        if (buffering != isBuffering) {
          setState(() => isBuffering = buffering);
        }
      });

      setState(() {});
    }).catchError((e) {
      setState(() => description = "Failed to load stream");
    });
  }

  void switchChannel(dynamic channel) {
    if (channel['id'] == currentChannelId) return;
    updateChannelData(channel);
    _playStream(channel['url'] ?? "");
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: MyColor.secondaryColor,
      body: Column(
        children: [
          // VIDEO PLAYER + POSTER BACKGROUND
          Stack(
            children: [
              // Poster Background (Blurred behind video)
              if (posterUrl.isNotEmpty)
                Container(
                  height: size.height * 0.42,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: posterUrl,
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.6),
                    colorBlendMode: BlendMode.dstATop,
                  ),
                ),

              // Video Player
              Container(
                height: size.height * 0.42,
                width: double.infinity,
                color: Colors.black,
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: MyColor.primaryColor))
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
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.live_tv,
                                    size: 80, color: Colors.white54),
                                const SizedBox(height: 16),
                                Text(
                                  description,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 16),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
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
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ),

              // LIVE Badge
              Positioned(
                top: 70,
                left: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: MyColor.primaryColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    "LIVE",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ),
              ),
            ],
          ),

          // Channel Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),

          const Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Row(
              children: [
                Text(
                  'Channel Description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  description,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14, height: 1.5),
                ),
              ),
            ],
          ),

          const Divider(height: 1, color: MyColor.bodyTextColor),

          // More Channels List
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "More Channels",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 110,
                  child: allChannels.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: MyColor.primaryColor))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: allChannels.length,
                          itemBuilder: (context, index) {
                            final channel = allChannels[index];
                            final isActive = channel['id'] == currentChannelId;

                            return GestureDetector(
                              onTap: () => switchChannel(channel),
                              child: Container(
                                width: 90,
                                margin: const EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isActive
                                        ? MyColor.primaryColor
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: isActive
                                      ? [
                                          BoxShadow(
                                            color: MyColor.primaryColor
                                                .withOpacity(0.4),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          )
                                        ]
                                      : null,
                                ),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(11),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            ImageUrlHelper.tv(channel['image']),
                                        height: 80,
                                        width: 84,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => Container(
                                          color: Colors.grey[800],
                                          child: const Icon(Icons.live_tv,
                                              color: Colors.white38, size: 30),
                                        ),
                                        errorWidget: (_, __, ___) => Container(
                                          color: Colors.grey[800],
                                          child: const Icon(Icons.live_tv,
                                              color: Colors.white54),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: Text(
                                        channel['title'] ?? "Channel",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.5),
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
