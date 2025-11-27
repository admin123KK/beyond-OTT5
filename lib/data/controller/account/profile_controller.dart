import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_lab/core/route/route.dart';
import 'package:play_lab/data/model/country_model/country_model.dart';
import 'package:play_lab/data/model/global/global_user_model.dart';
import 'package:play_lab/data/model/global/response_model/response_model.dart';
import 'package:play_lab/environment.dart';
import 'package:play_lab/view/components/show_custom_snackbar.dart';

import '../../../constants/my_strings.dart';
import '../../../core/helper/shared_pref_helper.dart';
import '../../../core/utils/url_container.dart';
import '../../model/account/profile_response_model.dart';
import '../../model/account/user_post_model/user_post_model.dart';
import '../../repo/account/profile_repo.dart';

class ProfileController extends GetxController implements GetxService {
  final ProfileRepo profileRepo;

  ProfileResponseModel model = ProfileResponseModel();

  String imageStaticUrl = '';
  String callFrom = '';

  ProfileController({required this.profileRepo});

  List<String> errors = [];
  String imageUrl = '';
  String? currentPass, password, confirmPass;
  bool isLoading = false;

  String? countryName;
  String? countryCode;
  String? mobileCode;
  String? userName;
  String? phoneNo;

  // Text Controllers
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileNoController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  // Focus Nodes
  final FocusNode userNameFocusNode = FocusNode();
  final FocusNode firstNameFocusNode = FocusNode();
  final FocusNode lastNameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode mobileNoFocusNode = FocusNode();
  final FocusNode addressFocusNode = FocusNode();
  final FocusNode stateFocusNode = FocusNode();
  final FocusNode zipCodeFocusNode = FocusNode();
  final FocusNode cityFocusNode = FocusNode();
  final FocusNode countryFocusNode = FocusNode();

  File? imageFile;

  void addError({required String error}) {
    if (!errors.contains(error)) errors.add(error);
    update();
  }

  void removeError({required String error}) {
    if (errors.contains(error)) errors.remove(error);
    update();
  }

  Future<void> loadProfileInfo() async {
    isLoading = true;
    update();

    model = await profileRepo.loadProfileInfo();

    if (model.data != null && model.status == 'success') {
      loadData(model);
    }

    isLoading = false;
    await getCountryData();
    update();
  }

  Future<void> updateProfile(String callFrom) async {
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String address = addressController.text;
    String city = cityController.text;
    String zip = zipCodeController.text;
    String state = stateController.text;

    if (firstName.isEmpty) {
      addError(error: MyStrings.kFirstNameNullError);
      return;
    }
    if (lastName.isEmpty) {
      addError(error: MyStrings.kLastNameNullError);
      return;
    }

    isLoading = true;
    update();

    UserPostModel postModel = UserPostModel(
      image: imageFile,
      firstName: firstName,
      lastName: lastName,
      email: emailController.text,
      username: userNameController.text,
      address: address,
      state: state,
      zip: zip,
      city: city,
      mobile: mobileNoController.text,
      country: countryName ?? '',
      mobileCode: mobileCode?.replaceAll('[+]', '') ?? '',
      countryCode: countryCode ?? '',
    );

    bool success = await profileRepo.updateProfile(postModel, callFrom);

    if (success) {
      if (callFrom.toLowerCase() == 'profile_complete') {
        Get.offAllNamed(RouteHelper.homeScreen);
      } else {
        await loadProfileInfo();
      }
    }

    isLoading = false;
    update();
  }

  bool submitLoading = false;

  Future<void> completeProfile() async {
    if (userNameController.text.isEmpty) {
      CustomSnackbar.showCustomSnackbar(
        errorList: [MyStrings.enterYourUsername],
        msg: [],
        isError: true,
      );
      return;
    }

    submitLoading = true;
    update();

    GlobalUser? user = model.data?.user;

    UserPostModel userPostModel = UserPostModel(
      image: null,
      firstName: user?.firstName ?? '',
      lastName: user?.lastName ?? '',
      email: user?.email ?? '',
      username: userNameController.text,
      address: addressController.text,
      state: stateController.text,
      zip: zipCodeController.text,
      city: cityController.text,
      mobile: mobileNoController.text,
      country: countryName ?? '',
      mobileCode: mobileCode?.replaceAll('[+]', '') ?? '',
      countryCode: countryCode ?? '',
    );

    final responseModel = await profileRepo.completeProfile(userPostModel);

    submitLoading = false;
    update();

    if (responseModel.status?.toLowerCase() ==
        MyStrings.success.toLowerCase()) {
      clearData();
      checkAndGotoNextStep(responseModel.data?.user);
      CustomSnackbar.showCustomSnackbar(
        msg: responseModel.message?.success ?? [MyStrings.success.tr],
        errorList: [],
        isError: false,
      );
    } else {
      CustomSnackbar.showCustomSnackbar(
        errorList:
            responseModel.message?.error ?? [MyStrings.somethingWentWrong.tr],
        msg: [],
        isError: true,
      );
    }
  }

