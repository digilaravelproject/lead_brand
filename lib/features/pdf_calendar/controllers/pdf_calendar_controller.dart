import 'package:get/get.dart';

class PdfCalendarController extends GetxController {
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxInt selectedYear = DateTime.now().year.obs;
  
  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  final List<int> years = List.generate(5, (index) => DateTime.now().year + index);

  void updateMonth(int? month) {
    if (month != null) selectedMonth.value = month;
  }

  void updateYear(int? year) {
    if (year != null) selectedYear.value = year;
  }
}
