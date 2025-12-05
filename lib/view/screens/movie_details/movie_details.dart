import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/api.dart';
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
  String portraitPath = "";
  String landscapePath = "";
  bool showMore = false;

  // Trailer variables
  String trailerVideoUrl = "";
  bool isTrailerLoading = true;
  String trailerError = "";

  @override
  void initState() {
    super.initState();
    fetchMovieBySlug("final-destination-bloodlines-1905081321l5lpk");
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
          setState(() {
            movie = found;
            portraitPath = json['data']['portrait_path'] ?? "";
            landscapePath = json['data']['landscape_path'] ?? "";
            isLoading = false;
          });

          // Extract trailer path and fetch real video
          final trailerPath = json['data']['trailer']?['path'] ?? "";
          if (trailerPath.isNotEmpty) {
            fetchTrailerVideo(trailerPath);
          } else {
            setState(() {
              trailerError = "No trailer available";
              isTrailerLoading = false;
            });
          }
        } else {
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // Fetch real trailer video from the "path"
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
          if (videoPath.isNotEmpty) {
            setState(() {
              trailerVideoUrl = videoPath.startsWith('http')
                  ? videoPath
                  : "$baseUrl/$videoPath".replaceAll('//', '/');
              isTrailerLoading = false;
            });
          } else {
            setState(() {
              trailerError = "Trailer video not found";
              isTrailerLoading = false;
            });
          }
        } else {
          setState(() {
            trailerError = "No trailer found";
            isTrailerLoading = false;
          });
        }
      } else {
        setState(() {
          trailerError = "Failed to load trailer";
          isTrailerLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        trailerError = "Check internet connection";
        isTrailerLoading = false;
      });
    }
  }

  String get poster => movie?['image']?['landscape'] == null
      ? ""
      : "$baseUrl/$landscapePath${movie!['image']['landscape']}"
          .replaceAll('//', '/');

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
        body: Center(child: CircularProgressIndicator(color: Colors.pink)),
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.58,
            pinned: true,
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  poster.isNotEmpty
                      ? Image.network(poster, fit: BoxFit.cover)
                      : Container(color: Colors.grey[900]),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(30)),
                    child: const Text("New Release",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),

                  Text("Released in 2025 • $genre",
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 16),

                  Text(
                    preview.isNotEmpty ? preview : desc,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 17, height: 1.5),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () => setState(() => showMore = !showMore),
                    child: Row(
                      children: [
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
                      ],
                    ),
                  ),

                  if (showMore) ...[
                    const SizedBox(height: 24),
                    Text(desc,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 16, height: 1.6)),
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
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.toNamed('/moviepurchase-screen', arguments: {
                          'title': title,
                          'coverImage': poster,
                          'price': double.tryParse(rentPrice) ?? 325.0,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        isFree
                            ? "Watch Free"
                            : "Buy Now @ NRS. ${double.parse(rentPrice).toStringAsFixed(0)}/- (24 hour)",
                        style: const TextStyle(
                            fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  const Text("Movie Official Trailer",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 16),

                  // REAL TRAILER VIDEO PLAYER
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[900]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildTrailerWidget(),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailerWidget() {
    if (isTrailerLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.pink),
      );
    }

    if (trailerError.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 10),
            Text(trailerError, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    if (trailerVideoUrl.isNotEmpty) {
      return Stack(
        children: [
          Image.network(poster, fit: BoxFit.cover, width: double.infinity),
          const Center(
            child:
                Icon(Icons.play_circle_fill, size: 80, color: Colors.white70),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Get.to(() => FullScreenTrailer(url: trailerVideoUrl));
                },
              ),
            ),
          ),
        ],
      );
    }

    return const Center(
      child: Text("No trailer availableee",
          style: TextStyle(color: Colors.white70)),
    );
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

// Fullscreen trailer page
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
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(color: Colors.pink),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        child:
            Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
      ),
    );
  }
}
