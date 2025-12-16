import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
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
  String currentQuery = '';

  // Debug info - to see exactly what backend returns
  String debugUrl = '';
  String debugStatus = '';
  String debugResponse = '';
  Color debugColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _searchController =
        TextEditingController(text: widget.initialSearchText ?? '');
    currentQuery = widget.initialSearchText?.trim() ?? '';

    if (currentQuery.isNotEmpty) {
      fetchSearchResults(currentQuery);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchSearchResults(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() {
        movieList.clear();
        currentQuery = '';
        debugUrl = debugStatus = debugResponse = '';
      });
      return;
    }

    setState(() {
      isLoading = true;
      movieList.clear();
      debugUrl =
          '${ApiConstants.searchListEndpoint}?search=${Uri.encodeComponent(q)}';
      debugStatus = 'Calling API...';
      debugResponse = 'Waiting...';
      debugColor = Colors.orange;
    });

    try {
      final response = await http.get(Uri.parse(debugUrl));

      setState(() {
        debugStatus = 'Status Code: ${response.statusCode}';
        debugResponse = response.body.length > 800
            ? '${response.body.substring(0, 800)}...\n(truncated)'
            : response.body;
        debugColor = response.statusCode == 200 ? Colors.green : Colors.red;
      });

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json['status'] == 'success') {
          final data = json['data'];
          final List<dynamic> items = data['items']['data'];

          // Only update portrait path (we only need title + image)
          portraitPath = data['portrait_path'] ?? portraitPath;

          setState(() {
            movieList = items;
            currentQuery = q;
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() {
        debugStatus = 'Error: $e';
        debugResponse = 'Connection failed';
        debugColor = Colors.red;
        isLoading = false;
      });
    }
  }

  String getPortraitImageUrl(String? filename) {
    if (filename == null || filename.isEmpty) {
      return 'https://via.placeholder.com/300x450?text=No+Image';
    }
    return portraitPath + filename; // Only path + filename from backend
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: MyColor.colorBlack,
        appBar: CustomAppBar(
          title: MyStrings.searchResult,
          isShowBackBtn: true,
        ),
        body: Column(
          children: [
            // DEBUG BOX - Only shows in debug mode so you know if API is working
            if (kDebugMode)
              Container(
                width: double.infinity,
                color: debugColor.withOpacity(0.2),
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('API DEBUG INFO',
                        style: TextStyle(
                            color: debugColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    const SizedBox(height: 8),
                    Text('URL:',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11)),
                    Text(debugUrl,
                        style:
                            const TextStyle(color: Colors.cyan, fontSize: 10)),
                    const SizedBox(height: 4),
                    Text(debugStatus,
                        style: TextStyle(
                            color: debugColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Response:',
                        style: TextStyle(color: Colors.white70, fontSize: 11)),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(debugResponse,
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 9)),
                    ),
                  ],
                ),
              ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search by title...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white70),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        movieList.clear();
                        currentQuery = '';
                        debugUrl = debugStatus = debugResponse = '';
                      });
                    },
                  ),
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
                ),
                onSubmitted: fetchSearchResults,
              ),
            ),

            // Results - Only showing Title + Poster
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : movieList.isEmpty
                      ? NoDataFoundScreen(
                          message: currentQuery.isEmpty
                              ? 'Type a title to search'
                              : 'No movies found for "$currentQuery"',
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                          itemCount: movieList.length,
                          itemBuilder: (context, index) {
                            final item = movieList[index];
                            final String title = item['title'] ?? 'No Title';
                            final String imageUrl =
                                getPortraitImageUrl(item['image']?['portrait']);

                            return InkWell(
                              onTap: () {
                                // You can add navigation later
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: MyColor.colorBlack.withOpacity(0.9),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black45,
                                        blurRadius: 8,
                                        offset: Offset(0, 4)),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // Poster Image
                                    Expanded(
                                      flex: 5,
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(12)),
                                        child: CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          placeholder: (_, __) => Container(
                                            color: Colors.grey[800],
                                            child: const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                        color: Colors.white54)),
                                          ),
                                          errorWidget: (_, __, ___) =>
                                              Container(
                                            color: Colors.grey[800],
                                            child: const Icon(
                                                Icons.broken_image,
                                                color: Colors.grey,
                                                size: 50),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Only Title
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Center(
                                          child: Text(
                                            title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
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
          ],
        ),
      ),
    );
  }
}
