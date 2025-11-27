import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';
import 'package:play_lab/view/components/bottom_Nav/bottom_nav.dart';
import 'package:play_lab/view/components/nav_drawer/custom_nav_drawer.dart';
import 'package:play_lab/view/will_pop_widget.dart';

class AllEpisodeScreen extends StatefulWidget {
  const AllEpisodeScreen({super.key});

  @override
  State<AllEpisodeScreen> createState() => _AllEpisodeScreenState();
}

class _AllEpisodeScreenState extends State<AllEpisodeScreen> {
  final ScrollController _scrollController = ScrollController();

  // Beautiful gradient colors for fake posters
  final List<Color> posterColors = [
    const Color(0xFFE91E63), // Pink
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF673AB7), // Deep Purple
    const Color(0xFF3F51B5), // Indigo
    const Color(0xFF2196F3), // Blue
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFF009688), // Teal
    const Color(0xFF4CAF50), // Green
    const Color(0xFF8BC34A), // Light Green
    const Color(0xFFFF9800), // Orange
    const Color(0xFFF44336), // Red
    const Color(0xFF795548), // Brown
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
          title: MyStrings.allSeries,
          isShowBackBtn: false,
          bgColor: MyColor.colorBlack,
        ),
        bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
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
              childAspectRatio: 0.72, // Perfect ratio - no overflow anymore
              crossAxisSpacing: 14,
              mainAxisSpacing: 16,
            ),
            itemCount: 30,
            itemBuilder: (context, index) {
              final color = posterColors[index % posterColors.length];

              return GestureDetector(
                onTap: () {
                  // Navigate to episode details or same screen (as per your flow)
                  Get.toNamed(RouteHelper.allEpisodeScreen);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: MyColor.colorBlack2,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster Section - Takes most space
                      Expanded(
                        flex: 5,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [color, color.withOpacity(0.7)],
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.live_tv_rounded,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Title + Episode Info Section
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Series Title
                            Text(
                              "Series ${index + 1}: The Adventure",
                              style: mulishSemiBold.copyWith(
                                color: Colors.white,
                                fontSize: 11.5,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),

                            // Episode Count Row
                            Row(
                              children: [
                                Icon(
                                  Icons.play_circle_fill,
                                  size: 14,
                                  color: MyColor.primaryColor,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  // Critical: Prevents horizontal overflow
                                  child: Text(
                                    "${12 + (index % 12)} Episodes",
                                    style: mulishRegular.copyWith(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                    overflow: TextOverflow.ellipsis,
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
