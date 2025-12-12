import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/api.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/my_images.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/components/bottom_Nav/bottom_nav.dart';
import 'package:play_lab/view/components/nav_drawer/custom_nav_drawer.dart';
import 'package:play_lab/view/screens/live_tv_details/image_helper.dart';
import 'package:play_lab/view/screens/my_search/search_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  bool _isSearchVisible = false;
  int _currentPage = 0;
  late Timer _timer;
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _error;

  List<dynamic> sliders = [];
  List<dynamic> liveChannels = [];
  List<dynamic> recentlyAdded = [];
  List<dynamic> freeZone = [];
  List<dynamic> featured = [];
  String portraitBaseUrl = "";
  String landscapeBaseUrl = "";
  String tvBaseUrl = "";

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (featuredMovies.isEmpty || !_pageController.hasClients) return;
      setState(() {
        _currentPage =
            _currentPage < featuredMovies.length - 1 ? _currentPage + 1 : 0;
        _pageController.animateToPage(_currentPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut);
      });
    });
    fetchDashboard();
  }

  void _navigateWithAuthCheck(String route,
      {Map<String, dynamic>? args}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ??
        prefs.getString('token') ??
        prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      Get.toNamed(RouteHelper.loginScreen);
      Get.snackbar("Login Required", "Please login to access this content",
          backgroundColor: Colors.red.withOpacity(0.95),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12);
    } else {
      Get.toNamed(route, arguments: args);
    }
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
            tvBaseUrl = "https://ott.beyondtechnepal.com/${path['television']}";
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
          ? "https://via.placeholder.com/800x1200/222222/FFFFFF?text=${item['title']?.substring(0, 2).toUpperCase()}"
          : img.startsWith('http')
              ? img
              : "$landscapeBaseUrl$img";
      return {
        "title": item['title'] ?? "Untitled",
        "image": url,
        "year": item['created_at']?.substring(0, 4) ?? "2025",
        "slug": item['slug']?.toString() ?? ""
      };
    }).toList();
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    _searchController.dispose();
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
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      slivers: [
                        _buildAppBar(),
                        _buildHeroSlider(),
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              if (liveChannels.isNotEmpty) ...[
                                _buildSectionTitle(MyStrings.liveTV,
                                    RouteHelper.allLiveTVScreen),
                                _buildLiveTVList(),
                                const SizedBox(height: 20),
                              ],
                              if (recentlyAdded.isNotEmpty) ...[
                                _buildSectionTitle(
                                    "New Releases", RouteHelper.allMovieScreen),
                                _buildMoviesList(),
                                const SizedBox(height: 20),
                              ],
                              if (freeZone.isNotEmpty) ...[
                                _buildSectionTitle(MyStrings.ourFreeZone,
                                    RouteHelper.allFreeZoneScreen),
                                _buildFreeZoneList(),
                                const SizedBox(height: 20),
                              ],
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  // ─────────────────────────────── UI WIDGETS ───────────────────────────────
  Widget _buildAppBar() => SliverAppBar(
        backgroundColor: MyColor.colorBlack,
        elevation: 0,
        pinned: true,
        expandedHeight: _isSearchVisible ? 170 : 110,
        flexibleSpace: FlexibleSpaceBar(
          background: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(MyImages.logo, height: 55, fit: BoxFit.contain),
                    InkWell(
                      onTap: () =>
                          setState(() => _isSearchVisible = !_isSearchVisible),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                            color: MyColor.bgColor, shape: BoxShape.circle),
                        child: Icon(
                            _isSearchVisible ? Icons.close : Icons.search,
                            color: Colors.white,
                            size: 24),
                      ),
                    ),
                  ],
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isSearchVisible ? 70 : 0,
                  child: _isSearchVisible
                      ? Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: TextField(
                            controller: _searchController,
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
                                  borderSide: BorderSide.none),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white),
                                onPressed: () {
                                  final q = _searchController.text.trim();
                                  if (q.isNotEmpty)
                                    Get.to(() => SearchScreen(searchText: q));
                                },
                              ),
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildHeroSlider() => SliverToBoxAdapter(
        child: featuredMovies.isEmpty
            ? const SizedBox(
                height: 400,
                child: Center(
                    child: Text("No Featured Content",
                        style: TextStyle(color: Colors.white38))))
            : AspectRatio(
                aspectRatio: 0.85,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemCount: featuredMovies.length,
                      itemBuilder: (_, i) =>
                          _buildFeaturedItem(featuredMovies[i]),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          featuredMovies.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == i ? 28 : 10,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == i
                                  ? MyColor.primaryColor
                                  : Colors.white54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      );

  Widget _buildFeaturedItem(Map<String, dynamic> movie) {
    final String img = movie["image"];
    final String title = movie["title"];
    final String year = movie["year"];
    final String slug = movie["slug"];
    final String heroTag = "featured_hero_$slug";

    return InkWell(
      onTap: () => _navigateWithAuthCheck(
        RouteHelper.movieDetailsScreen,
        args: {
          'slug': slug,
          'heroTag': heroTag,
          'imageUrl': img,
        },
      ),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black87],
            ),
          ),
          child: Stack(
            children: [
              // HERO IMAGE - This will fly
              Positioned.fill(
                child: Hero(
                  tag: heroTag,
                  transitionOnUserGestures: true,
                  child: Image.network(
                    img,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(color: Colors.grey[900]),
                    errorBuilder: (_, __, ___) =>
                        Container(color: Colors.grey[900]),
                  ),
                ),
              ),
              // Content overlay
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(blurRadius: 10, color: Colors.black)
                            ])),
                    Text("$year • Tap to Watch",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _navigateWithAuthCheck(
                        RouteHelper.movieDetailsScreen,
                        args: {
                          'slug': slug,
                          'heroTag': heroTag,
                          'imageUrl': img,
                        },
                      ),
                      icon: const Icon(Icons.play_arrow,
                          size: 28, color: Colors.white),
                      label: const Text("Watch Now",
                          style: TextStyle(fontSize: 15, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColor.primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String route) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: mulishBold.copyWith(color: Colors.white, fontSize: 19)),
            GestureDetector(
              onTap: () => _navigateWithAuthCheck(route),
              child: Text("See All ",
                  style: mulishSemiBold.copyWith(
                      color: MyColor.primaryColor, fontSize: 14)),
            ),
          ],
        ),
      );

  Widget _buildLiveTVList() => SizedBox(
        height: 180,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          scrollDirection: Axis.horizontal,
          itemCount: liveChannels.length,
          itemBuilder: (context, i) {
            final item = liveChannels[i];
            final String title = item['title'] ?? "Channel";

            return InkWell(
              onTap: () => Get.toNamed(RouteHelper.liveTvDetailsScreen,
                  arguments: item['id']),
              child: Container(
                width: 140,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CachedNetworkImage(
                              imageUrl: ImageUrlHelper.tv(item['image']),
                              height: 90,
                              width: 80,
                              fit: BoxFit.contain,
                              placeholder: (_, __) => Container(
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.live_tv,
                                      color: Colors.white38, size: 40)),
                              errorWidget: (_, __, ___) => Container(
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.broken_image,
                                      color: Colors.white54, size: 40)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            title,
                            style: TextStyle(
                              color: title.toLowerCase().contains("kanti")
                                  ? const Color(0xFF00A0E3)
                                  : Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // LIVE Badge - Fixed Position
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Text("LIVE",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

  Widget _buildMoviesList() =>
      SizedBox(height: 180, child: _buildGridList(recentlyAdded));
  Widget _buildFreeZoneList() => SizedBox(
      height: 160,
      child: _buildGridList(freeZone, badge: "FREE", badgeColor: Colors.green));

  Widget _buildGridList(List<dynamic> items,
          {String? badge, Color? badgeColor}) =>
      ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          final imgPath =
              item['image']?['portrait'] ?? item['image']?['landscape'] ?? '';
          final imgUrl = imgPath.isEmpty
              ? "https://via.placeholder.com/300"
              : imgPath.startsWith('http')
                  ? imgPath
                  : "$portraitBaseUrl$imgPath";

          final String heroTag = "grid_hero_${item['slug'] ?? i}";

          return InkWell(
            onTap: () => _navigateWithAuthCheck(
              RouteHelper.movieDetailsScreen,
              args: {
                'slug': item['slug'],
                'heroTag': heroTag,
                'imageUrl': imgUrl,
              },
            ),
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 12),
              child: Hero(
                tag: heroTag,
                transitionOnUserGestures: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : Container(
                                color: Colors.grey[850],
                                child: const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: MyColor.primaryColor))),
                        errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[850],
                            child: const Icon(Icons.broken_image,
                                color: Colors.white38)),
                      ),
                      if (badge != null)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Chip(
                            label: Text(badge,
                                style: const TextStyle(fontSize: 9)),
                            backgroundColor: badgeColor,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          color: Colors.black.withOpacity(0.8),
                          child: Text(
                            item['title'] ?? "Unknown",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
}
