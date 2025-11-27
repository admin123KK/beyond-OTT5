import 'dart:async';
import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:play_lab/core/helper/shared_pref_helper.dart';
import 'package:play_lab/core/utils/dimensions.dart';
import 'package:play_lab/core/utils/styles.dart';
import 'package:play_lab/core/utils/url_container.dart';
import 'package:play_lab/data/model/play_video_response_model/play_video_response_model.dart';
import 'package:play_lab/data/model/video_details/video_details_response_model/video_details_response_model.dart';
import 'package:play_lab/data/model/wishlist_model/add_in_wishlist_response_model.dart';
import 'package:play_lab/data/repo/movie_details_repo/movie_details_repo.dart';
import 'package:play_lab/view/components/dialog/login_dialog.dart';
import 'package:play_lab/view/components/dialog/subscribe_now_dialog.dart';
import 'package:play_lab/view/components/show_custom_snackbar.dart';
import 'package:video_player/video_player.dart';

import '../../../constants/my_strings.dart';
import '../../../core/route/route.dart';
import '../../../core/utils/my_color.dart';

class MovieDetailsController extends GetxController {
  MovieDetailsRepo movieDetailsRepo;

  MovieDetailsController({
    required this.movieDetailsRepo,
    required this.itemId,
    this.episodeId = -1,
  });

  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;

  void _onProgressUpdate() {
    final currentPosition = videoPlayerController.value.position.inSeconds;
    final duration = videoPlayerController.value.duration.inSeconds;

    if (duration > 0 && currentPosition >= duration) {
      videoPlayerController.pause();
      chewieController?.pause();
    }

    isShowBackBtn = videoPlayerController.value.isPlaying ? false : true;
    update();
  }

  Future<void> initializePlayer(String url,
      {required Duration playDuration}) async {
    await loadSubtitles();

    videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(url),
      videoPlayerOptions: VideoPlayerOptions(),
    );

