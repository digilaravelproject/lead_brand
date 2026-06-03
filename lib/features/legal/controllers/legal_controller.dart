import 'package:get/get.dart';
import '../domain/models/legal_page_model.dart';
import '../domain/usecases/get_page_usecase.dart';
import '../../../../core/utils/custom_snackbar.dart';

class LegalController extends GetxController {
  final GetPageUseCase getPageUseCase;

  LegalController({required this.getPageUseCase});

  final termsPage = Rxn<LegalPageModel>();
  final privacyPage = Rxn<LegalPageModel>();
  final aboutUsPage = Rxn<LegalPageModel>();
  final isTermsLoading = false.obs;
  final isPrivacyLoading = false.obs;
  final isAboutUsLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTermsCondition();
    fetchPrivacyPolicy();
    fetchAboutUs();
  }

  Future<void> fetchTermsCondition() async {
    isTermsLoading.value = true;
    try {
      final response = await getPageUseCase.getTermsCondition();
      if (response.isSuccess && response.body != null) {
        final pageData = response.body['page'];
        if (pageData != null) {
          termsPage.value = LegalPageModel.fromJson(pageData);
        }
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      CustomSnackbar.showError('Failed to load Terms & Conditions.');
    } finally {
      isTermsLoading.value = false;
    }
  }

  Future<void> fetchPrivacyPolicy() async {
    isPrivacyLoading.value = true;
    try {
      final response = await getPageUseCase.getPrivacyPolicy();
      if (response.isSuccess && response.body != null) {
        final pageData = response.body['page'];
        if (pageData != null) {
          privacyPage.value = LegalPageModel.fromJson(pageData);
        }
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      CustomSnackbar.showError('Failed to load Privacy Policy.');
    } finally {
      isPrivacyLoading.value = false;
    }
  }

  Future<void> fetchAboutUs() async {
    isAboutUsLoading.value = true;
    try {
      final response = await getPageUseCase.getAboutUs();
      if (response.isSuccess && response.body != null) {
        final pageData = response.body['page'];
        if (pageData != null) {
          aboutUsPage.value = LegalPageModel.fromJson(pageData);
        }
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      CustomSnackbar.showError('Failed to load About Us.');
    } finally {
      isAboutUsLoading.value = false;
    }
  }
}
