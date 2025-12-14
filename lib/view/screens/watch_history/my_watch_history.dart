import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/Get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/api.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';
import 'package:play_lab/view/components/nav_drawer/custom_nav_drawer.dart';
import 'package:play_lab/view/screens/movie_details/widget/rating_and_watch_widget/RatingAndWatchWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyWatchHistoryScreen extends StatefulWidget {
  const MyWatchHistoryScreen({super.key});

  @override
  State<MyWatchHistoryScreen> createState() => _MyWatchHistoryScreenState();
}

class _MyWatchHistoryScreenState extends State<MyWatchHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  List<dynamic> historyItems = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  String? errorMessage;
  int currentPage = 1;
  bool hasNextPage = false;

  @override
  void initState() {
    super.initState();
    fetchHistory(page: 1);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (hasNextPage && !isLoadingMore) {
        currentPage++;
        fetchHistory(page: currentPage, isLoadMore: true);
      }
    }
  }

  Future<void> fetchHistory(
      {required int page, bool isLoadMore = false}) async {
    if (!isLoadMore) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    } else {
      setState(() => isLoadingMore = true);
    }

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      setState(() {
        errorMessage = "Please login to view history";
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.histroyListEndpoint}?page=$page"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          final data = json['data']['histories'];
          final List<dynamic> newItems = data['data'] ?? [];

          setState(() {
            hasNextPage = data['next_page_url'] != null;
            if (isLoadMore) {
              historyItems.addAll(newItems);
              isLoadingMore = false;
            } else {
              historyItems = newItems;
              isLoading = false;
            }
          });
        } else {
          setState(() {
            errorMessage = "Failed to load history";
            isLoading = false;
            isLoadingMore = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Server error";
          isLoading = false;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "No internet connection";
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavigationDrawerWidget(),
      backgroundColor: MyColor.colorBlack,
      appBar:
          const CustomAppBar(title: MyStrings.myHistory, isShowBackBtn: true),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: MyColor.primaryColor))
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history,
                          size: 80, color: Colors.white38),
                      const SizedBox(height: 20),
                      Text(errorMessage!,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 18)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => fetchHistory(page: 1),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: MyColor.primaryColor),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : historyItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_toggle_off,
                              size: 100, color: Colors.white.withOpacity(0.5)),
                          const SizedBox(height: 24),
                          const Text("No Watch History Yet",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text("Start watching movies to see your history here",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        currentPage = 1;
                        await fetchHistory(page: 1);
                      },
                      color: MyColor.primaryColor,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        itemCount:
                            historyItems.length + (isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == historyItems.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(
                                    color: MyColor.primaryColor),
                              ),
                            );
                          }

                          final item = historyItems[index];
                          final movie = item['item'] ?? item['episode'];
                          if (movie == null) return const SizedBox();

                          final String title = movie['title'] ?? "Unknown";
                          final String? imgPath = movie['image']?['portrait'] ??
                              movie['image']?['landscape'];
                          final String imgUrl = imgPath == null ||
                                  imgPath.isEmpty
                              ? "https://via.placeholder.com/800x1200/1E1E1E/FFFFFF?text=No+Image"
                              : imgPath.startsWith('http')
                                  ? imgPath
                                  : "https://ott.beyondtechnepal.com/$imgPath";

                          final String heroTag =
                              "history_hero_${movie['id'] ?? index}";

                          return GestureDetector(
                            onTap: () {
                              Get.toNamed(RouteHelper.movieDetailsScreen,
                                  arguments: {
                                    'slug': movie['slug'],
                                    'heroTag': heroTag,
                                    'imageUrl': imgUrl,
                                  });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Hero(
                                    tag: heroTag,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CachedNetworkImage(
                                        imageUrl: imgUrl,
                                        width: 120,
                                        height: 160,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) =>
                                            Container(color: Colors.grey[800]),
                                        errorWidget: (_, __, ___) =>
                                            Container(color: Colors.grey[800]),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 20),
                                        Text(
                                          title,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 12),
                                        RatingAndWatchWidget(
                                          watch:
                                              movie['view']?.toString() ?? "0",
                                          rating:
                                              movie['ratings']?.toString() ??
                                                  "0.0",
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                                .animate()
                                .fade(
                                  duration: 400.ms,
                                  delay: (100 * index).ms,
                                )
                                .slideX(begin: 0.2, end: 0),
                          );
                        },
                      ),
                    ),
    );
  }
}
