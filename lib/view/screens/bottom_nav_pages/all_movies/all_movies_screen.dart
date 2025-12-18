import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';
import 'package:play_lab/view/components/bottom_Nav/bottom_nav.dart';
import 'package:play_lab/view/components/nav_drawer/custom_nav_drawer.dart';
import 'package:play_lab/view/will_pop_widget.dart';

class AllMovieScreen extends StatefulWidget {
  const AllMovieScreen({super.key});

  @override
  State<AllMovieScreen> createState() => _AllMovieScreenState();
}

class _AllMovieScreenState extends State<AllMovieScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<Color> posterColors = [
    const Color(0xFFE50914), // Netflix Red
    const Color(0xFF8E2DE2), // Purple
    const Color(0xFF4A00E0), // Blue
    const Color(0xFF00D4FF), // Cyan
    const Color(0xFF00C9A7), // Teal
    const Color(0xFFFF6B6B), // Coral
    const Color(0xFFFF8A65), // Orange
    const Color(0xFFFFD93D), // Yellow
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopWidget(
      nextRoute: RouteHelper.homeScreen,
      child: Scaffold(
        backgroundColor: MyColor.colorBlack,
        drawer: const NavigationDrawerWidget(),
        appBar: const CustomAppBar(
          title: MyStrings.allMovies,
          isShowBackBtn: false,
          bgColor: MyColor.colorBlack,
        ),
        bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
        body: RefreshIndicator(
          color: MyColor.primaryColor,
          backgroundColor: MyColor.cardBg,
          onRefresh: () async =>
              await Future.delayed(const Duration(seconds: 1)),
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(15),
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              crossAxisSpacing: 14,
              mainAxisSpacing: 18,
            ),
            itemCount: 30,
            itemBuilder: (context, index) {
              final color = posterColors[index % posterColors.length];

              return GestureDetector(
                onTap: () => Get.toNamed(RouteHelper.movieDetailsScreen),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: MyColor.colorBlack2,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gorgeous Gradient Poster with Play Icon
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(14)),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  color,
                                  color.withOpacity(0.8),
                                  color.withOpacity(0.4),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.play_circle_fill,
                                size: 56,
                                color: Colors.white.withOpacity(0.95),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Movie Title + Rating
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Movie Title ${index + 1}",
                              style: mulishSemiBold.copyWith(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  "${7.2 + (index % 20) * 0.1}".substring(0, 3),
                                  style: mulishRegular.copyWith(
                                    color: Colors.amber,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
