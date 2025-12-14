import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/api.dart';
import 'package:play_lab/core/utils/my_color.dart';
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
  String baseUrl = ApiConstants.baseUrl;
  String trailerVideoUrl = "";
  bool isTrailerLoading = true;
  String trailerError = "";
  bool showMore = false;

  late String heroTag;
  late String heroImageUrl;

  bool isInWishlist = false; // Track wishlist status
  bool isAddingToWishlist = false; // Loading state for button

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
            pathData['portrait_path'] ?? pathData['portrait'] ?? '',
            pathData['landscape_path'] ?? pathData['landscape'] ?? '',
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
                : "$baseUrl/$videoPath".replaceAll('//', '/');
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

  // ADD TO WISHLIST FUNCTION
  Future<void> _addToWishlist() async {
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
      Get.snackbar("Login Required", "Please login to add to wishlist",
          backgroundColor: Colors.red, colorText: Colors.white);
      setState(() => isAddingToWishlist = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConstants
            .addWatchListEndpoint), // Make sure this is defined in api.dart
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "item_id": itemId,
          "episode_id": null,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
        setState(() => isInWishlist = true);
        Get.snackbar(
          "Success!",
          jsonResponse['message']?['success']?[0] ?? "Added to Watch Later",
          backgroundColor: MyColor.primaryColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
            "Failed",
            jsonResponse['message']?['error']?[0] ??
                "Could not add to wishlist",
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Network error. Try again.",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => isAddingToWishlist = false);
    }
  }

  String get title => movie?['title'] ?? "Movie Title";
  String get preview => movie?['preview_text'] ?? "";
  String get desc => movie?['description'] ?? "No description.";
  String get genre => movie?['team']?['genres'] ?? "N/A";
  String get director => movie?['team']?['director'] ?? "N/A";
  String get producer => movie?['team']?['producer'] ?? "N/A";
  String get casts => movie?['team']?['casts'] ?? "N/A";
  String get rentPrice => movie?['rent_price'] ?? "0.0";
  bool get isFree => movie?['exclude_plan'] == 1;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: CircularProgressIndicator(color: MyColor.primaryColor)),
      );
    }

    if (movie == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: Text("Movie not found",
                style: TextStyle(color: Colors.white, fontSize: 24))),
      );
    }

    final double backdropHeight = MediaQuery.of(context).size.height * 0.50;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Hero(
            tag: heroTag,
            transitionOnUserGestures: true,
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
                colors: [Colors.transparent, Colors.black],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: Colors.white, size: 28),
              onPressed: () => Get.back(),
            ),
          ),
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
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(16)),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Cast & Crew",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                _info("Director", director),
                                _info("Producer", producer),
                                _info("Cast", casts),
                              ]),
                        ),
                      ],
                      const SizedBox(height: 35),

                      // WISHLIST + BUY BUTTON ROW
                      Row(
                        children: [
                          // ADD TO WISHLIST BUTTON
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed:
                                  isAddingToWishlist ? null : _addToWishlist,
                              icon: isAddingToWishlist
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : Icon(
                                      isInWishlist
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 24),
                              label: Text(
                                  isInWishlist ? "Added" : "Watch Later",
                                  style: const TextStyle(fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isInWishlist
                                    ? Colors.green
                                    : MyColor.primaryColor.withOpacity(0.8),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // BUY NOW BUTTON
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 60,
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.toNamed('/moviepurchase-screen',
                                      arguments: {
                                        'title': title,
                                        'coverImage': heroImageUrl,
                                        'price':
                                            double.tryParse(rentPrice) ?? 325.0,
                                      });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MyColor.primaryColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                ),
                                child: Text(
                                  isFree
                                      ? "Watch Free"
                                      : "Buy Now @ NRS. ${double.parse(rentPrice).toStringAsFixed(0)}/-",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
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
    if (trailerError.isNotEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 10),
          Text(trailerError, style: const TextStyle(color: Colors.white70)),
        ]),
      );
    }
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
                      Get.to(() => FullScreenTrailer(url: trailerVideoUrl))),
            ),
          ),
        ],
      );
    }
    return const Center(
        child: Text("No trailer available",
            style: TextStyle(color: Colors.white70)));
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.white70, fontSize: 16),
          children: [
            TextSpan(
                text: "$label: ",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

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
    _controller = VideoPlayerController.network(widget.url);
    _controller.initialize().then((_) {
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
