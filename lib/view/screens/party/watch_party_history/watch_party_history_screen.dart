import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/core/utils/dimensions.dart';
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';

class WatchPartyHistoryScreen extends StatelessWidget {
  const WatchPartyHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final List<Map<String, String>> mockParties = [
      {
        "title": "Avengers: Endgame Watch Party",
        "host": "Tony Stark",
        "members": "12 watching",
        "time": "2 hours ago",
        "status": "live"
      },
      {
        "title": "Stranger Things S4 Finale",
        "host": "Eleven",
        "members": "8 watching",
        "time": "Yesterday",
        "status": "ended"
      },
      {
        "title": "Dune Part 2 Night",
        "host": "Paul Atreides",
        "members": "15 watching",
        "time": "3 days ago",
        "status": "ended"
      },
      {
        "title": "Spider-Man: No Way Home",
        "host": "Peter Parker",
        "members": "20 watching",
        "time": "Last week",
        "status": "ended"
      },
    ];

    return Scaffold(
      backgroundColor: MyColor.colorBlack,
      appBar: CustomAppBar(
        title: "Watch Party",
        bgColor: Colors.transparent,
        actions: [
          GestureDetector(
            onTap: () {
              _showJoinPartySheet(context);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.space15,
                vertical: Dimensions.space5,
              ),
              decoration: BoxDecoration(
                color: MyColor.primaryColor,
                borderRadius: BorderRadius.circular(Dimensions.cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: MyColor.primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                "Join Party",
                style: mulishSemiBold.copyWith(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
      body: mockParties.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.celebration,
                    size: 80,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "No Watch Parties Yet",
                    style: mulishSemiBold.copyWith(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Start or join a party to see history!",
                    style: mulishRegular.copyWith(color: Colors.white54),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mockParties.length,
              itemBuilder: (context, index) {
                final party = mockParties[index];
                bool isLive = party["status"] == "live";

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isLive
                          ? MyColor.primaryColor.withOpacity(0.5)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Poster Placeholder
                      Container(
                        width: 70,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                          image: const DecorationImage(
                            image:
                                NetworkImage("https://via.placeholder.com/150"),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                                Colors.black45, BlendMode.darken),
                          ),
                        ),
                        child: Icon(
                          Icons.play_circle_fill,
                          color: isLive ? MyColor.primaryColor : Colors.white54,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Party Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              party["title"]!,
                              style: mulishSemiBold.copyWith(
                                color: Colors.white,
                                fontSize: 17,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.person,
                                    size: 16, color: Colors.white60),
                                const SizedBox(width: 4),
                                Text(
                                  party["host"]!,
                                  style: mulishMedium.copyWith(
                                      color: Colors.white60),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.group,
                                    size: 16, color: Colors.white60),
                                const SizedBox(width: 4),
                                Text(
                                  party["members"]!,
                                  style: mulishRegular.copyWith(
                                      color: Colors.white60),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.access_time,
                                    size: 16, color: Colors.white60),
                                const SizedBox(width: 4),
                                Text(
                                  party["time"]!,
                                  style: mulishRegular.copyWith(
                                      color: Colors.white60),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Live Badge or Arrow
                      isLive
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.red, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "LIVE",
                                    style: mulishBold.copyWith(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const Icon(
                              Icons.chevron_right,
                              color: Colors.white38,
                              size: 28,
                            ),
                    ],
                  ),
                )
                    .animate()
                    .slideX(
                        begin: -0.2, delay: (100 * index).ms, duration: 600.ms)
                    .fadeIn();
              },
            ),
    );
  }

  // Join Party Bottom Sheet
  void _showJoinPartySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Join Watch Party",
                style: mulishBold.copyWith(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 20),
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter Party Code",
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: Colors.white54),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.snackbar(
                      "Joined!",
                      "Welcome to the party!",
                      backgroundColor: MyColor.primaryColor,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColor.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Join Party",
                    style: mulishSemiBold.copyWith(
                        fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
