import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/api.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/my_icons.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';
import 'package:play_lab/view/components/circle_icon_button.dart';
import 'package:play_lab/view/components/custom_text_field.dart';
import 'package:play_lab/view/components/label_text.dart';
import 'package:play_lab/view/components/show_custom_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewTicketScreen extends StatefulWidget {
  const NewTicketScreen({super.key});

  @override
  State<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends State<NewTicketScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _messageFocusNode = FocusNode();

  String _selectedPriority = "Medium";
  final List<String> _priorityList = ["Low", "Medium", "High", "Urgent"];

  final List<Map<String, dynamic>> _attachments = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitTicket() async {
    if (_subjectController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      CustomSnackbar.showCustomSnackbar(
        errorList: [MyStrings.pleaseFillOutTheField],
        msg: [],
        isError: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.createTicketEndpoint),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "subject": _subjectController.text.trim(),
          "message": _messageController.text.trim(),
          "priority": _selectedPriority.toLowerCase(),
        }),
      );

      final json = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        CustomSnackbar.showCustomSnackbar(
          errorList: [],
          msg: [
            json['message']?['success']?[0] ??
                MyStrings.ticketCreateSuccessfully
          ],
          isError: false,
        );

        _subjectController.clear();
        _messageController.clear();
        setState(() {
          _selectedPriority = "Medium";
          _attachments.clear();
        });
        Get.back();
      } else {
        throw Exception(json['message'] ?? 'Failed to create ticket');
      }
    } catch (e) {
      CustomSnackbar.showCustomSnackbar(
        errorList: [e.toString().replaceAll('Exception: ', '')],
        msg: [],
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _addDummyAttachment() {
    if (_attachments.length >= 5) {
      CustomSnackbar.showCustomSnackbar(
          errorList: [MyStrings.attactmentError], msg: [], isError: true);
      return;
    }
    final names = ["screenshot.jpg", "invoice.pdf", "report.docx", "data.xlsx"];
    final types = ["image", "pdf", "doc", "xlsx"];
    final i = DateTime.now().millisecond % 4;

    setState(() {
      _attachments.add({"name": names[i], "type": types[i]});
    });

    CustomSnackbar.showCustomSnackbar(
        errorList: [], msg: ["${names[i]} attached"], isError: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.bgColor,
      appBar: CustomAppBar(title: MyStrings.addNewTicket.tr),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Subject
            LabelText(text: MyStrings.subject.tr),
            const SizedBox(height: 8),
            CustomTextField(
              hintText: MyStrings.enterYourSubject.tr,
              controller: _subjectController,
              nextFocus: _messageFocusNode,
              onChanged: null,
            ),

            const SizedBox(height: 20),

            // Priority
            LabelText(text: MyStrings.priority.tr),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: MyColor.textFieldColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: MyColor.borderColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPriority,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: MyColor.primaryColor),
                  dropdownColor: MyColor.textFieldColor,
                  items: _priorityList
                      .map((p) => DropdownMenuItem(
                          value: p, child: Text(p, style: mulishSemiBold)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedPriority = v!),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Message
            LabelText(text: MyStrings.message.tr),
            const SizedBox(height: 8),
            CustomTextField(
              hintText: MyStrings.enterYourMessage.tr,
              controller: _messageController,
              focusNode: _messageFocusNode,
              maxLines: 6,
              onChanged: null,
            ),

            const SizedBox(height: 20),

            // Attachments
            LabelText(text: MyStrings.attachments.tr),
            const SizedBox(height: 8),
            InkWell(
              onTap: _addDummyAttachment,
              child: CustomTextField(
                hintText: MyStrings.upload.tr,
                isEnabled: false,
                isShowSuffixIcon: true,
                suffixIcon: Container(
                  margin: const EdgeInsets.all(6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                      color: MyColor.primaryColor,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(MyStrings.upload.tr,
                      style: mulishSemiBold.copyWith(
                          color: Colors.white, fontSize: 13)),
                ),
                onChanged: null,
              ),
            ),
            const SizedBox(height: 6),
            Text(MyStrings.supportedFileHint,
                style: mulishRegular.copyWith(
                    color: MyColor.bodyTextColor, fontSize: 12)),

            if (_attachments.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _attachments.length,
                  itemBuilder: (_, i) {
                    final file = _attachments[i];
                    return Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: MyColor.borderColor)),
                          child: Center(
                            child: SvgPicture.asset(
                              file["type"] == "pdf"
                                  ? MyIcons.pdfFile
                                  : MyIcons.doc,
                              height: 40,
                              width: 40,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 8,
                          child: CircleIconButton(
                            onTap: () =>
                                setState(() => _attachments.removeAt(i)),
                            height: 24,
                            width: 24,
                            backgroundColor: MyColor.closeRedColor,
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 50),

            // BEAUTIFUL SUBMIT BUTTON WITHOUT RoundedButton
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _submitTicket(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColor.primaryColor,
                    disabledBackgroundColor:
                        MyColor.primaryColor.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          MyStrings.submit.tr,
                          style: mulishSemiBold.copyWith(
                              color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
