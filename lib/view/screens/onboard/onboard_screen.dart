import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/core/utils/my_color.dart';
import 'package:play_lab/core/utils/my_images.dart';
import 'package:play_lab/core/utils/util.dart';

import 'widget/button_continue/button_continue.dart';
import 'widget/button_get_start/button_get_start.dart';
import 'widget/button_next/button_next.dart';
import 'widget/button_skip/button_skip.dart';
import 'widget/sub_title_widget/sub_title_widget.dart';
import 'widget/title_widget/title_widget.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final int totalPages = 3;
  late PageController _controller;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
    MyUtil.changeTheme();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // Listen to page changes
    _controller.addListener(() {
      int next = _controller.page!.round();
      if (currentPage != next) {
        setState(() {
          currentPage = next;
        });

        // AUTO GO TO LOGIN WHEN REACHING LAST PAGE
        if (currentPage == totalPages - 1) {
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              Get.offAndToNamed(RouteHelper.loginScreen);
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void gotoNextPage() {
    if (currentPage < totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      Get.offAndToNamed(RouteHelper.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            MyImages.bgImage,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),

          PageView.builder(
            controller: _controller,
            itemCount: totalPages,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(
                    top: 20, bottom: 50, left: 20, right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    TitleWidget(text: _getTitle(index)),
                    const SizedBox(height: 15),

                    // Subtitle
                    SubTitleWidget(text: _getSubtitle(index)),
                    const SizedBox(height: 30),

                    // Bottom Controls
                    if (index == totalPages - 1)
                      // Last Page → Continue Button
                      ButtonContinue(
                          press: () =>
                              Get.offAndToNamed(RouteHelper.loginScreen))
                    else if (index == 0)
                      // First Page → Get Started + Skip
                      Column(
                        children: [
                          ButtonGetStart(press: gotoNextPage),
                          const SizedBox(height: 20),
                          ButtonSkip(
                              press: () =>
                                  Get.offAndToNamed(RouteHelper.loginScreen)),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Page Indicators
                          SizedBox(
                            height: 12,
                            child: ListView.builder(
                              itemCount: totalPages,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, i) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: currentPage == i ? 24 : 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: currentPage == i
                                          ? MyColor.primaryColor
                                          : MyColor.colorWhite.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          ButtonNext(press: gotoNextPage),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Dummy titles & subtitles (replace with your real ones)
  String _getTitle(int index) {
    final titles = [
      "Watch Movies & Shows",
      "Stream Anywhere",
      "Unlimited Entertainment"
    ];
    return titles[index];
  }

  String _getSubtitle(int index) {
    final subtitles = [
      "Enjoy thousands of movies and TV shows on your device",
      "Watch offline, anytime, anywhere with downloads",
      "New content added weekly. Start watching now!"
    ];
    return subtitles[index];
  }
}
