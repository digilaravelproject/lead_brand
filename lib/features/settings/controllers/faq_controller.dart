import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/custom_snackbar.dart';

class FaqModel {
  final int id;
  final String question;
  final String answer;

  FaqModel({required this.id, required this.question, required this.answer});

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
    );
  }
}

class FaqController extends GetxController {
  final ApiClient apiClient = Get.find<ApiClient>();
  
  final faqsList = <FaqModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFaqs();
  }

  Future<void> fetchFaqs() async {
    isLoading.value = true;
    try {
      final response = await apiClient.get(AppConstants.faqsUrl);
      if (response.isSuccess && response.body != null) {
        final List<dynamic> faqsJson = response.body['faqs'] ?? [];
        faqsList.assignAll(faqsJson.map((e) => FaqModel.fromJson(e)).toList());
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      CustomSnackbar.showError('Failed to load FAQs.');
    } finally {
      isLoading.value = false;
    }
  }
}
