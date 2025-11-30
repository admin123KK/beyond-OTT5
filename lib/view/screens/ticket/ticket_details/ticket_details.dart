import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/my_icons.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';
import 'package:play_lab/view/components/circle_icon_button.dart';
import 'package:play_lab/view/components/show_custom_snackbar.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class TicketDetailsScreen extends StatefulWidget {
  const TicketDetailsScreen({super.key});

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  final TextEditingController _replyController = TextEditingController();
  final List<Map<String, dynamic>> _attachments = [];

  // Dummy ticket data (passed from previous screen)
  late String ticketId;
  late String subject;

  // Dummy conversation history
  final List<Map<String, dynamic>> dummyMessages = [
    {
      "isAdmin": true,
      "message":
          "Hello! Thank you for reaching out. Can you please send us a screenshot of the issue?",
      "time": "2 hours ago",
      "attachments": []
    },
    {
      "isAdmin": false,
      "message":
          "Yes sure, I’m facing login issue after the latest update. Attaching screenshot.",
      "time": "1 hour ago",
      "attachments": ["screenshot.jpg"]
    },
    {
      "isAdmin": true,
      "message":
          "Thank you! We have identified the bug. Fix will be live in next 24 hours.",
      "time": "30 min ago",
      "attachments": []
    },
  ];

  @override
  void initState() {
    super.initState();
    ticketId = Get.arguments?[0] ?? "TKT-8844";
    subject = Get.arguments?[1] ?? "Login Problem After Update";
  }

  void _sendReply() {
    if (_replyController.text.trim().isEmpty) {
      CustomSnackbar.showCustomSnackbar(
        errorList: ["Please write a message"],
        msg: [],
        isError: true,
      );
      return;
    }

    setState(() {
      dummyMessages.insert(0, {
        "isAdmin": false,
        "message": _replyController.text,
        "time": "Just now",
        "attachments": _attachments.map((e) => e["name"]).toList(),
      });
      _replyController.clear();
      _attachments.clear();
    });

    CustomSnackbar.showCustomSnackbar(
      errorList: [],
      msg: ["Reply sent successfully"],
      isError: false,
    );
  }

  void _addDummyFile() {
    final files = ["screenshot.jpg", "log.txt", "error.pdf", "photo.png"];
    final icons = ["image", "doc", "pdf", "image"];
    final rand = DateTime.now().millisecond % 4;

    setState(() {
      _attachments.add({"name": files[rand], "type": icons[rand]});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.bgColor,
      appBar: CustomAppBar(title: "Ticket #$ticketId"),
      body: Column(
        children: [
          // Ticket Header Card
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text("Open",
                      style: mulishSemiBold.copyWith(color: Colors.green)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "[$ticketId] $subject",
                    style: mulishBold.copyWith(
                        fontSize: 16, color: MyColor.getTextColor()),
                  ),
                ),
                CircleIconButton(
                  onTap: () => Get.back(),
                  backgroundColor: MyColor.closeRedColor,
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              reverse: true, // Latest message at bottom
              itemCount: dummyMessages.length,
              itemBuilder: (ctx, i) {
                final msg = dummyMessages[i];
                final isAdmin = msg["isAdmin"] as bool;

                return Container(
                  margin: EdgeInsets.only(
                    left: isAdmin ? 60 : 12,
                    right: isAdmin ? 12 : 60,
                    bottom: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: isAdmin
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isAdmin
                              ? MyColor.primaryColor.withOpacity(0.12)
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
                              color: MyColor.primaryColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg["message"],
                              style: mulishRegular.copyWith(
                                color: isAdmin
                                    ? MyColor.getTextColor()
                                    : Colors.white,
                                height: 1.5,
                              ),
                            ),
                            if ((msg["attachments"] as List).isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                children:
                                    (msg["attachments"] as List).map((file) {
                                  return Chip(
                                    label: Text(file,
                                        style: const TextStyle(fontSize: 12)),
                                    backgroundColor:
                                        Colors.white.withOpacity(0.2),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        msg["time"],
                        style: mulishRegular.copyWith(
                            fontSize: 11, color: MyColor.bodyTextColor),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Reply Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MyColor.cardBg,
              border: Border(top: BorderSide(color: MyColor.borderColor)),
            ),
            child: Column(
              children: [
                // Attachments Preview
                if (_attachments.isNotEmpty)
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _attachments.length,
                      itemBuilder: (ctx, i) {
                        final file = _attachments[i];
                        return Stack(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: MyColor.borderColor),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  file["type"] == "image"
                                      ? MyIcons.file
                                      : file["type"] == "pdf"
                                          ? MyIcons.pdfFile
                                          : file["type"] == "doc"
                                              ? MyIcons.doc
                                              : MyIcons.xlsx,
                                  height: 36,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 4,
                              child: CircleIconButton(
                                onTap: () =>
                                    setState(() => _attachments.removeAt(i)),
                                height: 22,
                                width: 22,
                                backgroundColor: MyColor.closeRedColor,
                                child: const Icon(Icons.close,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    ZoomTapAnimation(
                      onTap: _attachments.length < 5 ? _addDummyFile : null,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: MyColor.textFieldColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: MyColor.borderColor),
                        ),
                        child: Icon(Icons.attachment_rounded,
                            color: MyColor.primaryColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _replyController,
                        maxLines: 3,
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
                            borderSide: BorderSide(color: MyColor.borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: MyColor.borderColor),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ZoomTapAnimation(
                      onTap: _sendReply,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: MyColor.primaryColor,
                        child:
                            const Icon(Icons.send_rounded, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
