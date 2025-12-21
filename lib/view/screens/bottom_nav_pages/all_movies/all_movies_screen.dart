import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/api.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';
import 'package:play_lab/view/components/bottom_Nav/bottom_nav.dart';
import 'package:play_lab/view/components/nav_drawer/custom_nav_drawer.dart';
import 'package:play_lab/view/will_pop_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllMovieScreen extends StatefulWidget {
  const AllMovieScreen({super.key});

  @override
  State<AllMovieScreen> createState() => _AllMovieScreenState();
}

class _AllMovieScreenState extends State<AllMovieScreen> {
  final ScrollController _scrollController = ScrollController();

  bool isLoading = true;
  bool isLoadingMore = false;
  String? errorMessage;

  List<dynamic> movies = [];
  String portraitBaseUrl =
      'https://ott.beyondtechnepal.com/assets/images/item/portrait/';

  int currentPage = 1;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    fetchMovies(page: 1);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore &&
          hasMore) {
        fetchMovies(page: currentPage + 1, isLoadMore: true);
      }
    });
  }

  Future<void> fetchMovies({int page = 1, bool isLoadMore = false}) async {
    if (isLoadMore) {
      setState(() => isLoadingMore = true);
    } else {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final url = Uri.parse('${ApiConstants.getAllMoviesEndpoint}?page=$page');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json['status'] == 'success') {
          final data = json['data']['movies'];
          final List<dynamic> newMovies = data['data'] ?? [];

          final String? backendPortraitPath = json['data']?['portrait_path'];
          if (backendPortraitPath != null) {
            portraitBaseUrl =
                'https://ott.beyondtechnepal.com/$backendPortraitPath';
          }

          setState(() {
            if (isLoadMore) {
              movies.addAll(newMovies);
              currentPage = page;
              isLoadingMore = false;
            } else {
              movies = newMovies;
            }
            hasMore = data['next_page_url'] != null;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Failed to load movies';
            isLoading = false;
            isLoadingMore = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error';
          isLoading = false;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'No internet connection';
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  Future<void> _navigateToDetails(dynamic movie) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ??
        prefs.getString('token') ??
        prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      Get.toNamed(RouteHelper.loginScreen);
      Get.snackbar(
        "Login Required",
        "Please login to watch movies",
        backgroundColor: Colors.red.withOpacity(0.95),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final String slug = movie['slug'] ?? '';
    final String? portraitFile = movie['image']?['portrait'];
    final String imageUrl = portraitFile != null && portraitFile.isNotEmpty
        ? portraitBaseUrl + portraitFile
        : '';

    final String heroTag = 'all_movie_hero_$slug';

    Get.toNamed(
      RouteHelper.movieDetailsScreen,
      arguments: {
        'slug': slug,
        'heroTag': heroTag,
        'imageUrl': imageUrl,
      },
    );
  }

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
          onRefresh: () async {
            currentPage = 1;
            await fetchMovies(page: 1);
          },
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: MyColor.primaryColor))
              : errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 80, color: Colors.white38),
                          const SizedBox(height: 16),
                          Text(errorMessage!,
                              style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 20),
                          ElevatedButton(
                              onPressed: () => fetchMovies(page: 1),
                              child: const Text("Retry")),
                        ],
                      ),
                    )
                  : movies.isEmpty
                      ? const Center(
                          child: Text("No movies available",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16)))
                      : GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics()),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio:
                                0.68, // Perfect ratio for your design
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: movies.length + (isLoadingMore ? 3 : 0),
                          itemBuilder: (context, index) {
                            if (index >= movies.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white54),
                                ),
                              );
                            }

                            final movie = movies[index];
                            final String title =
                                movie['title'] ?? 'Unknown Movie';
                            final String ratings = movie['ratings'] ?? '0.0';
                            final String? portraitFile =
                                movie['image']?['portrait'];
                            final String imageUrl =
                                portraitFile != null && portraitFile.isNotEmpty
                                    ? portraitBaseUrl + portraitFile
                                    : '';

                            final String heroTag =
                                'all_movie_hero_${movie['slug'] ?? index}';

                            return GestureDetector(
                              onTap: () => _navigateToDetails(movie),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // Fixed height poster area with placeholder
                                    Expanded(
                                      flex: 4,
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(16)),
                                        child: Hero(
                                          tag: heroTag,
                                          child: imageUrl.isNotEmpty
                                              ? CachedNetworkImage(
                                                  imageUrl: imageUrl,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  placeholder: (_, __) =>
                                                      Container(
                                                    color:
                                                        const Color(0xFF2A2A2A),
                                                    child: const Icon(
                                                      Icons.play_circle_outline,
                                                      size: 50,
                                                      color: Colors.white38,
                                                    ),
                                                  ),
                                                  errorWidget: (_, __, ___) =>
                                                      Container(
                                                    color:
                                                        const Color(0xFF2A2A2A),
                                                    child: const Icon(
                                                      Icons.play_circle_outline,
                                                      size: 50,
                                                      color: Colors.white38,
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  color:
                                                      const Color(0xFF2A2A2A),
                                                  child: const Icon(
                                                    Icons.play_circle_outline,
                                                    size: 50,
                                                    color: Colors.white38,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),

                                    // Bottom section: Title + Rating (fixed height)
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 12),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF121212),
                                          borderRadius: BorderRadius.vertical(
                                              bottom: Radius.circular(16)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              title,
                                              style: mulishSemiBold.copyWith(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.star,
                                                    color: Colors.amber,
                                                    size: 16),
                                                const SizedBox(width: 4),
                                                Text(
                                                  ratings,
                                                  style: mulishRegular.copyWith(
                                                    color: Colors.amber,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
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
    );
  }
}
