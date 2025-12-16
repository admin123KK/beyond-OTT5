import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:http/http.dart' as http;
import 'package:play_lab/constants/api.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';
import 'package:play_lab/view/components/custom_text_field.dart';
import 'package:play_lab/view/components/label_text.dart';
import 'package:play_lab/view/components/show_custom_snackbar.dart';
import 'package:play_lab/view/screens/ticket/all_ticket_screen.dart'; // Import AllTicketScreen
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
  final Map<String, int> _priorityMap = {
    "Low": 1,
    "Medium": 2,
    "High": 3,
  };

  final List<String> _priorityList = ["Low", "Medium", "High"];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitTicket() async {
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (subject.isEmpty || message.isEmpty) {
      CustomSnackbar.showCustomSnackbar(
        errorList: [MyStrings.pleaseFillOutTheField],
        msg: [],
        isError: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final prefs = await SharedPreferences.getInstance();
    final String? token =
        prefs.getString('access_token') ?? prefs.getString('token');

    if (token == null || token.isEmpty) {
      setState(() => _isSubmitting = false);
      CustomSnackbar.showCustomSnackbar(
        errorList: ['Please login to create a support ticket'],
        msg: [],
        isError: true,
      );
      Get.toNamed('/login-screen');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.createTicketEndpoint),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "subject": subject,
          "message": message,
          "priority": _priorityMap[_selectedPriority], // Sends 1, 2, or 3
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

        // Clear form (optional, since we're navigating away)
        _subjectController.clear();
        _messageController.clear();
        setState(() => _selectedPriority = "Medium");

        // Navigate to AllTicketScreen and replace current screen
        Get.off(() => const AllTicketScreen());
      } else {
        final errorMsg = json['message']?['error']?[0] ??
            json['message'] ??
            'Failed to create ticket';
        CustomSnackbar.showCustomSnackbar(
          errorList: [errorMsg],
          msg: [],
          isError: true,
        );
      }
    } catch (e) {
      CustomSnackbar.showCustomSnackbar(
        errorList: ['No internet connection or server error'],
        msg: [],
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
            const SizedBox(height: 20),

            // Subject
            LabelText(text: MyStrings.subject.tr),
            const SizedBox(height: 8),
            CustomTextField(
              hintText: MyStrings.enterYourSubject.tr,
              controller: _subjectController,
              nextFocus: _messageFocusNode,
              onChanged: null,
            ),

            const SizedBox(height: 24),

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
                          value: p,
                          child: Text(p,
                              style: mulishSemiBold.copyWith(
                                  color: Colors.white))))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedPriority = value!);
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Message
            LabelText(text: MyStrings.message.tr),
            const SizedBox(height: 8),
            CustomTextField(
              hintText: MyStrings.enterYourMessage.tr,
              controller: _messageController,
              focusNode: _messageFocusNode,
              maxLines: 8,
              onChanged: null,
            ),

            const SizedBox(height: 60),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitTicket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColor.primaryColor,
                  disabledBackgroundColor:
                      MyColor.primaryColor.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 6,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 3),
                      )
                    : Text(
                        MyStrings.submit.tr,
                        style: mulishSemiBold.copyWith(
                            color: Colors.white, fontSize: 18),
                      ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
