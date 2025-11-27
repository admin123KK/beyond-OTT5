// home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/my_images.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/components/bottom_Nav/bottom_nav.dart';
import 'package:play_lab/view/components/nav_drawer/custom_nav_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  bool _isSearchVisible = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: MyColor.colorBlack,
      drawer: const NavigationDrawerWidget(),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
      body: SafeArea(
        child: RefreshIndicator(
          color: MyColor.primaryColor,
          backgroundColor: MyColor.cardBg,
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
            Get.snackbar("Refreshed", "Home updated!",
                backgroundColor: MyColor.primaryColor);
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              // App Bar + Search
              SliverAppBar(
                backgroundColor: MyColor.colorBlack,
                elevation: 0,
                pinned: true,
                expandedHeight: _isSearchVisible ? 140 : 100,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(MyImages.logo,
                                height: 55, fit: BoxFit.contain),
                            InkWell(
                              onTap: () => setState(
                                  () => _isSearchVisible = !_isSearchVisible),
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: MyColor.bgColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isSearchVisible
                                      ? Icons.close
                                      : Icons.search_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        if (_isSearchVisible)
                          TextField(
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: MyStrings.search,
                              hintStyle: const TextStyle(color: Colors.white38),
                              filled: true,
                              fillColor: MyColor.textFiledFillColor,
                              prefixIcon: const Icon(Icons.search,
                                  color: Colors.white70),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Main Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Big Banner (Slider Placeholder)
                    Container(
                      height: 180,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: const DecorationImage(
                          image: NetworkImage(
                              'https://fawesome.tv/assets/images/march-horror.webp'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      // child: Center(
                      //   child: Image.network(
                      //     'https://fawesome.tv/assets/images/march-horror.webp',
                      //     fit: BoxFit.cover,
                      //   ),
                      // ),
                    ),
                    const SizedBox(height: 25),

                    // Section: Live TV
                    _buildSectionTitle(
                        MyStrings.liveTV, RouteHelper.allLiveTVScreen),
                    _buildHorizontalList(
                      Colors.redAccent,
                      "Live Channe;l",
                    ),

                    // Section: Movies
                    _buildSectionTitle("Movies", RouteHelper.allMovieScreen),
                    _buildHorizontalList(Colors.blue, "Action Movie"),

                    // Section: Series
                    _buildSectionTitle(
                        MyStrings.latestSeries, RouteHelper.allEpisodeScreen),
                    _buildHorizontalList(Colors.green, "Web Series"),

                    // Section: Free Zone
                    _buildSectionTitle(
                        MyStrings.ourFreeZone, RouteHelper.allFreeZoneScreen),
                    _buildHorizontalList(Colors.purple, "Free Content"),

                    // Featured Item
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text("Featured Item",
                          style: mulishBold.copyWith(
                              color: Colors.white, fontSize: 18)),
                    ),
                    Container(
                      height: 200,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[800],
                      ),
                      child: const Center(
                        child: Icon(Icons.play_circle_fill,
                            size: 80, color: MyColor.primaryColor),
                      ),
                    ),

                    const SizedBox(height: 100), // Extra space for bottom nav
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: mulishBold.copyWith(color: Colors.white, fontSize: 18)),
          GestureDetector(
            onTap: () => Get.toNamed(route),
            child: Text(
              "See All",
              style: mulishSemiBold.copyWith(
                  color: MyColor.primaryColor, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(Color color, String label) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle_outline, size: 50, color: color),
                const SizedBox(height: 10),
                Text(label,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center),
              ],
            ),
          );
        },
      ),
    );
  }
}
