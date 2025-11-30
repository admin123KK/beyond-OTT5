// view/screen/watch_movie_details_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/components/buttons/rounded_button.dart';

// MovieModel class (optional - kept for future use)
class MovieModel {
  final int id;
  final String title;
  final String coverImage;
  final String trailerThumb;
  final String description;
  final double price;
  final String releaseYear;
  final List<String> genres;
  final bool isNewRelease;

  MovieModel({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.trailerThumb,
    required this.description,
    required this.price,
    required this.releaseYear,
    required this.genres,
    this.isNewRelease = false,
  });
}

class WatchMovieDetailsScreen extends StatelessWidget {
  const WatchMovieDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Accept BOTH Map<String, String> and MovieModel safely
    final args = Get.arguments;

    late String title;
    late String coverImage;
    late String year;

    if (args is Map<String, dynamic>) {
      title = args['title'] ?? "Unknown Movie";
      coverImage = args['coverImage'] ?? args['image'] ?? "";
      year = args['year'] ?? "2024";
    } else if (args is MovieModel) {
      title = args.title;
      coverImage = args.coverImage;
      year = args.releaseYear;
    } else {
      title = "Movie Details";
      coverImage = "";
      year = "2024";
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            floating: false,
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
                  coverImage.isNotEmpty
                      ? Image.network(
                          coverImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/placeholder.jpg',
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(color: Colors.grey[900]),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        mulishBold.copyWith(fontSize: 28, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: MyColor.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "New Release",
                      style: mulishSemiBold.copyWith(
                          fontSize: 12, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Released in $year • Action • Thriller",
                    style: mulishRegular.copyWith(
                        color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "A high-stakes action thriller featuring intense battles and breathtaking visuals. Experience the ultimate cinematic journey.",
                    style: mulishRegular.copyWith(
                      fontSize: 15,
                      color: Colors.white70,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 30),
                  RoundedButton(
                    text: "Buy Now @ NRS. 325/- (24 hour)",
                    press: () {
                      Get.toNamed(RouteHelper.moviePurchase);
                    },
                    color: MyColor.primaryColor,
                    textColor: Colors.white,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Movie Official Trailer",
                    style:
                        mulishBold.copyWith(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[800],
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          coverImage.isNotEmpty
                              ? Image.network(coverImage, fit: BoxFit.cover)
                              : const SizedBox(),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.play_arrow,
                                size: 60, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
