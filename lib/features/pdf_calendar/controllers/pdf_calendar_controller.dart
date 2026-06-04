import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';

class PdfCalendarController extends GetxController {
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxBool isLoading = false.obs;
  final RxBool isPdfLoading = false.obs;
  final RxString pdfUrl = ''.obs;
  
  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  final List<int> years = List.generate(5, (index) => DateTime.now().year + index);

  @override
  void onInit() {
    super.onInit();
    generateCalendar(selectedYear.value);
  }

  void updateMonth(int? month) {
    if (month != null) selectedMonth.value = month;
  }

  void updateYear(int? year) {
    if (year != null) selectedYear.value = year;
  }

  Future<void> generateCalendar(int year) async {
    isLoading.value = true;
    pdfUrl.value = '';
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/api/calendar', queryParameters: {'year': year});
      if (response.isSuccess && response.body != null) {
        final String? url = response.body['pdf_url'] ?? response.body['data']?['pdf_url'];
        if (url != null && url.isNotEmpty) {
          if (pdfUrl.value == url) {
            isPdfLoading.value = false;
          } else {
            isPdfLoading.value = true;
            pdfUrl.value = url;
          }
        } else {
          Get.snackbar(
            'Error',
            'PDF URL not found in response',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          response.message.isNotEmpty ? response.message : 'Failed to fetch calendar PDF',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate calendar: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
