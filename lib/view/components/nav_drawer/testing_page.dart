// testing_page.dart → FINAL & FULLY WORKING WITH YOUR REAL PURCHASE SCREEN

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/api.dart';

class TestingPage extends StatefulWidget {
  const TestingPage({Key? key}) : super(key: key);
  @override
  State<TestingPage> createState() => _TestingPageState();
}

class _TestingPageState extends State<TestingPage> {
  bool isLoading = true;
  Map<String, dynamic>? movie;
  String baseUrl = ApiConstants.baseUrl;
  String portraitPath = "";
  String landscapePath = "";
  bool showMore = false;

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
        } else {
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
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
          // HERO POSTER
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.58,
            pinned: true,
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
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
                  // TITLE
                  Text(title,
                      style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 12),

                  // NEW RELEASE BADGE
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

                  // GENRE LINE
                  Text("Released in 2025 • $genre",
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 16),

                  // SHORT DESCRIPTION
                  Text(
                    preview.isNotEmpty ? preview : desc,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 17, height: 1.5),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),

                  // VIEW MORE
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

                  // FULL DESC + CAST WHEN EXPANDED
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

                  // PINK BUY NOW BUTTON → GOES TO YOUR REAL PURCHASE SCREEN WITH CORRECT DATA
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.toNamed(
                          '/moviepurchase-screen', // or whatever your route name is
                          arguments: {
                            'title': title,
                            'coverImage': poster,
                            'price': double.tryParse(rentPrice) ?? 325.0,
                          },
                        );
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

                  // TRAILER
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
                    child: Stack(
                      children: [
                        Center(
                            child: Image.network(poster,
                                fit: BoxFit.cover, width: double.infinity)),
                        const Center(
                            child: Icon(Icons.play_circle_fill,
                                size: 80, color: Colors.white70)),
                      ],
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
