import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/api.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/helper/date_converter.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';
import 'package:play_lab/view/components/floating_action_button/fab.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllTicketScreen extends StatefulWidget {
  const AllTicketScreen({super.key});

  @override
  State<AllTicketScreen> createState() => _AllTicketScreenState();
}

class _AllTicketScreenState extends State<AllTicketScreen> {
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> tickets = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  String? errorMessage;

  int currentPage = 1;
  int lastPage = 1;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    fetchTickets(page: 1);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoading &&
          !isLoadingMore &&
          hasMore) {
        fetchTickets(page: currentPage + 1);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchTickets({int page = 1}) async {
    if (page == 1) {
      setState(() {
        isLoading = true;
        tickets.clear();
        errorMessage = null;
      });
    } else {
      setState(() => isLoadingMore = true);
    }

    final prefs = await SharedPreferences.getInstance();
    final String? token =
        prefs.getString('access_token') ?? prefs.getString('token');

    if (token == null || token.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = "Please login to view tickets";
      });
      Get.offAllNamed(RouteHelper.loginScreen);
      return;
    }

    try {
      final String url = "${ApiConstants.viewSupportTicketEndpoint}?page=$page";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Tickets API URL: $url');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json['status'] == 'success') {
          final ticketData = json['data']['tickets'];
          final List<dynamic> newTickets = ticketData['data'];
          lastPage = ticketData['last_page'] ?? 1;
          hasMore = currentPage < lastPage;

          final List<Map<String, dynamic>> parsedTickets = newTickets.map((e) {
            return {
              "id": e['id'].toString(),
              "ticket": e['ticket'] ?? 'TKT-000',
              "subject": e['subject'] ?? 'No Subject',
              "status": e['status'].toString(),
              "priority": e['priority'].toString(),
              "createdAt": e['created_at'] ?? '',
              "lastReply": e['last_reply'] ?? '',
            };
          }).toList();

          setState(() {
            if (page == 1) {
              tickets = parsedTickets;
            } else {
              tickets.addAll(parsedTickets);
            }
            currentPage = page;
          });
        } else {
          errorMessage =
              json['message']?['error']?[0] ?? "Failed to load tickets";
        }
      } else if (response.statusCode == 401) {
        errorMessage = "Session expired. Please login again.";
        await prefs.remove('access_token');
        Get.offAllNamed(RouteHelper.loginScreen);
      } else {
        errorMessage = "Server error: ${response.statusCode}";
      }
    } catch (e) {
      debugPrint('Fetch tickets error: $e');
      errorMessage = "Check your internet connection";
    } finally {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case '0':
        return "Open";
      case '1':
        return "Answered";
      case '2':
        return "Replied";
      case '3':
        return "Closed";
      default:
        return "Open";
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case '0':
        return Colors.orange;
      case '1':
        return Colors.blue;
      case '2':
        return Colors.purple;
      case '3':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String getPriorityText(String priority) {
    switch (priority) {
      case '1':
        return "Low";
      case '2':
        return "Medium";
      case '3':
        return "High";
      default:
        return "Medium";
    }
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case '1':
        return Colors.green;
      case '2':
        return Colors.orange;
      case '3':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

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
          onRefresh: () => fetchTickets(page: 1),
          color: MyColor.primaryColor,
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: MyColor.primaryColor))
              : errorMessage != null
                  ? Center(
                      child: ListView(
                        children: [
                          const SizedBox(height: 200),
                          Icon(Icons.error_outline,
                              color: Colors.red[300], size: 80),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 18),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => fetchTickets(page: 1),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: MyColor.primaryColor),
                            child: const Text("Retry",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    )
                  : tickets.isEmpty
                      ? Center(
                          child: ListView(
                            children: const [
                              SizedBox(height: 300),
                              Icon(Icons.inbox_outlined,
                                  color: Colors.white54, size: 80),
                              SizedBox(height: 20),
                              Text(
                                "No support tickets yet",
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 18),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          itemCount: tickets.length + (isLoadingMore ? 1 : 0),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (_, i) {
                            if (i == tickets.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(
                                      color: MyColor.primaryColor),
                                ),
                              );
                            }

                            final t = tickets[i];

                            return InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                // Navigate to Ticket Details using ticket number
                                Get.toNamed(
                                  RouteHelper.ticketDetailsdScreen,
                                  arguments: {
                                    'ticketNumber': t["ticket"],
                                    'subject': t["subject"],
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: MyColor.cardBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color:
                                          MyColor.borderColor.withOpacity(0.5)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
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
                                                      color:
                                                          MyColor.primaryColor,
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
                                            color: getStatusColor(t["status"])
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            border: Border.all(
                                                color:
                                                    getStatusColor(t["status"]),
                                                width: 1.5),
                                          ),
                                          child: Text(
                                            getStatusText(t["status"]),
                                            style: mulishSemiBold.copyWith(
                                                color:
                                                    getStatusColor(t["status"]),
                                                fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 7),
                                          decoration: BoxDecoration(
                                            color:
                                                getPriorityColor(t["priority"])
                                                    .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            border: Border.all(
                                                color: getPriorityColor(
                                                    t["priority"]),
                                                width: 1.5),
                                          ),
                                          child: Text(
                                            getPriorityText(t["priority"]),
                                            style: mulishSemiBold.copyWith(
                                                color: getPriorityColor(
                                                    t["priority"]),
                                                fontSize: 13),
                                          ),
                                        ),
                                        Text(
                                          DateConverter.getFormatedSubtractTime(
                                              t["createdAt"]),
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
