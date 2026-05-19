import 'package:get/get.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/splash/controllers/splash_controller.dart';
import '../services/network/api_client.dart';
import '../../features/dashboard/controllers/dashboard_controller.dart';
import '../../features/plans/controllers/plans_controller.dart';
import '../../features/gallery/controllers/gallery_controller.dart';
import '../../features/video_ads/controllers/video_ads_controller.dart';
import '../../features/pdf_calendar/controllers/pdf_calendar_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Core services
    Get.lazyPut(() => ApiClient(), fenix: true);

    // Auth
    Get.lazyPut(() => AuthController(), fenix: true);
    
    // Dashboard
    Get.lazyPut(() => DashboardController(), fenix: true);
    
    // Plans
    Get.lazyPut(() => PlansController(), fenix: true);
    
    // Gallery
    Get.lazyPut(() => GalleryController(), fenix: true);
    
    // Video Ads
    Get.lazyPut(() => VideoAdsController(), fenix: true);
    
    // PDF Calendar
    Get.lazyPut(() => PdfCalendarController(), fenix: true);
  }
}
