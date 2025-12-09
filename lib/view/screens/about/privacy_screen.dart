import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:dio/dio.dart';
import 'package:play_lab/constants/api.dart';

import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/styles.dart';
import '../../../constants/my_strings.dart';
import '../../../core/route/route.dart'; // Make sure this has ApiConstants
import '../../../core/utils/url_container.dart'; // Usually where ApiConstants lives
import '../../components/app_bar/custom_appbar.dart';
import '../../components/buttons/category_button.dart';

// Simple shimmer (replace with your real one if needed)
class PrivacyPolicyShimmer extends StatelessWidget {
  const PrivacyPolicyShimmer({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: MyColor.primaryColor),
    );
  }
}

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final RxList<Map<String, dynamic>> policyList = <Map<String, dynamic>>[].obs;
  final RxInt selectedIndex = 0.obs;
  final RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    fetchPolicies();
  }

  Future<void> fetchPolicies() async {
    try {
      isLoading.value = true;

      final response = await Dio().get(ApiConstants.policiesEndpoint);

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List policies = response.data['data']['policies'];
        policyList.assignAll(policies.cast<Map<String, dynamic>>());
      } else {
        Get.snackbar("Error", "Failed to load policies");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: MyColor.secondaryColor,
          appBar: CustomAppBar(
            title: MyStrings.policies.tr.capitalizeFirst ?? 'Policies',
          ),
          body: isLoading.value
              ? const PrivacyPolicyShimmer()
              : policyList.isEmpty
                  ? const Center(
                      child: Text("No policies available",
                          style: TextStyle(color: Colors.white70)))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          // Top Horizontal Buttons
                          Padding(
                            padding: const EdgeInsets.only(left: 12, top: 12),
                            child: SizedBox(
                              height: 50,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children:
                                      policyList.asMap().entries.map((entry) {
                                    int idx = entry.key;
                                    var policy = entry.value;
                                    String title = policy['data_values']
                                            ?['title'] ??
                                        'Policy';

                                    return Row(
                                      children: [
                                        CategoryButton(
                                          text: title,
                                          textSize: Dimensions.fontDefault,
                                          horizontalPadding: 15,
                                          verticalPadding: 9,
                                          color: selectedIndex.value == idx
                                              ? MyColor.primaryColor
                                              : MyColor.bodyTextColor,
                                          press: () =>
                                              selectedIndex.value = idx,
                                        ),
                                        const SizedBox(width: 10),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),

                          // Selected Policy HTML Content
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: HtmlWidget(
                              policyList[selectedIndex.value]['data_values']
                                      ?['description'] ??
                                  '',
                              textStyle: mulishSemiBold.copyWith(
                                color: MyColor.colorWhite,
                                fontSize: Dimensions.fontLarge,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
        ));
  }
}
