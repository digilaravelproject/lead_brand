import 'dart:async';
import 'package:get/get.dart';
import '../../../routes/route_helper.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage/shared_prefs.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    bool isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;
    if (isLoggedIn) {
      Get.offAllNamed(RouteHelper.getDashboardRoute());
    } else {
      Get.offAllNamed(RouteHelper.getLoginRoute());
    }
  }
}
