import 'package:get/get.dart';
import '../../../routes/route_helper.dart';

class PlansController extends GetxController {
  final List<String> comboPlans = [
    'Child Plan',
    'General Plan',
    'Retirement Plan',
  ];

  final List<String> licPlans = [
    'Children Plans',
    'Endowment Plans',
    'Health Plans',
    'Money Back Plans',
    'Pension Plans',
    'Single Premium Plans',
    'Term Plans',
  ];

  final RxList<String> currentPlans = <String>[].obs;
  final RxString title = 'Select Plan'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPlans();
  }

  void _loadPlans() {
    final route = Get.currentRoute;
    if (route.contains('combo')) {
      currentPlans.assignAll(comboPlans);
      title.value = 'Select Combo Plan';
    } else {
      currentPlans.assignAll(licPlans);
      title.value = 'Select LIC Plan';
    }
  }

  void selectPlan(String plan) {
    Get.toNamed(RouteHelper.getGalleryRoute(), arguments: plan);
  }
}