  void loadData(ProfileResponseModel? model) {
    if (model?.data?.user == null) return;

    final user = model!.data!.user!;
    imageUrl = user.image != null
        ? '${UrlContainer.baseUrl}/assets/images/user/profile/${user.image}'
        : '';

    firstNameController.text = user.firstName ?? '';
    lastNameController.text = user.lastName ?? '';
    emailController.text = user.email ?? '';
    mobileNoController.text = (user.mobile ?? '').replaceAll('null', '');
    addressController.text = user.address ?? '';
    stateController.text = user.state ?? '';
    zipCodeController.text = user.zip ?? '';
    cityController.text = user.city ?? '';
    countryController.text = user.country ?? '';

    // Save username for global use
    profileRepo.apiClient.sharedPreferences.setString(
      SharedPreferenceHelper.userNameKey,
      '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
    );

    isLoading = false;
    update();
  }

  void checkAndGotoNextStep(GlobalUser? user) async {
    if (user == null) return;

    bool needEmailVerification = user.ev != "1";
    bool needSmsVerification = user.sv != "1";

    // Save user data locally
    await profileRepo.apiClient.sharedPreferences
        .setString(SharedPreferenceHelper.userEmailKey, user.email ?? '');
    await profileRepo.apiClient.sharedPreferences
        .setString(SharedPreferenceHelper.userIDKey, user.id.toString());
    await profileRepo.apiClient.sharedPreferences
        .setString(SharedPreferenceHelper.phoneNumberKey, user.mobile ?? '');
    await profileRepo.apiClient.sharedPreferences
        .setString(SharedPreferenceHelper.userNameKey, user.username ?? '');
    await profileRepo.apiClient.sharedPreferences
        .setString(SharedPreferenceHelper.userImageKey, user.image ?? '');

    // FIREBASE sendUserToken() REMOVED → Replaced with safe placeholder
    // Later: Call your new push system here
    await profileRepo.initializePushNotificationToken();

    if (needEmailVerification) {
      Get.offAndToNamed(RouteHelper.emailVerificationScreen);
    } else if (needSmsVerification) {
      Get.offAndToNamed(RouteHelper.smsVerificationScreen);
    } else {
      Get.offAllNamed(RouteHelper.homeScreen);
    }
  }

  // Country Picker Logic
  final TextEditingController searchCountryController = TextEditingController();
  bool countryLoading = true;
  List<Countries> countryList = [];
  List<Countries> filteredCountries = [];

  String dialCode = Environment.defaultPhoneCode;

  void updateMobilecode(String code) {
    dialCode = code;
    update();
  }

  Future<void> getCountryData() async {
    countryLoading = true;
    update();

    ResponseModel response = await profileRepo.getCountryList();

    if (response.statusCode == 200) {
      CountryModel countryModel =
          CountryModel.fromJson(jsonDecode(response.responseJson));
      List<Countries>? tempList = countryModel.data?.countries;

      if (tempList != null && tempList.isNotEmpty) {
        countryList = tempList;
        filteredCountries = tempList;

        final defaultCountry = tempList.firstWhere(
          (c) =>
              c.countryCode?.toLowerCase() ==
              Environment.defaultCountryCode.toLowerCase(),
          orElse: () => tempList[0],
        );

        if (defaultCountry.dialCode != null) {
          setCountryNameAndCode(
            defaultCountry.country ?? '',
            defaultCountry.countryCode ?? '',
            defaultCountry.dialCode ?? '',
          );
          selectCountryData(defaultCountry);
        }
      }
    } else {
      CustomSnackbar.showCustomSnackbar(
          errorList: [response.message], msg: [], isError: true);
    }

    countryLoading = false;
    update();
  }

  void setCountryNameAndCode(String cName, String cCode, String mCode) {
    countryName = cName;
    countryCode = cCode;
    mobileCode = mCode;
    update();
  }

  Countries selectedCountryData = Countries();
  void selectCountryData(Countries value) {
    selectedCountryData = value;
    update();
  }

  void clearData() {
    userNameController.clear();
    mobileNoController.clear();
    countryCode = null;
    mobileCode = null;
  }

  @override
  void onClose() {
    // Dispose controllers & focus nodes
    userNameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    mobileNoController.dispose();
    addressController.dispose();
    stateController.dispose();
    zipCodeController.dispose();
    cityController.dispose();
    countryController.dispose();
    searchCountryController.dispose();

    userNameFocusNode.dispose();
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    emailFocusNode.dispose();
    mobileNoFocusNode.dispose();
    addressFocusNode.dispose();
    stateFocusNode.dispose();
    zipCodeFocusNode.dispose();
    cityFocusNode.dispose();
    countryFocusNode.dispose();

    super.onClose();
  }
}
