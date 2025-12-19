import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as ads
    if (dart.library.html) 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/api.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/url_container.dart'; // <-- Added for ImageHelper base URL
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';
import 'package:play_lab/view/components/nav_drawer/custom_nav_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishListScreen extends StatefulWidget {
  const WishListScreen({super.key});

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  List<dynamic> wishlistItems = [];
  bool isLoading = true;
  String? errorMessage;

  ads.BannerAd? _bannerAd;

  String get adUnitId {
    if (kIsWeb) return "";
    if (defaultTargetPlatform == TargetPlatform.android) {
      return MyStrings.wishListAndroidBanner;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return MyStrings.wishListIOSBanner;
    }
    return "";
  }

  @override
  void initState() {
    super.initState();
    fetchWishlist();
    if (!kIsWeb && adUnitId.isNotEmpty) {
      loadAd();
    }
  }

  void loadAd() {
    _bannerAd = ads.BannerAd(
      adUnitId: adUnitId,
      size: ads.AdSize.banner,
      request: const ads.AdRequest(),
      listener: ads.BannerAdListener(
        onAdLoaded: (_) => setState(() {}),
        onAdFailedToLoad: (ad, err) => ad.dispose(),
      ),
    )..load();
  }

  Future<void> fetchWishlist() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      setState(() {
        errorMessage = "Please login to view Watch Later";
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getWishListEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json['status'] == 'success') {
          final List<dynamic> items = json['data']['wishlists']['data'] ?? [];

          setState(() {
            wishlistItems = items;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = json['message'] ?? "Failed to load wishlist";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Server error: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "No internet connection";
        isLoading = false;
      });
    }
  }

  Future<void> removeFromWishlist(int wishlistId, int itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('access_token');

    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.removeWishListEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "item_id": itemId,
          "episode_id": null,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          setState(() {
            wishlistItems.removeWhere((item) => item['id'] == wishlistId);
          });
          Get.snackbar(
            "Removed",
            "Movie removed from Watch Later",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
        } else {
          Get.snackbar("Error", json['message'] ?? "Failed to remove", backgroundColor: Colors.red);
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to remove item", backgroundColor: Colors.red);
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavigationDrawerWidget(),
      backgroundColor: MyColor.colorBlack,
      appBar: const CustomAppBar(title: MyStrings.wishList, isShowBackBtn: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: MyColor.primaryColor))
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 80, color: Colors.white38),
                      const SizedBox(height: 20),
                      Text(errorMessage!, style: const TextStyle(color: Colors.white70, fontSize: 18)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: fetchWishlist,
                        style: ElevatedButton.styleFrom(backgroundColor: MyColor.primaryColor),
                        child: const Text("Retry", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : wishlistItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bookmark_border, size: 100, color: Colors.white.withOpacity(0.5)),
                          const SizedBox(height: 24),
                          const Text("Your Watch Later is Empty", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text("Add movies to watch later from movie details", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchWishlist,
                      color: MyColor.primaryColor,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: wishlistItems.length,
                        itemBuilder: (context, index) {
                          final wishlistEntry = wishlistItems[index];
                          final movie = wishlistEntry['item'];

                          final String title = movie['title'] ?? "Unknown Movie";
                          final String previewText = movie['preview_text'] ?? "No description available";
                          final String slug = movie['slug'] ?? "";
                          final String? landscape = movie['image']?['landscape'];
                          final String? portrait = movie['image']?['portrait'];

                          // Prioritize landscape (horizontal) for card, fallback to portrait
                          final String? imgPath = landscape ?? portrait;

                          // Use ImageHelper base URL (standard in your app)
                          final String imgUrl = imgPath == null || imgPath.isEmpty
                              ? "https://via.placeholder.com/800x1200/1E1E1E/FFFFFF?text=No+Image"
                              : "${UrlContainer.baseUrl}$imgPath";

                          final String heroTag = "wishlist_hero_${wishlistEntry['id']}";

                          return GestureDetector(
                            onTap: slug.isEmpty
                                ? null
                                : () {
                                    Get.toNamed(RouteHelper.movieDetailsScreen, arguments: {
                                      'slug': slug,
                                      'heroTag': heroTag,
                                      'imageUrl': imgUrl,
                                    });
                                  },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6)),
                                ],
                              ),
                              child: Row(
                                children: [
                              //     Hero(
                              //       tag: heroTag,
                              //       child: ClipRRect(
                              //         borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                              //         child: CachedNetworkImage(
                              //           // imageUrl: imgUrl,
                              //           width: 130,
                              //           height: 180,
                              //           fit: BoxFit.cover,
                              //           placeholder: (_, __) => Container(
                              //             color: Colors.grey[800],
                              //             child: const Center(child: CircularProgressIndicator(color: MyColor.primaryColor)),
                              //           ),
                              //           errorWidget: (_, __, ___) => Container(
                              //             color: Colors.grey[800],
                              //             child: const Icon(Icons.broken_image, color: Colors.white38, size: 50),
                              //           ), imageUrl: '',
                              //         ),
                              //       ),
                              //     ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            previewText,
                                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              ElevatedButton.icon(
                                                onPressed: slug.isEmpty
                                                    ? null
                                                    : () {
                                                        Get.toNamed(RouteHelper.movieDetailsScreen, arguments: {
                                                          'slug': slug,
                                                          'heroTag': heroTag,
                                                          'imageUrl': imgUrl,
                                                        });
                                                      },
                                                icon: const Icon(Icons.play_arrow_outlined, size: 18,color: Colors.white,),
                                                label: Text(MyStrings.watchNow,style: TextStyle(color: Colors.white),),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: MyColor.primaryColor,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                                ),
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () {
                                                  final wishlistId = wishlistEntry['id'];
                                                  final itemId = movie['id'];
                                                  removeFromWishlist(wishlistId, itemId);
                                                },
                                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
                                                tooltip: "Remove from Watch Later",
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
      bottomNavigationBar: !kIsWeb && _bannerAd != null
          ? SizedBox(height: _bannerAd!.size.height.toDouble(), child: ads.AdWidget(ad: _bannerAd!))
          : const SizedBox.shrink(),
    );
  }
}