import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/api.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';
import 'package:play_lab/view/screens/live_tv_details/image_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class MovieDetailsScreen extends StatefulWidget {
  const MovieDetailsScreen({Key? key}) : super(key: key);

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  bool isLoading = true;
  Map<String, dynamic>? movie;

  // Trailer
  String trailerVideoUrl = "";
  bool isTrailerLoading = true;
  String trailerError = "";

  // Movie Video
  String movieVideoUrl = "";
  bool isFetchingVideo = false;
  String videoError = "";

  late String heroTag;
  late String heroImageUrl;

  // Wishlist
  bool isInWishlist = false;
  bool isAddingToWishlist = false;
  bool isCheckingWishlist = false;

  bool showMore = false;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final String slug =
        args['slug'] ?? Get.arguments as String? ?? "default-slug";
    heroTag = args['heroTag'] ?? 'default_hero_tag';
    heroImageUrl = args['imageUrl'] ?? '';

    fetchMovieBySlug(slug);
  }

  Future<void> fetchMovieBySlug(String slug) async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse(ApiConstants.deviceMoviesEndpoint));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final List movies = json['data']['movies']['data'];
        final found =
            movies.firstWhere((m) => m['slug'] == slug, orElse: () => null);

        if (found != null) {
          setState(() => movie = found);

          final pathData = json['data'];
          ImageUrlHelper.init(
            pathData['portrait_path'] ?? '',
            pathData['landscape_path'] ?? '',
            pathData['television'] ?? '',
          );

          if (heroImageUrl.isEmpty) {
            final imgPath = movie?['image']?['landscape'] ??
                movie?['image']?['portrait'] ??
                '';
            heroImageUrl = imgPath.startsWith('http')
                ? imgPath
                : imgPath.isNotEmpty
                    ? "${ImageUrlHelper.landscape}$imgPath"
                    : "https://via.placeholder.com/800x1200";
          }

          final trailerPath = pathData['trailer']?['path'] ?? "";
          if (trailerPath.isNotEmpty) {
            fetchTrailerVideo(trailerPath);
          } else {
            setState(() {
              trailerError = "No trailer available";
              isTrailerLoading = false;
            });
          }

          // Check wishlist status
          checkWishlistStatus();

          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchTrailerVideo(String pathUrl) async {
    setState(() {
      isTrailerLoading = true;
      trailerError = "";
    });
    try {
      final response = await http.get(Uri.parse(pathUrl));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List trailers = json['data'] ?? [];
        if (trailers.isNotEmpty) {
          final videoPath = trailers[0]['video'] ?? "";
          setState(() {
            trailerVideoUrl = videoPath.startsWith('http')
                ? videoPath
                : "${ApiConstants.baseUrl}/$videoPath".replaceAll('//', '/');
            isTrailerLoading = false;
          });
        } else {
          setState(() {
            trailerError = "No trailer found";
            isTrailerLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        trailerError = "Check internet connection";
        isTrailerLoading = false;
      });
    }
  }

  // CHECK WISHLIST STATUS ON LOAD
  Future<void> checkWishlistStatus() async {
    final int? itemId = movie?['id'];
    if (itemId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('access_token');
    if (token == null || token.isEmpty) return;

    setState(() => isCheckingWishlist = true);

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getWishListEndpoint),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          final List wishlist = json['data'] ?? [];
          final bool exists = wishlist.any((item) => item['item_id'] == itemId);
          setState(() => isInWishlist = exists);
        }
      }
    } catch (e) {
      // Silent fail
    } finally {
      setState(() => isCheckingWishlist = false);
    }
  }

  // TOGGLE WISHLIST
  Future<void> _toggleWishlist() async {
    if (movie == null || isAddingToWishlist) return;

    final int? itemId = movie?['id'];
    if (itemId == null) {
      Get.snackbar("Error", "Movie ID not found",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => isAddingToWishlist = true);

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      setState(() => isAddingToWishlist = false);
      Get.snackbar("Login Required", "Please login to manage Watch Later",
          backgroundColor: Colors.red, colorText: Colors.white);
      Get.toNamed('/login-screen');
      return;
    }

    final String endpoint = isInWishlist
        ? ApiConstants.removeWishListEndpoint // if you have remove endpoint
        : ApiConstants.addWishListEndpoint;

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({"item_id": itemId, "episode_id": null}),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
        setState(() => isInWishlist = !isInWishlist);
        Get.snackbar("Success!",
            isInWishlist ? "Added to Watch Later" : "Removed from Watch Later",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else if (response.statusCode == 401) {
        await prefs.remove('access_token');
        setState(() => isInWishlist = false);
        Get.offAllNamed('/login-screen');
      } else {
        Get.snackbar("Failed",
            jsonResponse['message']?['error']?[0] ?? "Operation failed",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Check internet",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => isAddingToWishlist = false);
    }
  }

  // PLAY MOVIE VIDEO - FROM BIG PLAY BUTTON OR "WATCH FREE"
  Future<void> playMovieVideo() async {
    final int? itemId = movie?['id'];
    if (itemId == null) {
      Get.snackbar("Error", "Movie ID not found",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() {
      isFetchingVideo = true;
      videoError = "";
    });

    final String endpoint = "${ApiConstants.playvideoEndpoint}$itemId";

    // Get token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      setState(() => isFetchingVideo = false);
      Get.snackbar("Login Required", "Please login to watch this movie",
          backgroundColor: Colors.red, colorText: Colors.white);
      Get.toNamed('/login-screen'); // orf your login route
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json['status'] == 'success') {
          final data = json['data'];
          final List videoList = data['video'] ?? [];

          final bool eligible = data['watchEligible'] == true;

          if (!eligible) {
            setState(() => isFetchingVideo = false);
            Get.snackbar("Purchase Required", "Buy this movie to watch",
                backgroundColor: Colors.orange[900], colorText: Colors.white);
            return;
          }

          if (videoList.isEmpty) {
            Get.snackbar("Error", "No video available",
                backgroundColor: Colors.red, colorText: Colors.white);
          } else {
            // Pick highest quality
            videoList
                .sort((a, b) => (b['size'] ?? 0).compareTo(a['size'] ?? 0));
            final String videoUrl = videoList.first['content'];

            // Play the video
            Get.to(() => FullScreenMoviePlayer(videoUrl: videoUrl));
          }
        } else {
          Get.snackbar(
              "Error", json['message']?['error']?[0] ?? "Access denied",
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        Get.snackbar("Session Expired", "Please login again",
            backgroundColor: Colors.red, colorText: Colors.white);
        // Optionally clear token and redirect to login
        await prefs.remove('access_token');
        Get.offAllNamed('/login-screen');
      } else {
        Get.snackbar("Error", "Server error: ${response.statusCode}",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Check your internet connection",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => isFetchingVideo = false);
    }
  }

  String get title => movie?['title'] ?? "Movie Title";
  String get preview => movie?['preview_text'] ?? "";
  String get desc => movie?['description'] ?? "No description.";
  String get genre => movie?['team']?['genres'] ?? "N/A";
  String get rentPrice => movie?['rent_price'] ?? "0.0";
  bool get isFree => movie?['exclude_plan'] == 1;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(
              child: CircularProgressIndicator(color: MyColor.primaryColor)));
    }

    if (movie == null) {
      return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(
              child: Text("Movie not found",
                  style: TextStyle(color: Colors.white, fontSize: 24))));
    }

    final double backdropHeight = MediaQuery.of(context).size.height * 0.50;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Hero(
            tag: heroTag,
            child: CachedNetworkImage(
              imageUrl: heroImageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: backdropHeight + MediaQuery.of(context).padding.top,
              placeholder: (_, __) => Container(color: Colors.grey[900]),
              errorWidget: (_, __, ___) => Container(color: Colors.grey[900]),
            ),
          ),
          Container(
            height: backdropHeight + MediaQuery.of(context).padding.top,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black]),
            ),
          ),

          // BIG PLAY BUTTON ON POSTER
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            height: backdropHeight,
            child: Center(
              child: GestureDetector(
                onTap: playMovieVideo,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.7),
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: isFetchingVideo
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 5)
                        : const Icon(Icons.play_arrow,
                            color: Colors.white, size: 60),
                  ),
                ),
              ),
            ),
          ),

          CustomAppBar(title: ''),

          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: backdropHeight),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                            color: MyColor.primaryColor,
                            borderRadius: BorderRadius.circular(30)),
                        child: const Text("New Release",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 12),
                      Text("Released in 2025 • $genre",
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 16),
                      Text(preview.isNotEmpty ? preview : desc,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 17, height: 1.5),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => setState(() => showMore = !showMore),
                        child: Row(children: [
                          Text(showMore ? "Show Less" : "View More",
                              style: const TextStyle(
                                  color: Colors.pinkAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17)),
                          Icon(
                              showMore
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.pinkAccent),
                        ]),
                      ),
                      if (showMore) ...[
                        const SizedBox(height: 24),
                        Text(desc,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                height: 1.6)),
                      ],
                      const SizedBox(height: 35),

                      // BUTTONS ROW
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed:
                                  isAddingToWishlist || isCheckingWishlist
                                      ? null
                                      : _toggleWishlist,
                              icon: isAddingToWishlist || isCheckingWishlist
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : Icon(
                                      isInWishlist
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isInWishlist
                                          ? Colors.red
                                          : Colors.white),
                              label:
                                  Text(isInWishlist ? "Added" : "Watch Later"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isInWishlist
                                    ? Colors.green
                                    : MyColor.primaryColor.withOpacity(0.8),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 60,
                              child: ElevatedButton(
                                onPressed: isFree
                                    ? playMovieVideo
                                    : () {
                                        Get.toNamed('/moviepurchase-screen',
                                            arguments: {
                                              'title': title,
                                              'coverImage': heroImageUrl,
                                              'price':
                                                  double.tryParse(rentPrice) ??
                                                      325.0,
                                            });
                                      },
                                child: Text(
                                  isFree
                                      ? "Watch Free"
                                      : "Buy Now @ NRS. ${double.parse(rentPrice).toStringAsFixed(0)}/-",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MyColor.primaryColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                      const Text("Movie Official Trailer",
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 16),
                      Container(
                        height: 220,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.grey[900]),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: _buildTrailerWidget()),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailerWidget() {
    if (isTrailerLoading)
      return const Center(
          child: CircularProgressIndicator(color: MyColor.primaryColor));
    if (trailerError.isNotEmpty)
      return Center(
          child: Text(trailerError,
              style: const TextStyle(color: Colors.white70)));
    if (trailerVideoUrl.isNotEmpty) {
      return Stack(
        children: [
          CachedNetworkImage(
              imageUrl: heroImageUrl,
              fit: BoxFit.cover,
              width: double.infinity),
          const Center(
              child: Icon(Icons.play_circle_fill,
                  size: 80, color: Colors.white70)),
          Positioned.fill(
            child: Material(
                color: Colors.transparent,
                child: InkWell(
                    onTap: () =>
                        Get.to(() => FullScreenTrailer(url: trailerVideoUrl)))),
          ),
        ],
      );
    }
    return const Center(
        child: Text("No trailer available",
            style: TextStyle(color: Colors.white70)));
  }
}

// FULL SCREEN MOVIE PLAYER
class FullScreenMoviePlayer extends StatefulWidget {
  final String videoUrl;
  const FullScreenMoviePlayer({Key? key, required this.videoUrl})
      : super(key: key);

  @override
  State<FullScreenMoviePlayer> createState() => _FullScreenMoviePlayerState();
}

class _FullScreenMoviePlayerState extends State<FullScreenMoviePlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      }).catchError((e) {
        Get.snackbar("Error", "Cannot play video",
            backgroundColor: Colors.red, colorText: Colors.white);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller))
            : const CircularProgressIndicator(color: MyColor.primaryColor),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MyColor.primaryColor,
        onPressed: () => setState(() => _controller.value.isPlaying
            ? _controller.pause()
            : _controller.play()),
        child:
            Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
      ),
    );
  }
}

// Trailer Player (unchanged)
class FullScreenTrailer extends StatefulWidget {
  final String url;
  const FullScreenTrailer({Key? key, required this.url}) : super(key: key);

  @override
  State<FullScreenTrailer> createState() => _FullScreenTrailerState();
}

class _FullScreenTrailerState extends State<FullScreenTrailer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller))
            : const CircularProgressIndicator(color: MyColor.primaryColor),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MyColor.primaryColor,
        child:
            Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
        onPressed: () => setState(() => _controller.value.isPlaying
            ? _controller.pause()
            : _controller.play()),
      ),
    );
  }
}
