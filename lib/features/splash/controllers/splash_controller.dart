import 'dart:async';
import 'package:get/get.dart';
import '../../../routes/route_helper.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    Get.offAllNamed(RouteHelper.getLoginRoute());
  }
}
