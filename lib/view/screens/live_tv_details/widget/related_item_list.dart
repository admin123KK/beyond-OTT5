// related_item_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

class RelatedTvList extends StatefulWidget {
  const RelatedTvList({super.key});

  @override
  State<RelatedTvList> createState() => _RelatedTvListState();
}

class _RelatedTvListState extends State<RelatedTvList> {
  // REAL HBO / NETFLIX / PREMIUM MOVIE POSTERS (100% working)
  final List<Map<String, String>> premiumMovies = [
    {
      'title': 'The Party Two',
      'image':
          'https://tse1.mm.bing.net/th/id/OIP.zLnCcemgMmtAEYVExhqLHwHaLH?rs=1&pid=ImgDetMain&o=7&rm=3',
    },
    {
      'title': 'The Batman',
      'image':
          'https://tse2.mm.bing.net/th/id/OIP.dwniYcvPhHgcaFL9wZdX_AHaK2?rs=1&pid=ImgDetMain&o=7&rm=3',
    },
    {
      'title': 'Oppenheimer',
      'image':
          'https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg',
    },
    {
      'title': 'TARZAN',
      'image':
          'https://tse1.mm.bing.net/th/id/OIP.lmbXDi24OT32g7_m8Wta4gHaK1?rs=1&pid=ImgDetMain&o=7&rm=3',
    },
    {
      'title': '14 Peak',
      'image':
          'https://tse2.mm.bing.net/th/id/OIP.8mUZP4mp-aWLxsaZR9JGJQAAAA?w=338&h=474&rs=1&pid=ImgDetMain&o=7&rm=3',
    },
    {
      'title': '360',
      'image':
          'https://tse3.mm.bing.net/th/id/OIP.VhnsjezIsO4nIN597b7T0AHaK1?rs=1&pid=ImgDetMain&o=7&rm=3',
    },
    {
      'title': 'Purna Bhadur Sarangi',
      'image':
          'https://tse3.mm.bing.net/th/id/OIP.jg07MfiUF0hFyKPP1QzfIwHaKq?rs=1&pid=ImgDetMain&o=7&rm=3',
    },
    {
      'title': 'Animals',
      'image':
          'https://tse1.mm.bing.net/th/id/OIP.MfYi0uGzTSXVZm05HZtYBgHaKX?rs=1&pid=ImgDetMain&o=7&rm=3',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: AnimationLimiter(
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: premiumMovies.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (context, index) {
            final movie = premiumMovies[index];

            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 800),
              columnCount: 3,
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: GestureDetector(
                    onTap: () {
                      Get.snackbar(
                        "Premium Channel",
                        "${movie['title']} • Coming Soon",
                        backgroundColor: Colors.black87,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Movie Poster
                            Image.network(
                              movie['image']!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.movie,
                                      color: Colors.white70, size: 40),
                                );
                              },
                            ),
                            // Gradient Overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.8),
                                  ],
                                ),
                              ),
                            ),
                            // Title
                            Positioned(
                              bottom: 10,
                              left: 8,
                              right: 8,
                              child: Text(
                                movie['title']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  shadows: [Shadow(blurRadius: 10)],
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // HBO Logo (Optional)
                            if (index < 4)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.purpleAccent.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    "HBO",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
