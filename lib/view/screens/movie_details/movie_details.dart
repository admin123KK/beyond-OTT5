import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/api.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/view/components/buttons/rounded_button.dart';
import 'package:play_lab/view/components/custom_sized_box.dart';

import 'widget/recommended_section/recommended_list_widget.dart';

class MovieDetailsScreen extends StatefulWidget {
  final String slug;

  const MovieDetailsScreen({Key? key, required this.slug}) : super(key: key);

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  bool isLoading = true;
  bool hasError = false;
  Map<String, dynamic>? movie;

  String baseUrl = "https://ott.beyondtechnepal.com";
  late String portraitUrl;
  late String landscapeUrl;

  @override
  void initState() {
    super.initState();
    fetchMovieDetails();
  }

  Future<void> fetchMovieDetails() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.deviceMoviesEndpoint), // ONLY THIS LINE CHANGED
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          final List items = json['data']['movies']['data'];

          final foundMovie = items.firstWhere(
            (item) => item['slug'] == widget.slug,
            orElse: () => null,
          );

          if (foundMovie != null) {
            final path = json['data']['path'];
            portraitUrl = "$baseUrl/${path['portrait']}";
            landscapeUrl = "$baseUrl/${path['landscape']}";

            setState(() {
              movie = foundMovie;
              isLoading = false;
            });
          } else {
            throw Exception("Movie not found");
          }
        }
      } else {
        throw Exception("Server error");
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  bool get isFree => movie?['exclude_plan'] == 1;
  bool get isRent => double.tryParse(movie?['rent_price'] ?? '0')! > 0;
  bool get isPaid => !isFree && !isRent;

  String get landscapeImage {
    final img = movie?['image']?['landscape'] ?? '';
    return img.startsWith('http')
        ? img
        : img.isNotEmpty
            ? "$landscapeUrl$img"
            : "https://via.placeholder.com/800x450/222222/FFFFFF?text=No+Image";
  }

  String get portraitImage {
    final img = movie?['image']?['portrait'] ?? '';
    return img.startsWith('http')
        ? img
        : img.isNotEmpty
            ? "$portraitUrl$img"
            : "https://via.placeholder.com/400x600/222222/FFFFFF?text=No+Image";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.colorBlack,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchMovieDetails,
          color: MyColor.primaryColor,
          child: isLoading
              ? _buildLoading()
              : hasError
                  ? _buildError()
                  : movie == null
                      ? _buildNotFound()
                      : CustomScrollView(
                          physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics()),
                          slivers: [
                            CustomAppBar(
                                title: movie?['title'] ?? "Movie Details"),
                            SliverToBoxAdapter(
                                child: MovieHeader(imageUrl: landscapeImage)),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movie?['title'] ?? "",
                                      style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            size: 16, color: Colors.white70),
                                        const SizedBox(width: 6),
                                        Text(
                                          movie?['created_at']
                                                  ?.substring(0, 4) ??
                                              "2025",
                                          style:
                                              TextStyle(color: Colors.white70),
                                        ),
                                        const SizedBox(width: 16),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isFree
                                                ? Colors.green
                                                : isRent
                                                    ? Colors.orange
                                                    : Colors.purple,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            isFree
                                                ? "FREE"
                                                : isRent
                                                    ? "RENT"
                                                    : "PREMIUM",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      child: RoundedButton(
                                        text: isFree
                                            ? "Watch Free"
                                            : isRent
                                                ? "Rent & Watch"
                                                : "Subscribe to Watch",
                                        press: () {
                                          Get.snackbar("Coming Soon",
                                              "Video player will be added soon!");
                                        },
                                        color: MyColor.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    InfoSection(
                                        title: "Description",
                                        content: movie?['description'] ??
                                            "No description available."),
                                    if (movie?['preview_text'] != null)
                                      InfoSection(
                                          title: "Tagline",
                                          content: movie!['preview_text']),
                                    if (movie?['team'] != null) ...[
                                      const SizedBox(height: 16),
                                      Text("Details",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 8,
                                        children: [
                                          _infoChip(
                                              "Genres",
                                              movie!['team']['genres'] ??
                                                  "N/A"),
                                          _infoChip(
                                              "Language",
                                              movie!['team']['language'] ??
                                                  "N/A"),
                                          _infoChip("Rating",
                                              "${movie!['ratings'] ?? "N/A"}/10"),
                                          _infoChip("Views",
                                              "${movie!['view'] ?? 0}"),
                                        ],
                                      ),
                                    ],
                                    if (movie?['team'] != null &&
                                        (movie!['team']['casts']
                                                    ?.toString()
                                                    .isNotEmpty ==
                                                true ||
                                            movie!['team']['director'] != null))
                                      CastCrewSection(team: movie!['team']),
                                    const CustomSizedBox(height: 20),
                                    const RecommendedListWidget(),
                                    const SizedBox(height: 30),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
        ),
      ),
    );
  }

  Widget _buildLoading() => const Center(
      child: CircularProgressIndicator(color: MyColor.primaryColor));

  Widget _buildError() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            const Text("Failed to load movie",
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: fetchMovieDetails, child: const Text("Retry")),
          ],
        ),
      );

  Widget _buildNotFound() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie, size: 80, color: Colors.white38),
            const SizedBox(height: 16),
            Text("Movie not found", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: () => Get.back(), child: const Text("Go Back")),
          ],
        ),
      );

  Widget _infoChip(String label, String value) => Chip(
        label: Text("$label: $value", style: TextStyle(fontSize: 12)),
        backgroundColor: MyColor.primaryColor.withOpacity(0.2),
        labelStyle: TextStyle(color: Colors.white70),
      );
}

class CustomAppBar extends StatelessWidget {
  final String title;
  const CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: MyColor.colorBlack,
      pinned: true,
      expandedHeight: 60,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(title, style: TextStyle(fontSize: 18)),
        centerTitle: true,
      ),
      leading: IconButton(
          icon: Icon(Icons.arrow_back_ios), onPressed: () => Get.back()),
    );
  }
}

class MovieHeader extends StatelessWidget {
  final String imageUrl;
  const MovieHeader({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        image:
            DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black87, Colors.transparent]),
        ),
      ),
    );
  }
}

class InfoSection extends StatelessWidget {
  final String title;
  final String content;
  const InfoSection({Key? key, required this.title, required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(title,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 8),
        Text(content, style: TextStyle(color: Colors.white70, height: 1.6)),
      ],
    );
  }
}

class CastCrewSection extends StatelessWidget {
  final Map<String, dynamic> team;
  const CastCrewSection({Key? key, required this.team}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text("Cast & Crew",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 12),
        if (team['director'] != null) _crewRow("Director", team['director']),
        if (team['producer'] != null) _crewRow("Producer", team['producer']),
        if (team['casts'] != null) _crewRow("Cast", team['casts']),
      ],
    );
  }

  Widget _crewRow(String role, dynamic value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.white70),
            children: [
              TextSpan(
                  text: "$role: ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              TextSpan(text: value.toString()),
            ],
          ),
        ),
      );
}
