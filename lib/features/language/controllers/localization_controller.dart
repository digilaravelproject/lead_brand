import 'package:bless_app/core/constants/image_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../domain/models/language_model.dart';
import '../widget/language_bottom_sheet.dart';

class LocalizationController extends GetxController {
  final _selectedIndex = 0.obs;
  final _languages = <LanguageModel>[].obs;

  int get selectedIndex => _selectedIndex.value;
  List<LanguageModel> get languages => _languages;

  @override
  void onInit() {
    super.onInit();
    _languages.addAll([
      LanguageModel(
        imageUrl: ImageConstants.english,
        languageName: 'English',
        languageCode: 'en',
        countryCode: 'US',
      ),
      LanguageModel(
        imageUrl: ImageConstants.hindi,
        languageName: 'Hindi',
        languageCode: 'hi',
        countryCode: 'IN',
      ),
      LanguageModel(
        imageUrl: ImageConstants.hindi,
        languageName: 'Marathi',
        languageCode: 'mr',
        countryCode: 'IN',
      ),
      LanguageModel(
        imageUrl: ImageConstants.hindi,
        languageName: 'Gujarati',
        languageCode: 'gr',
        countryCode: 'IN',
      ),
    ]);
  }

  Future<void> initLanguage() async {
    final languageCode = SharedPrefs.getString(AppConstants.language) ?? 'en';
    final index = _languages.indexWhere((element) => element.languageCode == languageCode);

    if (index != -1) {
      _selectedIndex.value = index;
      setLanguage(_languages[index]);
    }
  }

  void setLanguage(LanguageModel language) {
    final index = _languages.indexWhere((element) => element.languageCode == language.languageCode);

    if (index != -1) {
      _selectedIndex.value = index;

      Get.updateLocale(Locale(
        language.languageCode,
        language.countryCode,
      ));

      SharedPrefs.setString(AppConstants.language, language.languageCode);
    }
  }

  Future<void> changeLanguage(LanguageModel language) async {
    // Show a loading dialog
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(
        '/api/user/language',
        data: {'language': language.languageCode},
      );

      // Dismiss loading dialog safely using Navigator pop
      if (Get.overlayContext != null) {
        Navigator.of(Get.overlayContext!).pop();
      } else {
        Get.back();
      }

      if (response.isSuccess) {
        setLanguage(language);
        CustomSnackbar.showSuccess('Language updated successfully');
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      // Dismiss loading dialog safely if still open
      if (Get.overlayContext != null) {
        try {
          Navigator.of(Get.overlayContext!).pop();
        } catch (_) {}
      }
      debugPrint('Error changing language: $e');
      CustomSnackbar.showError('Failed to update language');
    }
  }

  void showLanguageBottomSheet(BuildContext context) {
    Get.bottomSheet(
      LanguageBottomSheet(controller: this),
      isScrollControlled: true,
    );
  }
}
