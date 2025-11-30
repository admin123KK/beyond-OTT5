import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/helper/date_converter.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';
import 'package:play_lab/view/components/floating_action_button/fab.dart';

class AllTicketScreen extends StatefulWidget {
  const AllTicketScreen({super.key});

  @override
  State<AllTicketScreen> createState() => _AllTicketScreenState();
}

class _AllTicketScreenState extends State<AllTicketScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> tickets = [
    // ... your dummy data (same as before)
    {
      "ticket": "TKT-1001",
      "subject": "Login Issue",
      "status": "1",
      "priority": "3",
      "createdAt": "2025-03-30T18:00:00.000Z",
    },
    {
      "ticket": "TKT-1002",
      "subject": "Video Not Playing",
      "status": "2",
      "priority": "3",
      "createdAt": "2025-03-29T14:20:00.000Z",
    },
    {
      "ticket": "TKT-1003",
      "subject": "Payment Failed",
      "status": "3",
      "priority": "4",
      "createdAt": "2025-03-28T09:15:00.000Z",
    },
    {
      "ticket": "TKT-1004",
      "subject": "App Crashing on Android",
      "status": "4",
      "priority": "2",
      "createdAt": "2025-03-25T12:00:00.000Z",
    },
    {
      "ticket": "TKT-1005",
      "subject": "Can't Find My Subscription",
      "status": "1",
      "priority": "2",
      "createdAt": "2025-03-20T16:45:00.000Z",
    },
  ];

  // Color & text helpers (same as before)
  Color getStatusColor(String s) =>
      {
        "1": Colors.green,
        "2": Colors.blue,
        "3": Colors.orange,
        "4": Colors.grey
      }[s] ??
      Colors.grey;

  String getStatusText(String s) =>
      {"1": "Open", "2": "Answered", "3": "Replied", "4": "Closed"}[s] ??
      "Unknown";

  Color getPriorityColor(String p) =>
      {
        "1": Colors.blue,
        "2": Colors.orange,
        "3": Colors.red,
        "4": Colors.purple
      }[p] ??
      Colors.grey;

  String getPriorityText(String p) =>
      {"1": "Low", "2": "Medium", "3": "High", "4": "Urgent"}[p] ?? "Medium";

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // This function opens the drawer on Home screen
  void _openHomeDrawer() {
    // Delay to make sure we're back on Home first
    Future.delayed(const Duration(milliseconds: 150), () {
      final scaffold =
          Scaffold.maybeOf(Get.nestedKey(1)?.currentContext ?? context);
      scaffold?.openDrawer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back(); // Close this screen
        _openHomeDrawer(); // Open drawer on Home
        return false; // Prevent default pop
      },
      child: Scaffold(
        backgroundColor: MyColor.bgColor,

        // CustomAppBar without leading (it already has drawer icon)
        appBar: CustomAppBar(
          title: MyStrings.supportTicket.tr,

          // If your CustomAppBar supports onBackPressed → use it
          // onBackPressed: () {
          //   Get.back();
          //   _openHomeDrawer();
          // },

          // OR if it has leadingOnPress → use that
          // leadingOnPress: () {
          //   Get.back();
          //   _openHomeDrawer();
          // },
        ),

        floatingActionButton: FAB(
          callback: () => Get.toNamed(RouteHelper.newTicketScreen),
        ),

        body: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          color: MyColor.primaryColor,
          child: tickets.isEmpty
              ? const Center(
                  child: Text("No tickets found",
                      style: TextStyle(color: Colors.white54, fontSize: 16)))
              : ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: tickets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final t = tickets[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Get.toNamed(
                        RouteHelper.ticketDetailsdScreen,
                        arguments: [t["ticket"], t["subject"]],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: MyColor.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: MyColor.borderColor.withOpacity(0.5)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "[${t["ticket"]}] ",
                                          style: mulishBold.copyWith(
                                              color: MyColor.primaryColor,
                                              fontSize: 15),
                                        ),
                                        TextSpan(
                                          text: t["subject"],
                                          style: mulishBold.copyWith(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(t["status"]!)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                        color: getStatusColor(t["status"]!),
                                        width: 1.5),
                                  ),
                                  child: Text(
                                    getStatusText(t["status"]!),
                                    style: mulishSemiBold.copyWith(
                                        color: getStatusColor(t["status"]!),
                                        fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: getPriorityColor(t["priority"]!)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                        color: getPriorityColor(t["priority"]!),
                                        width: 1.5),
                                  ),
                                  child: Text(
                                    getPriorityText(t["priority"]!),
                                    style: mulishSemiBold.copyWith(
                                        color: getPriorityColor(t["priority"]!),
                                        fontSize: 13),
                                  ),
                                ),
                                Text(
                                  DateConverter.getFormatedSubtractTime(
                                      t["createdAt"]!),
                                  style: mulishRegular.copyWith(
                                      fontSize: 12,
                                      color: MyColor.bodyTextColor),
                                ),
                              ],
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
