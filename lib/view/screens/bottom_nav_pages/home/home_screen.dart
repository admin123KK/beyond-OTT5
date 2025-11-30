import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/my_images.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/components/bottom_Nav/bottom_nav.dart';
import 'package:play_lab/view/components/nav_drawer/custom_nav_drawer.dart';
import 'package:play_lab/view/screens/bottom_nav_pages/all_movies/watch_movie.dart'; // ADD THIS LINE

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

  // Featured Movies (same as yours)
  final List<Map<String, String>> featuredMovies = [
    {
      "title": "John Wick: Chapter 4",
      "image":
          "https://tse1.mm.bing.net/th/id/OIP.4LoVG7nt06NwWxjAmb19cAHaQC?w=1125&h=2436&rs=1&pid=ImgDetMain&o=7&rm=3",
      "year": "2023"
    },
    {
      "title": "Dune: Part Two",
      "image": "https://wallpaperaccess.com/full/12948324.jpg",
      "year": "2024"
    },
    {
      "title": "Deadpool & Wolverine",
      "image":
          "https://m.media-amazon.com/images/S/pv-target-images/dd6fb66997dd4cb5606b587bb255d2cd2cec20ecbd11852a8f6b07a1358d09a1.jpg",
      "year": "2024"
    },
    {
      "title": "Oppenheimer",
      "image":
          "https://tse2.mm.bing.net/th/id/OIP.fZoBEzk6so-Pj033wxwmNwHaLH?rs=1&pid=ImgDetMain&o=7&rm=3",
      "year": "2023"
    },
  ];

  // Movie Posters (Movies Section)
  final List<String> moviePosters = [
    'https://tse2.mm.bing.net/th/id/OIP.fZoBEzk6so-Pj033wxwmNwHaLH?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://th.bing.com/th/id/OIP.CmNSUluwE9FL_OcSpIAL-QHaEK?o=7rm=3&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse3.mm.bing.net/th/id/OIP.ZnfrTsth1Ca7moFTyz7RagHaHX?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse3.mm.bing.net/th/id/OIP.8oCtyV0T7Lp3_kSCnC54iAHaEy?w=2560&h=1658&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse2.mm.bing.net/th/id/OIP.WORJuyzM08Mjh74Qhwc8WwHaEK?w=2560&h=1440&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse2.mm.bing.net/th/id/OIP.dFgVSa2bzwKuuTxKlBIppgHaEo?rs=1&pid=ImgDetMain&o=7&rm=3',
  ];

  // LATEST SERIES POSTERS
  final List<Map<String, String>> latestSeriesPosters = [
    {
      "title": "Money Heist",
      "image": "https://image.tmdb.org/t/p/w500/reEMJA1uzscCbkpeRJeTT2bjqUp.jpg"
    },
    {
      "title": "Stranger Things",
      "image":
          "https://cdn.shopify.com/s/files/1/0522/8222/8911/files/touts-st-4.png?v=16518873278"
    },
    {
      "title": "Squid Game",
      "image":
          "https://static1.srcdn.com/wordpress/wp-content/uploads/2023/11/two-players-threaten-to-sue-netflix-over-alleged-injuries-from-squid-games_-the-challenge-1.jpg"
    },
    {
      "title": "The Witcher",
      "image":
          "https://tse3.mm.bing.net/th/id/OIP.ccydwWZcSpR6LeM03sgscwHaEo?rs=1&pid=ImgDetMain&o=7&rm=3"
    },
    {
      "title": "Wednesday",
      "image":
          "https://tse3.mm.bing.net/th/id/OIP.QcAfhVjLv507FbRsDqG1MAHaK-?rs=1&pid=ImgDetMain&o=7&rm=3"
    },
    {
      "title": "Loki",
      "image":
          "https://static1.colliderimages.com/wordpress/wp-content/uploads/2023/11/tom-hiddlestone-god-loki-season-2-poster.jpg"
    },
    {
      "title": "The Crown",
      "image":
          "https://www.thereelness.com/wp-content/uploads/2018/03/C880D986-E3DB-47F1-98E3-E2BF74ED7160.jpeg"
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < featuredMovies.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
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
          color: MyColor.primaryColor,
          backgroundColor: MyColor.cardBg,
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
            Get.snackbar("Refreshed", "Home updated!",
                backgroundColor: MyColor.primaryColor, colorText: Colors.white);
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
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
                                    shape: BoxShape.circle),
                                child: Icon(
                                    _isSearchVisible
                                        ? Icons.close
                                        : Icons.search_rounded,
                                    color: Colors.white,
                                    size: 22),
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
                                  borderSide: BorderSide.none),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // Auto-Sliding Featured Carousel
                    SizedBox(
                      height: 480,
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) =>
                                setState(() => _currentPage = index),
                            itemCount: featuredMovies.length,
                            itemBuilder: (context, index) {
                              final movie = featuredMovies[index];
                              return _buildFeaturedMovieItem(
                                imageUrl: movie["image"]!,
                                title: movie["title"]!,
                                year: movie["year"]!,
                              );
                            },
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
                                        duration:
                                            const Duration(milliseconds: 300),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        width: _currentPage == i ? 24 : 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                            color: _currentPage == i
                                                ? MyColor.primaryColor
                                                : Colors.white54,
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                      )),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    _buildSectionTitle(
                        MyStrings.liveTV, RouteHelper.allLiveTVScreen),
                    _buildLiveTVList(),
                    const SizedBox(height: 15),
                    _buildSectionTitle("Movies", RouteHelper.allMovieScreen),
                    _buildMoviesList(),
                    const SizedBox(height: 15),
                    _buildSectionTitle(
                        MyStrings.latestSeries, RouteHelper.allEpisodeScreen),
                    _buildLatestSeriesList(),
                    const SizedBox(height: 15),
                    _buildSectionTitle(
                        MyStrings.ourFreeZone, RouteHelper.allFreeZoneScreen),
                    _buildHorizontalList(Colors.purpleAccent, "Free Content"),
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

  // ONLY THIS METHOD IS MODIFIED → "Watch Now" now opens details screen
  Widget _buildFeaturedMovieItem({
    required String imageUrl,
    required String title,
    required String year,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image:
            DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.95)
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.black, blurRadius: 10)
                        ])),
                const SizedBox(height: 8),
                Text("Released in $year • Action • Thriller",
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // THIS IS THE ONLY CHANGE
                        Get.to(() => const WatchMovieDetailsScreen(),
                            arguments: {
                              'title': title,
                              'coverImage': imageUrl,
                              'year': year,
                              // Add more data as needed
                            });
                      },
                      icon: const Icon(
                        Icons.play_arrow,
                        size: 28,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Watch Now",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: MyColor.primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ALL OTHER METHODS REMAIN 100% SAME AS YOUR ORIGINAL
  Widget _buildSectionTitle(String title, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: mulishBold.copyWith(color: Colors.white, fontSize: 18)),
          GestureDetector(
              onTap: () => Get.toNamed(route),
              child: Text("See All",
                  style: mulishSemiBold.copyWith(
                      color: MyColor.primaryColor, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildLiveTVList() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (context, index) => _buildChannelItem(
          imageUrl:
              'https://yt3.googleusercontent.com/-7k9f25VwXdzn77vsMP6wgF8FL4i4p-LycW6EeYQCNOfnYFz1BLIrGgc4X3RZg116L8fsxFJ_A=s900-c-k-c0x-state-no-rj',
          label: "Live Channel",
          baseColor: Colors.redAccent,
        ),
      ),
    );
  }

  Widget _buildMoviesList() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        scrollDirection: Axis.horizontal,
        itemCount: moviePosters.length,
        itemBuilder: (context, index) => _buildChannelItem(
          imageUrl: moviePosters[index],
          label: "Action Movie",
          baseColor: Colors.blueAccent,
        ),
      ),
    );
  }

  Widget _buildLatestSeriesList() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        scrollDirection: Axis.horizontal,
        itemCount: latestSeriesPosters.length,
        itemBuilder: (context, index) {
          final series = latestSeriesPosters[index];
          return _buildChannelItem(
            imageUrl: series["image"]!,
            label: series["title"]!,
            baseColor: Colors.purpleAccent,
          );
        },
      ),
    );
  }

  Widget _buildChannelItem({
    required String imageUrl,
    required String label,
    required Color baseColor,
  }) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : Container(
                        color: baseColor.withOpacity(0.3),
                        child: const Center(
                            child: CircularProgressIndicator(
                                color: MyColor.primaryColor, strokeWidth: 2))),
                errorBuilder: (_, __, ___) => Container(
                    color: baseColor.withOpacity(0.3),
                    child:
                        const Icon(Icons.broken_image, color: Colors.white54)),
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle),
                child:
                    Icon(Icons.play_arrow_rounded, size: 38, color: baseColor),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.black.withOpacity(0.8),
                child: Text(
                  label,
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
    );
  }

  Widget _buildHorizontalList(Color color, String label) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        scrollDirection: Axis.horizontal,
        itemCount: 8,
        itemBuilder: (context, index) => Container(
          width: 120,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.play_circle_outline, size: 50, color: color),
            const SizedBox(height: 10),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}