    await videoPlayerController.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      aspectRatio: 16 / 9,
      autoPlay: false,
      autoInitialize: true,
      startAt: playDuration,
      allowedScreenSleep: false,
      showControlsOnInitialize: false,
      showControls: true,
      allowFullScreen: true,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
      errorBuilder: (context, errorMessage) {
        String msg = MyStrings.unknownVideoError;
        if (errorMessage.contains('VideoError')) {
          msg = MyStrings.videoSourceError;
        } else if (errorMessage.contains('PlatformException')) {
          msg = MyStrings.platformSpecificError;
        }
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              msg.tr,
              style: mulishBold.copyWith(color: MyColor.colorWhite),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
      subtitleBuilder: (context, subtitle) {
        final position = videoPlayerController.value.position;
        final activeSubtitle = selectedSubtitleDataList.firstWhere(
          (s) => s.start <= position && s.end >= position,
          orElse: () => Subtitle(
              start: Duration.zero, end: Duration.zero, text: '', index: 0),
        );

        if (activeSubtitle.text.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(10),
          child: Text(
            activeSubtitle.text,
            style: mulishRegular
                .copyWith(color: MyColor.colorWhite, shadows: const [
              Shadow(blurRadius: 10, color: Colors.black87),
            ]),
            textAlign: TextAlign.center,
          ),
        );
      },
      subtitle: Subtitles(selectedSubtitleDataList),
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.white,
        handleColor: Colors.white,
        backgroundColor: Colors.white.withOpacity(0.5),
        bufferedColor: Colors.white.withOpacity(0.3),
      ),
      // additionalOptions: (context) {
      // return <OptionItem>[
      //   if (subTitleLangList.isNotEmpty)
      //     // OptionItem(
      //     //   // onTap: (){
      //     //   //   // _showSubtitleSelectionBottomSheet(context);
      //     //   // },
      //     //   iconData: Icons.subtitles,
      //     //   title: MyStrings.subtitles.tr,
      //     // ),
      // ];
      // },
    );

    videoPlayerController.addListener(_onProgressUpdate);
    videoUrl = url;
    playVideoLoading = false;
    update();
  }

  // Fixed: Async logic moved here
  void _showSubtitleSelectionBottomSheet(BuildContext context) async {
    await Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(
          top: Dimensions.space20,
          left: Dimensions.space15,
          right: Dimensions.space15,
          bottom: Dimensions.space50,
        ),
        decoration: const BoxDecoration(
          color: MyColor.secondaryColor,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(Dimensions.space10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              MyStrings.selectALanguage.tr,
              style: mulishSemiBold.copyWith(
                  fontSize: Dimensions.fontLarge, color: MyColor.colorWhite),
            ),
            const SizedBox(height: 25),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subTitleLangList.length,
              itemBuilder: (ctx, index) {
                final lang = subTitleLangList[index];
                final isSelected = lang == selectedSubTitle;

                return GestureDetector(
                  onTap: () async {
                    Get.back(); // Close bottom sheet
                    changeSubtitleLang(lang);
                    await loadSubtitles();

                    // Refresh subtitles in player
                    chewieController
                        ?.setSubtitle(getSubtitlesData(subtitleString));

                    // Force UI refresh
                    Future.delayed(const Duration(milliseconds: 100), () {
                      chewieController?.play();
                      chewieController?.pause();
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: Dimensions.space15),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? MyColor.primaryColor.withOpacity(0.8)
                          : MyColor.shimmerBaseColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected
                            ? MyColor.primaryColor.withOpacity(0.8)
                            : MyColor.shimmerBaseColor,
                      ),
                    ),
                    child: Text(
                      lang.language ?? 'Unknown',
                      style: mulishSemiBold.copyWith(color: MyColor.colorWhite),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // Video Quality
  List<VideoQuality> videoQualityList = [];
  VideoQuality selectedVideoQuality = VideoQuality();

  Future<void> changeVideoQuality(
      {required VideoQuality quality,
      required Duration currentDuration}) async {
    selectedVideoQuality = quality;
    update();
    await initializePlayer(quality.content ?? '',
        playDuration: currentDuration);
  }

  void changeVideoDuration(Duration duration) {
    videoPlayerController.seekTo(duration);
    update();
  }

  Map<String, String> adsTime = {};

  Future<void> loadVideoUrl() async {
    playVideoLoading = true;
    videoQualityList.clear();
    update();

    final model =
        await movieDetailsRepo.getVideoData(itemId, episodeId: episodeId);

    if (model.statusCode == 200) {
      final responseModel =
          PlayVideoResponseModel.fromJson(jsonDecode(model.responseJson));

      if (responseModel.data?.video?.isNotEmpty ?? false) {
        subTitleLangList = responseModel.data?.subtitles ?? [];
        if (subTitleLangList.isNotEmpty) selectedSubTitle = subTitleLangList[0];

        videoQualityList.addAll(responseModel.data?.video ?? []);
        selectedVideoQuality = videoQualityList.first;
        adsTime = responseModel.data?.adsTime ?? {};

        await initializePlayer(selectedVideoQuality.content ?? '',
            playDuration: const Duration(seconds: 0));
      } else if (responseModel.remark == 'unauthorized_rent') {
        isNeedToRent = true;
        playerImage = movieDetails.data?.item?.image?.landscape ?? '';
        playerAssetPath = movieDetails.data?.landscapePath ?? '';
      } else if (responseModel.remark == 'unauthorized_paid') {
        isAuthorized()
            ? showSubscribeDialog(Get.context!)
            : showLoginDialog(Get.context!);
      } else {
        lockVideo = true;
        CustomSnackbar.showCustomSnackbar(
          errorList:
              responseModel.message?.error ?? [MyStrings.somethingWentWrong],
          msg: [],
          isError: true,
        );
      }
    } else {
      lockVideo = true;
      CustomSnackbar.showCustomSnackbar(
          errorList: [model.message], msg: [], isError: true);
    }

    playVideoLoading = false;
    update();
  }

  String videoUrl = '';
  String currency = '';
  String currencySym = '';
  String userId = '';

  bool isDescriptionShow = true;
  bool isTeamShow = false;
  late int itemId;
  late int episodeId;

  bool playVideoLoading = true;
  bool videoDetailsLoading = true;
  bool isEpisode = false;
  String portraitImagePath = '';
  String episodePath = '';

  List<RelatedItems> relatedItemsList = [];
  List<Episodes> episodeList = [];
  VideoDetailsResponseModel movieDetails = VideoDetailsResponseModel();

  Future<void> initData(int itemId, int episodeId) async {
    currency =
        movieDetailsRepo.apiClient.getCurrencyOrUsername(isCurrency: true);
    currencySym =
        movieDetailsRepo.apiClient.getCurrencyOrUsername(isSymbol: true);
    userId = movieDetailsRepo.apiClient.sharedPreferences
            .getString(SharedPreferenceHelper.userIDKey) ??
        '';

    this.itemId = itemId;
    this.episodeId = episodeId;

    playVideoLoading = true;
    update();

    await Future.wait([
      loadVideoDetails(),
      if (isAuthorized()) checkWishlist(),
    ]);
  }

  bool isNeedToRent = false;
  bool isNeedToPurchase = false;

  Future<void> loadVideoDetails() async {
    videoDetailsLoading = true;
    update();

    final response = await movieDetailsRepo.getVideoDetails(itemId,
        episodeId: episodeId == -1 ? -1 : episodeId);

    if (response.statusCode == 200) {
      final model =
          VideoDetailsResponseModel.fromJson(jsonDecode(response.responseJson));

      if (model.status?.toLowerCase() == 'success' &&
          model.data?.item != null) {
        movieDetails = model;
        playerImage = model.data!.item!.image!.landscape ?? '';
        playerAssetPath = model.data!.landscapePath ?? '';

        relatedItemsList = model.data?.relatedItems ?? [];
        portraitImagePath = model.data?.portraitPath ?? '';
        episodePath = model.data?.episodePath ?? '';
        episodeList = model.data?.episodes ?? [];

        if (episodeList.isNotEmpty && episodeId == -1) {
          episodeId = episodeList[0].id ?? -1;
        }

        lockVideo = false;
        await loadVideoUrl();
      } else {
        // Handle unauthorized, rent, purchase cases...
        lockVideo = true;
        playVideoLoading = false;
      }
    } else {
      lockVideo = true;
      playVideoLoading = false;
      CustomSnackbar.showCustomSnackbar(
          errorList: [response.message], msg: [], isError: true);
    }

    videoDetailsLoading = false;
    update();
  }

  bool isFavourite = false;
  bool showWishlistBtn = false;
  bool wishListLoading = false;
  String playerImage = '';
  String playerAssetPath = '';
  bool lockVideo = false;

  Future<void> checkWishlist() async {
    wishListLoading = true;
    showWishlistBtn = false;
    update();

    isFavourite =
        await movieDetailsRepo.checkWishlist(itemId, episodeId: episodeId);
    showWishlistBtn = true;
    wishListLoading = false;
    update();
  }

  void addInWishList() async {
    wishListLoading = true;
    update();

    final model = isFavourite
        ? await movieDetailsRepo.removeFromWishList(itemId,
            episodeId: episodeId)
        : await movieDetailsRepo.addInWishList(itemId, episodeId: episodeId);

    if (model.statusCode == 200) {
      final res =
          AddInWishlistResponseModel.fromJson(jsonDecode(model.responseJson));
      isFavourite = res.remark == 'added_successfully';
    }

    wishListLoading = false;
    update();
  }

  bool isBuyPlanClick = false;
  bool isCreatePartyLoading = false;

  void rentVideo() async {
    // ... your rent logic
  }

  Future<void> createParty(String episodeId, String partyCode,
      {required String itemId}) async {
    // ... your party logic
  }

  void gotoNextPage(int id, int episodeId) async {
    if (!isNeedToRent) await clearData();
    Get.offAndToNamed(RouteHelper.movieDetailsScreen,
        arguments: [id, episodeId]);
  }

  Future<void> clearData() async {
    if (!isNeedToRent) {
      chewieController?.dispose();
      videoPlayerController.dispose();
      await clearCache();
    }

    isEpisode = false;
    playVideoLoading = true;
    videoDetailsLoading = true;
    lockVideo = false;
    videoUrl = '';
    relatedItemsList.clear();
    episodeList.clear();
    update();
  }

  Future<void> clearCache() async {
    try {
      await DefaultCacheManager().emptyCache();
      final dir = await getTemporaryDirectory();
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (e) {
      if (kDebugMode) print('Cache clear error: $e');
    }
  }

  bool isAuthorized() {
    return movieDetailsRepo.apiClient.sharedPreferences
            .getString(SharedPreferenceHelper.accessTokenKey)
            ?.isNotEmpty ??
        false;
  }

  // Subtitles
  List<Subtitle> selectedSubtitleDataList = [];
  String subtitleString = '';
  bool isShowBackBtn = false;

  Future<void> loadSubtitles() async {
    try {
      final fileUrl = selectedSubTitle.file;
      if (fileUrl == null || fileUrl.isEmpty) return;

      final url = '${UrlContainer.baseUrl}assets/subtitles/$fileUrl';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        subtitleString = utf8.decode(response.bodyBytes);
        selectedSubtitleDataList = getSubtitlesData(subtitleString);
      }
    } catch (e) {
      if (kDebugMode) print('Subtitle load error: $e');
    }
    update();
  }

  List<SubtitleModel> subTitleLangList = [];
  SubtitleModel selectedSubTitle = SubtitleModel();

  void changeSubtitleLang(SubtitleModel subtitle) {
    selectedSubTitle = subtitle;
    update();
  }

  void changeIsTeamVisibility(bool value) {
    isTeamShow = value;
    update();
  }
}

// Subtitle Parser (unchanged)
List<Subtitle> getSubtitlesData(String content) {
  final regExp = RegExp(
    r'(\d{2}:\d{2}:\d{2},\d{3}) --> (\d{2}:\d{2}:\d{2},\d{3})\s+([\s\S]*?)(?=\r?\n\r?\n|\r?\n?$)',
    multiLine: true,
  );

  final List<Subtitle> subtitles = [];

  for (final match in regExp.allMatches(content)) {
    final start = _parseDuration(match.group(1)!);
    final end = _parseDuration(match.group(2)!);
    final text = match.group(3)!.trim();

    subtitles.add(Subtitle(
      index: subtitles.length,
      start: start,
      end: end,
      text: removeAllHtmlTags(text),
    ));
  }

  return subtitles;
}

Duration _parseDuration(String time) {
  final parts = time.split(':');
  final ms = int.parse(parts[2].split(',').last);
  return Duration(
    hours: int.parse(parts[0]),
    minutes: int.parse(parts[1]),
    seconds: int.parse(parts[2].split(',').first),
    milliseconds: ms,
  );
}

String removeAllHtmlTags(String htmlText) {
  return htmlText.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&nbsp;', ' ');
}
