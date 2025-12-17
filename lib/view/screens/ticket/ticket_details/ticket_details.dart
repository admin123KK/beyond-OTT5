import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/api.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';
import 'package:play_lab/view/components/circle_icon_button.dart';
import 'package:play_lab/view/components/custom_snackbar.dart';
import 'package:play_lab/view/components/show_custom_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class TicketDetailsScreen extends StatefulWidget {
  const TicketDetailsScreen({super.key});

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  final TextEditingController _replyController = TextEditingController();

  late String ticketNumber;
  String ticketId = '';
  String subject = '';
  String status = '0';
  List<dynamic> messages = [];
  bool isLoading = true;
  bool isSendingReply = false;
  bool isClosingTicket = false;

  @override
  void initState() {
    super.initState();
    ticketNumber = Get.arguments?.toString() ?? '';
    if (ticketNumber.isEmpty) {
      CustomSnackbar.showCustomSnackbar(
          errorList: ['Invalid ticket'], msg: [], isError: true);
      Get.back();
      return;
    }
    fetchTicketDetails();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? prefs.getString('token');
  }

  Future<void> fetchTicketDetails() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final token = await _getToken();
    if (token == null) {
      CustomSnackbar.showCustomSnackbar(
          errorList: [MyStrings.loginFailedTryAgain], msg: [], isError: true);
      if (mounted) Get.offAllNamed('/login');
      return;
    }

    try {
      final url = "${ApiConstants.viewSupportTicketEndpoint}/$ticketNumber";
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          final myTicket = json['data']['my_ticket'];
          final List<dynamic> msgs = json['data']['messages'] ?? [];

          setState(() {
            ticketId = myTicket['id'].toString();
            ticketNumber = myTicket['ticket'] ?? ticketNumber;
            subject = myTicket['subject'] ?? 'No Subject';
            status = myTicket['status'].toString();
            messages = msgs.reversed.toList();
            isLoading = false;
          });
        } else {
          CustomSnackbar.showCustomSnackbar(
              errorList: [json['message'] ?? 'Failed to load ticket'],
              msg: [],
              isError: true);
          if (mounted) Get.back();
        }
      } else if (response.statusCode == 401) {
        CustomSnackbar.showCustomSnackbar(
            errorList: ['Session expired'], msg: [], isError: true);
        if (mounted) Get.offAllNamed('/login');
      } else {
        CustomSnackbar.showCustomSnackbar(
            errorList: ['Server error'], msg: [], isError: true);
        if (mounted) Get.back();
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showCustomSnackbar(
            errorList: ['Check internet connection'], msg: [], isError: true);
        Get.back();
      }
    }
  }

  Future<void> _sendReply() async {
    if (_replyController.text.trim().isEmpty) {
      CustomSnackbar.showCustomSnackbar(
          errorList: ['Please write a message'], msg: [], isError: true);
      return;
    }

    if (!mounted) return;
    setState(() => isSendingReply = true);

    final token = await _getToken();
    if (token == null) return;

    try {
      final url = "${ApiConstants.replySupportTicketEndpoint}/$ticketId";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'message': _replyController.text.trim()}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          _replyController.clear();
          await fetchTicketDetails();
          CustomSnackbar.showCustomSnackbar(
              errorList: [], msg: ['Reply sent successfully'], isError: false);
        } else {
          CustomSnackbar.showCustomSnackbar(
              errorList: [json['message'] ?? 'Reply failed'],
              msg: [],
              isError: true);
        }
      } else {
        CustomSnackbar.showCustomSnackbar(
            errorList: ['Server error while replying'], msg: [], isError: true);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showCustomSnackbar(
            errorList: ['Check internet'], msg: [], isError: true);
      }
    } finally {
      if (mounted) setState(() => isSendingReply = false);
    }
  }

  // Close ticket → API call → back → refresh list
  Future<void> _closeTicket() async {
    if (!mounted) return;
    setState(() => isClosingTicket = true);

    final token = await _getToken();
    if (token == null) return;

    try {
      final url = "${ApiConstants.closeSupportTicketEndpoint}/$ticketId";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          CustomSnackbar.showCustomSnackbar(
              errorList: [],
              msg: ['Ticket closed successfully'],
              isError: false);

          // Back to AllTicketScreen and trigger refresh
          Get.back(result: true);
        } else {
          CustomSnackbar.showCustomSnackbar(
              errorList: [json['message'] ?? 'Failed to close ticket'],
              msg: [],
              isError: true);
        }
      } else {
        CustomSnackbar.showCustomSnackbar(
            errorList: ['Server error'], msg: [], isError: true);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showCustomSnackbar(
            errorList: ['Check internet'], msg: [], isError: true);
      }
    } finally {
      if (mounted) setState(() => isClosingTicket = false);
    }
  }

  String _getStatusText() {
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
        return "Unknown";
    }
  }

  Color _getStatusColor() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.bgColor,
      appBar: CustomAppBar(title: "Ticket #$ticketNumber"),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: MyColor.primaryColor))
          : Column(
              children: [
                // Header
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MyColor.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: MyColor.borderColor, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _getStatusColor()),
                        ),
                        child: Text(
                          _getStatusText(),
                          style:
                              mulishSemiBold.copyWith(color: _getStatusColor()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "[$ticketNumber] $subject",
                          style: mulishBold.copyWith(
                              fontSize: 16, color: MyColor.getTextColor()),
                        ),
                      ),
                      // Cross Button → Close Ticket
                      CircleIconButton(
                        onTap: () {
                          _closeTicket();
                          showCustomSnackBar('Ticket Closed', context);
                        },
                        backgroundColor: MyColor.closeRedColor,
                        child: isClosingTicket
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.close,
                                color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ),

                // Messages
                Expanded(
                  child: messages.isEmpty
                      ? Center(
                          child: Text("No messages yet",
                              style: mulishRegular.copyWith(
                                  color: MyColor.bodyTextColor)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (ctx, i) {
                            final msg = messages[i];
                            final bool isAdmin = msg['admin_id'] != null ||
                                (msg['user_type'] ?? '') == 'admin';
                            final String time = msg['created_at'] ?? 'Just now';

                            return Container(
                              margin: EdgeInsets.only(
                                  left: isAdmin ? 60 : 12,
                                  right: isAdmin ? 12 : 60,
                                  bottom: 16),
                              child: Column(
                                crossAxisAlignment: isAdmin
                                    ? CrossAxisAlignment.start
                                    : CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: isAdmin
                                          ? MyColor.primaryColor
                                              .withOpacity(0.12)
                                          : MyColor.primaryColor,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(16),
                                        topRight: const Radius.circular(16),
                                        bottomLeft: isAdmin
                                            ? Radius.zero
                                            : const Radius.circular(16),
                                        bottomRight: isAdmin
                                            ? const Radius.circular(16)
                                            : Radius.zero,
                                      ),
                                      border: Border.all(
                                          color: MyColor.primaryColor
                                              .withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      msg['message'] ?? '',
                                      style: mulishRegular.copyWith(
                                        color: isAdmin
                                            ? MyColor.getTextColor()
                                            : Colors.white,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(time,
                                      style: mulishRegular.copyWith(
                                          fontSize: 11,
                                          color: MyColor.bodyTextColor)),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                // Reply Box (only if not closed)
                if (status != '3')
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: MyColor.cardBg,
                      border:
                          Border(top: BorderSide(color: MyColor.borderColor)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _replyController,
                            maxLines: 4,
                            minLines: 1,
                            decoration: InputDecoration(
                              hintText: "Type your reply...",
                              hintStyle: mulishRegular.copyWith(
                                  color: MyColor.hintTextColor),
                              filled: true,
                              fillColor: MyColor.textFieldColor,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: MyColor.borderColor)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: MyColor.borderColor)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ZoomTapAnimation(
                          onTap: _sendReply,
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: MyColor.primaryColor,
                            child: isSendingReply
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.send_rounded,
                                    color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
