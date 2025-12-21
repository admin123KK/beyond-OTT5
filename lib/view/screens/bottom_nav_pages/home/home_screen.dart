import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/api.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/my_images.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/components/bottom_Nav/bottom_nav.dart';
import 'package:play_lab/view/components/nav_drawer/custom_nav_drawer.dart';
import 'package:play_lab/view/screens/my_search/search_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  int _currentPage = 0;
  late Timer _autoSlideTimer;
  final PageController _pageController = PageController();

  bool _isLoading = true;
  String? _error;

  List<dynamic> sliders = [];
  List<dynamic> liveChannels = [];
  List<dynamic> recentlyAdded = [];
  List<dynamic> freeZone = [];
  List<dynamic> featured = [];
  String portraitBaseUrl = "";
  String landscapeBaseUrl = "";

  // Tab index for category switching
  int _selectedTabIndex = 2; // Default to "Movies"

  @override
  void initState() {
    super.initState();
    fetchDashboard();

    // Auto slide every 3 seconds (fast)
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (featuredMovies.isEmpty || !_pageController.hasClients) return;
      setState(() {
        _currentPage = (_currentPage + 1) % featuredMovies.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  Future<void> fetchDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await http
          .get(Uri.parse(ApiConstants.deviceDashboardEndpoint), headers: {
        'Accept': 'application/json'
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          final data = json['data']['data'];
          final path = json['data']['path'];
          setState(() {
            sliders = data['sliders'] ?? [];
            liveChannels = data['televisions']?['data'] ?? [];
            recentlyAdded = data['recently_added'] ?? [];
            freeZone = data['free_zone'] ?? [];
            featured = data['featured'] ?? [];
            portraitBaseUrl =
                "https://ott.beyondtechnepal.com/${path['portrait']}";
            landscapeBaseUrl =
                "https://ott.beyondtechnepal.com/${path['landscape']}";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'No internet connection';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get featuredMovies {
    final source =
        featured.isNotEmpty ? featured : recentlyAdded.take(6).toList();
    return source.map((item) {
      final img =
          item['image']?['landscape'] ?? item['image']?['portrait'] ?? '';
      final url = img.isEmpty
          ? "https://via.placeholder.com/800x450/222222/FFFFFF?text=${item['title']?.substring(0, 2).toUpperCase()}"
          : img.startsWith('http')
              ? img
              : "$landscapeBaseUrl$img";
      return {
        "title": item['title'] ?? "Untitled",
        "image": url,
        "slug": item['slug']?.toString() ?? "",
      };
    }).toList();
  }

  @override
  void dispose() {
    _autoSlideTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

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
          onRefresh: fetchDashboard,
          color: MyColor.primaryColor,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: MyColor.primaryColor))
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off,
                              size: 80, color: Colors.white38),
                          const SizedBox(height: 16),
                          Text(_error!,
                              style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 20),
                          ElevatedButton(
                              onPressed: fetchDashboard,
                              child: const Text("Retry")),
                        ],
                      ),
                    )
                  : CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // App Bar
                        SliverAppBar(
                          backgroundColor: MyColor.colorBlack,
                          elevation: 0,
                          pinned: true,
                          floating: true,
                          leading: Builder(
                            builder: (context) => IconButton(
                              icon: const Icon(Icons.menu, color: Colors.white),
                              onPressed: () =>
                                  Scaffold.of(context).openDrawer(),
                            ),
                          ),
                          actions: [
                            IconButton(
                              icon:
                                  const Icon(Icons.search, color: Colors.white),
                              onPressed: () =>
                                  Get.to(() => const SearchScreen()),
                            ),
                          ],
                          title: Image.asset(MyImages.logo,
                              height: 40, fit: BoxFit.contain),
                        ),

                        // Hero Slider with Dots (no title)
                        SliverToBoxAdapter(
                          child: featuredMovies.isEmpty
                              ? const SizedBox(
                                  height: 220,
                                  child: Center(
                                      child: Text("No Featured Content",
                                          style: TextStyle(
                                              color: Colors.white38))))
                              : SizedBox(
                                  height: MediaQuery.of(context).size.width *
                                      0.5625, // 16:9
                                  child: Stack(
                                    children: [
                                      PageView.builder(
                                        controller: _pageController,
                                        onPageChanged: (i) =>
                                            setState(() => _currentPage = i),
                                        itemCount: featuredMovies.length,
                                        itemBuilder: (_, i) {
                                          final movie = featuredMovies[i];
                                          return GestureDetector(
                                            onTap: () => _navigateWithAuthCheck(
                                              RouteHelper.movieDetailsScreen,
                                              args: {
                                                'slug': movie['slug'],
                                                'imageUrl': movie['image'],
                                              },
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl: movie['image'],
                                              fit: BoxFit.cover,
                                              placeholder: (_, __) => Container(
                                                  color: Colors.grey[900]),
                                              errorWidget: (_, __, ___) =>
                                                  Container(
                                                      color: Colors.grey[900]),
                                            ),
                                          );
                                        },
                                      ),
                                      // Circular dots
                                      Positioned(
                                        bottom: 16,
                                        left: 0,
                                        right: 0,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(
                                            featuredMovies.length,
                                            (i) => Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4),
                                              width: _currentPage == i ? 24 : 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: _currentPage == i
                                                    ? MyColor.primaryColor
                                                    : Colors.white54,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),

                        // Tab Bar (Pinned)
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _TabBarDelegate(
                            selectedIndex: _selectedTabIndex,
                            onTabChanged: (index) {
                              setState(() => _selectedTabIndex = index);
                              // You can add logic here to filter content based on tab
                              // For now, we show all categories in "All" and "Movies"
                            },
                          ),
                        ),

                        // Live TV Section (only show if "All" or "Live" is selected)
                        if (_selectedTabIndex == 0 ||
                            _selectedTabIndex == 6) ...[
                          SliverToBoxAdapter(
                            child: _buildSectionHeader(
                                MyStrings.liveTV, RouteHelper.allLiveTVScreen),
                          ),
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                itemCount: liveChannels.length,
                                itemBuilder: (context, i) {
                                  final item = liveChannels[i];
                                  final String title =
                                      item['title'] ?? "Channel";
                                  final String? imagePath = item['image'];

                                  final String imageUrl = imagePath == null ||
                                          imagePath.isEmpty ||
                                          imagePath == 'null'
                                      ? "https://via.placeholder.com/300/1E1E1E/FFFFFF?text=TV"
                                      : imagePath.startsWith('http')
                                          ? imagePath
                                          : "https://ott.beyondtechnepal.com/assets/images/television/$imagePath";

                                  return GestureDetector(
                                    onTap: () => _navigateWithAuthCheck(
                                      RouteHelper.liveTvDetailsScreen,
                                      args: item['id'],
                                    ),
                                    child: Container(
                                      width: 140,
                                      margin: const EdgeInsets.only(right: 12),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: CachedNetworkImage(
                                              imageUrl: imageUrl,
                                              height: 130,
                                              width: 130,
                                              fit: BoxFit.cover,
                                              placeholder: (_, __) => Container(
                                                  color: Colors.grey[850]),
                                              errorWidget: (_, __, ___) =>
                                                  Container(
                                                      color: Colors.grey[850]),
                                            ),
                                          ),
                                          Positioned(
                                            top: 6,
                                            right: 8,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 7,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                "LIVE",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
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
                        ],

                        // New Releases (show for All, Movies, Web Series)
                        if (_selectedTabIndex == 0 ||
                            _selectedTabIndex == 2 ||
                            _selectedTabIndex == 3) ...[
                          SliverToBoxAdapter(
                            child: _buildSectionHeader(
                                "New Releases", RouteHelper.allMovieScreen),
                          ),
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: 240,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                itemCount: recentlyAdded.length,
                                itemBuilder: (context, i) =>
                                    _buildPoster(recentlyAdded[i]),
                              ),
                            ),
                          ),
                        ],

                        // Trending (show for All, Movies)
                        if (_selectedTabIndex == 0 ||
                            _selectedTabIndex == 2) ...[
                          SliverToBoxAdapter(
                            child: _buildSectionHeader(
                                "Trending", RouteHelper.allMovieScreen),
                          ),
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: 240,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                itemCount: recentlyAdded.length,
                                itemBuilder: (context, i) =>
                                    _buildPoster(recentlyAdded[i]),
                              ),
                            ),
                          ),
                        ],

                        const SliverToBoxAdapter(child: SizedBox(height: 40)),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String route) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: mulishBold.copyWith(color: Colors.white, fontSize: 20),
          ),
          GestureDetector(
            onTap: () => _navigateWithAuthCheck(route),
            child: Text(
              "See More",
              style: mulishSemiBold.copyWith(
                  color: MyColor.primaryColor, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoster(dynamic item) {
    final imgPath =
        item['image']?['portrait'] ?? item['image']?['landscape'] ?? '';
    final imgUrl = imgPath.isEmpty
        ? "https://via.placeholder.com/300"
        : imgPath.startsWith('http')
            ? imgPath
            : "$portraitBaseUrl$imgPath";

    final String? slug = item['slug'];

    return GestureDetector(
      onTap: () {
        if (slug != null) {
          _navigateWithAuthCheck(
            RouteHelper.movieDetailsScreen,
            args: {'slug': slug, 'imageUrl': imgUrl},
          );
        }
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: imgUrl,
            fit: BoxFit.cover,
            height: 200,
            width: 140,
            placeholder: (_, __) => Container(color: Colors.grey[850]),
            errorWidget: (_, __, ___) => Container(color: Colors.grey[850]),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateWithAuthCheck(String route, {dynamic args}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ??
        prefs.getString('token') ??
        prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      Get.toNamed(RouteHelper.loginScreen);
      Get.snackbar(
        "Login Required",
        "Please login to access this content",
        backgroundColor: Colors.red.withOpacity(0.95),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } else {
      Get.toNamed(route, arguments: args);
    }
  }
}

// Pinned Tab Bar Delegate
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final int selectedIndex;
  final Function(int) onTabChanged;

  _TabBarDelegate({required this.selectedIndex, required this.onTabChanged});

  @override
  double get maxExtent => 56;
  @override
  double get minExtent => 56;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: MyColor.colorBlack,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _TabItem(
            title: 'All',
            isSelected: selectedIndex == 0,
            onTap: () => onTabChanged(0),
          ),
          _TabItem(
            title: 'Shows',
            isSelected: selectedIndex == 1,
            onTap: () => onTabChanged(1),
          ),
          _TabItem(
            title: 'Movies',
            isSelected: selectedIndex == 2,
            onTap: () => onTabChanged(2),
          ),
          _TabItem(
            title: 'Web Series',
            isSelected: selectedIndex == 3,
            onTap: () => onTabChanged(3),
          ),
          _TabItem(
            title: 'Sports',
            isSelected: selectedIndex == 4,
            onTap: () => onTabChanged(4),
          ),
          _TabItem(
            title: 'Kids',
            isSelected: selectedIndex == 5,
            onTap: () => onTabChanged(5),
          ),
          _TabItem(
            title: 'Live',
            isSelected: selectedIndex == 6,
            onTap: () => onTabChanged(6),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) =>
      oldDelegate.selectedIndex != selectedIndex;
}

class _TabItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem(
      {required this.title, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
