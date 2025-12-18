import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/api.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';
import 'package:play_lab/view/components/no_data_widget.dart';
import '../../../constants/my_strings.dart';

class SearchScreen extends StatefulWidget {
  final String? initialSearchText;

  const SearchScreen({super.key, this.initialSearchText});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isLoading = false;
  List<dynamic> movieList = [];
  String portraitPath = 'assets/images/item/portrait/';
  late TextEditingController _searchController;

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController =
        TextEditingController(text: widget.initialSearchText ?? '');

    // Start searching even with initial text
    if (widget.initialSearchText != null &&
        widget.initialSearchText!.trim().isNotEmpty) {
      _performSearch(widget.initialSearchText!.trim());
    }

    // Listen to every character typed
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Allow search from the VERY FIRST LETTER (no min length)
    if (query.isEmpty) {
      setState(() {
        movieList.clear();
        isLoading = false;
      });
      return;
    }

    // Fast debounce: 300ms — feels instant but prevents spam
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      isLoading = true;
      // Don't clear list immediately — keeps old results until new ones load
    });

    try {
      final url = Uri.parse(
          '${ApiConstants.searchListEndpoint}${Uri.encodeComponent(query)}');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json['status'] == 'success') {
          final data = json['data'];
          final List<dynamic> items = data['items']['data'] ?? [];

          final String newPortraitPath = data['portrait_path'] ?? portraitPath;

          setState(() {
            movieList = items;
            portraitPath = newPortraitPath;
            isLoading = false;
          });
        } else {
          setState(() {
            movieList = [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          movieList = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        movieList = [];
        isLoading = false;
      });
    }
  }

  String getPortraitImageUrl(String? filename) {
    if (filename == null || filename.isEmpty) {
      return 'https://via.placeholder.com/300x450?text=No+Image';
    }
    // Full URL with your domain
    return 'https://ott.beyondtechnepal.com/$portraitPath$filename';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: MyColor.colorBlack,
        appBar: const CustomAppBar(
          title: MyStrings.searchResult,
          isShowBackBtn: true,
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search movies, shows...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white70),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => movieList.clear());
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.white70, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onSubmitted: (value) => _performSearch(value.trim()),
              ),
            ),

            // Results Area
            Expanded(
              child: isLoading && movieList.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : movieList.isEmpty
                      ? NoDataFoundScreen(
                          message: _searchController.text.trim().isEmpty
                              ? 'Type to search movies'
                              : 'No results for "${_searchController.text.trim()}"',
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // 3 columns for better density
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: movieList.length,
                          itemBuilder: (context, index) {
                            final item = movieList[index];
                            final String title = item['title'] ?? 'No Title';
                            final String? portraitFile =
                                item['image']?['portrait'];

                            return InkWell(
                              onTap: () {
                                // TODO: Go to movie detail
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Opening: $title')),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            getPortraitImageUrl(portraitFile),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        placeholder: (_, __) => Container(
                                          color: Colors.grey[800],
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                                color: Colors.white54,
                                                strokeWidth: 2),
                                          ),
                                        ),
                                        errorWidget: (_, __, ___) => Container(
                                          color: Colors.grey[800],
                                          child: const Icon(Icons.broken_image,
                                              color: Colors.grey, size: 40),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
