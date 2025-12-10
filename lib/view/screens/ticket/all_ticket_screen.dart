import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/api.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/helper/date_converter.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';
import 'package:play_lab/view/components/floating_action_button/fab.dart';
import 'package:shared_preferences/shared_preferences.dart'; // This is already in your app

class AllTicketScreen extends StatefulWidget {
  const AllTicketScreen({super.key});

  @override
  State<AllTicketScreen> createState() => _AllTicketScreenState();
}

class _AllTicketScreenState extends State<AllTicketScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> tickets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final url = Uri.parse(ApiConstants.getTicketEndpoint); // FULL URL HERE

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List data = json['data']['tickets']['data'];

        setState(() {
          tickets = data
              .map((e) => {
                    "ticket": e['ticket'] ?? 'TKT-000',
                    "subject": e['subject'] ?? 'No Subject',
                    "status": e['status'].toString(),
                    "priority": e['priority'].toString(),
                    "createdAt": e['created_at'] ?? '',
                  })
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Your same beautiful UI functions
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
      Colors.orange;
  String getPriorityText(String p) =>
      {"1": "Low", "2": "Medium", "3": "High", "4": "Urgent"}[p] ?? "Medium";

  void _openHomeDrawer() {
    Future.delayed(const Duration(milliseconds: 150), () {
      Scaffold.maybeOf(Get.nestedKey(1)?.currentContext ?? context)
          ?.openDrawer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        _openHomeDrawer();
        return false;
      },
      child: Scaffold(
        backgroundColor: MyColor.bgColor,
        appBar: CustomAppBar(title: MyStrings.supportTicket.tr),
        floatingActionButton:
            FAB(callback: () => Get.toNamed(RouteHelper.newTicketScreen)),
        body: RefreshIndicator(
          onRefresh: fetchTickets,
          color: MyColor.primaryColor,
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: MyColor.primaryColor))
              : tickets.isEmpty
                  ? Center(
                      child: ListView(children: const [
                      SizedBox(height: 300),
                      Text("No tickets found",
                          style: TextStyle(color: Colors.white54, fontSize: 18))
                    ]))
                  : ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: tickets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (_, i) {
                        final t = tickets[i];
                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Get.toNamed(
                              RouteHelper.ticketDetailsdScreen,
                              arguments: [t["ticket"], t["subject"]]),
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
                                    offset: const Offset(0, 4))
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(children: [
                                          TextSpan(
                                              text: "[${t["ticket"]}] ",
                                              style: mulishBold.copyWith(
                                                  color: MyColor.primaryColor,
                                                  fontSize: 15)),
                                          TextSpan(
                                              text: t["subject"],
                                              style: mulishBold.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 16)),
                                        ]),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: getStatusColor(t["status"])
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                            color: getStatusColor(t["status"]),
                                            width: 1.5),
                                      ),
                                      child: Text(getStatusText(t["status"]),
                                          style: mulishSemiBold.copyWith(
                                              color:
                                                  getStatusColor(t["status"]),
                                              fontSize: 13)),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: getPriorityColor(t["priority"])
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                            color:
                                                getPriorityColor(t["priority"]),
                                            width: 1.5),
                                      ),
                                      child: Text(
                                          getPriorityText(t["priority"]),
                                          style: mulishSemiBold.copyWith(
                                              color: getPriorityColor(
                                                  t["priority"]),
                                              fontSize: 13)),
                                    ),
                                    Text(
                                        DateConverter.getFormatedSubtractTime(
                                            t["createdAt"]),
                                        style: mulishRegular.copyWith(
                                            fontSize: 12,
                                            color: MyColor.bodyTextColor)),
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
