// test_live_tv_screen.dart
import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

class TestLiveTvScreen extends StatefulWidget {
  const TestLiveTvScreen({super.key});

  @override
  State<TestLiveTvScreen> createState() => _TestLiveTvScreenState();
}

class _TestLiveTvScreenState extends State<TestLiveTvScreen> {
  final TextEditingController _scopeController =
      TextEditingController(text: "all");
  String _result = "Enter scope and press Test API to fetch channels";
  bool _isLoading = false;

  List<dynamic> channels = [];
  String? playingUrl;
  String? playingTitle;
  String? playingDescription;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _playerLoading = true;
  bool _playerError = false;

  final String baseUrl = "https://ott.beyondtechnepal.com";

  Future<void> fetchLiveTv() async {
    final scope = _scopeController.text.trim();
    if (scope.isEmpty) {
      setState(() => _result = "Please enter a scope");
      return;
    }

    setState(() {
      _isLoading = true;
      _result = "Loading channels...";
      channels = [];
      _resetPlayer();
    });

    try {
      final url = Uri.parse("$baseUrl/api/live-television");
      final response = await http.get(url, headers: {
        'Accept': 'application/json'
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success' &&
            json['data']['televisions']['data'] is List) {
          setState(() {
            channels = json['data']['televisions']['data'];
            _result =
                "SUCCESS (200)\n\nChannels fetched: ${channels.length}\n\nURL: $url";
          });
        } else {
          setState(() {
            _result = "FAILED: No valid channel data\n\n${response.body}";
          });
        }
      } else {
        setState(() {
          _result = "FAILED: ${response.statusCode}\n\n${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _result = "ERROR: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _playChannel(String url, String title, String description) {
    _chewieController?.dispose();
    _videoController?.dispose();

    setState(() {
      playingUrl = url;
      playingTitle = title;
      playingDescription = description;
      _playerLoading = true;
      _playerError = false;
    });

    if (url.isEmpty) {
      setState(() => _playerError = true);
      return;
    }

    _videoController = VideoPlayerController.network(url);
    _videoController!.initialize().then((_) {
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: true,
        allowFullScreen: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.purple,
          handleColor: Colors.purple,
          backgroundColor: Colors.grey.shade900,
          bufferedColor: Colors.white24,
        ),
      );
      setState(() => _playerLoading = false);
    }).catchError((e) {
      setState(() {
        _playerLoading = false;
        _playerError = true;
      });
    });
  }

  void _resetPlayer() {
    _chewieController?.dispose();
    _videoController?.dispose();
    setState(() {
      playingUrl = null;
      playingTitle = null;
      playingDescription = null;
      _playerLoading = false;
      _playerError = false;
    });
  }

  double get _aspectRatio => _videoController?.value.isInitialized == true
      ? _videoController!.value.aspectRatio
      : 16 / 9;

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text("Live TV API Tester & Player"),
        backgroundColor: Colors.purple.shade900,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Scope Input
            TextField(
              controller: _scopeController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Enter scope (e.g. all, 1, kantipur)",
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple.shade400)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () => _scopeController.clear(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Fetch Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : fetchLiveTv,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send),
              label: Text(_isLoading ? "Testing..." : "Test API"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade700,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 30),

            // Result or Channel List
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade600),
                ),
                child: channels.isEmpty
                    ? SingleChildScrollView(
                        child: SelectableText(
                          _result,
                          style: const TextStyle(
                              color: Colors.white,
                              fontFamily: "monospace",
                              fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        itemCount: channels.length,
                        itemBuilder: (context, index) {
                          final channel = channels[index];
                          final String title = channel['title'] ?? "No Title";
                          final String description =
                              channel['description'] ?? "No Description";
                          final String url = channel['url'] ?? "";

                          return Card(
                            color: Colors.grey.shade800,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.tv,
                                  color: Colors.purple, size: 40),
                              title: Text(title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(description,
                                  style:
                                      const TextStyle(color: Colors.white70)),
                              trailing: const Icon(Icons.play_circle,
                                  color: Colors.green, size: 30),
                              onTap: () =>
                                  _playChannel(url, title, description),
                            ),
                          );
                        },
                      ),
              ),
            ),

            // Player Section (below the list)
            if (playingUrl != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade600),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text("Title: ",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 16)),
                        Text(playingTitle ?? "",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text("Description: ",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14)),
                        Expanded(
                            child: Text(playingDescription ?? "",
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 14))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.shade400),
                      ),
                      child: _playerLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.purple))
                          : _playerError
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.error,
                                          color: Colors.red, size: 40),
                                      const SizedBox(height: 10),
                                      SelectableText(
                                        playingUrl!,
                                        style: const TextStyle(
                                            color: Colors.cyan, fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : _chewieController != null
                                  ? AspectRatio(
                                      aspectRatio: _aspectRatio,
                                      child: Chewie(
                                          controller: _chewieController!),
                                    )
                                  : const Center(
                                      child: Text("No stream",
                                          style: TextStyle(
                                              color: Colors.white70))),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
