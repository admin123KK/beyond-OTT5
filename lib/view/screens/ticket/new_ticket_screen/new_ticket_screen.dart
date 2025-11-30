import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:play_lab/constants/my_strings.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/my_icons.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/view/components/app_bar/custom_appbar.dart';
import 'package:play_lab/view/components/buttons/rounded_button.dart';
import 'package:play_lab/view/components/circle_icon_button.dart';
import 'package:play_lab/view/components/custom_text_field.dart';
import 'package:play_lab/view/components/label_text.dart';
import 'package:play_lab/view/components/show_custom_snackbar.dart';

class NewTicketScreen extends StatefulWidget {
  const NewTicketScreen({super.key});

  @override
  State<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends State<NewTicketScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();

  String? _selectedPriority = "Medium";
  final List<String> _priorityList = ["Low", "Medium", "High", "Urgent"];

  final List<Map<String, dynamic>> _attachments = [];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _showSuccess() {
    CustomSnackbar.showCustomSnackbar(
      errorList: [],
      msg: [MyStrings.ticketCreateSuccessfully],
      isError: false,
    );
    // Clear form
    _subjectController.clear();
    _messageController.clear();
    setState(() {
      _selectedPriority = "Medium";
      _attachments.clear();
    });
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
              isPassword: false,
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
                border: Border.all(color: MyColor.borderColor, width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPriority,
                  dropdownColor: MyColor.textFieldColor,
                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                      color: MyColor.primaryColor),
                  isExpanded: true,
                  items: _priorityList.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(
                        priority,
                        style: mulishSemiBold.copyWith(
                            color: MyColor.getTextColor()),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedPriority = value);
                  },
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
              isPassword: false,
              onChanged: null,
            ),

            const SizedBox(height: 20),

            // Attachments
            LabelText(text: MyStrings.attachments.tr),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                if (_attachments.length < 5) {
                  _addDummyAttachment(); // Simulate file pick
                } else {
                  CustomSnackbar.showCustomSnackbar(
                    errorList: [MyStrings.attactmentError],
                    msg: [],
                    isError: true,
                  );
                }
              },
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    MyStrings.upload.tr,
                    style: mulishSemiBold.copyWith(
                        color: Colors.white, fontSize: 13),
                  ),
                ),
                onChanged: null,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              MyStrings.supportedFileHint,
              style: mulishRegular.copyWith(
                  color: MyColor.bodyTextColor, fontSize: 12),
            ),

            // Attached Files Preview
            if (_attachments.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _attachments.length,
                  itemBuilder: (context, index) {
                    final file = _attachments[index];
                    return Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: MyColor.borderColor),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              file["type"] == "image"
                                  ? MyIcons.pdfFile
                                  : file["type"] == "pdf"
                                      ? MyIcons.pdfFile
                                      : file["type"] == "doc"
                                          ? MyIcons.doc
                                          : MyIcons.xlsx,
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
                                setState(() => _attachments.removeAt(index)),
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

            const SizedBox(height: 40),

            // Submit Button
            Center(
              child: RoundedButton(
                text: MyStrings.submit.tr,
                press: () {
                  if (_subjectController.text.isEmpty ||
                      _messageController.text.isEmpty) {
                    CustomSnackbar.showCustomSnackbar(
                      errorList: [MyStrings.pleaseFillOutTheField],
                      msg: [],
                      isError: true,
                    );
                  } else {
                    _showSuccess();
                  }
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Simulate file attachment (for demo)
  void _addDummyAttachment() {
    final types = ["image", "pdf", "doc", "xlsx"];
    final names = ["screenshot.jpg", "invoice.pdf", "report.docx", "data.xlsx"];
    final random = DateTime.now().millisecondsSinceEpoch % 4;

    setState(() {
      _attachments.add({
        "name": names[random],
        "type": types[random],
      });
    });

    CustomSnackbar.showCustomSnackbar(
      errorList: [],
      msg: ["${names[random]} attached"],
      isError: false,
    );
  }
}
