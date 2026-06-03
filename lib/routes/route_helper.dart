import 'package:get/get.dart';
import '../features/auth/login/login_screen.dart';
import '../features/auth/otp/otp_screen.dart';
import '../features/auth/bindings/auth_binding.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/splash/bindings/splash_binding.dart';
import '../features/dashboard/screens/main_screen.dart';
import '../features/profile/screens/profile_setup_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/plans/screens/combo_plan_screen.dart';
import '../features/gallery/screens/gallery_screen.dart';
import '../features/gallery/screens/image_viewer_screen.dart';
import '../../features/video_ads/screens/video_ads_screen.dart';
import '../../features/promotional_videos/screens/promotional_videos_screen.dart';
import '../../features/promotional_videos/screens/video_viewer_screen.dart';
import '../features/pdf_calendar/screens/pdf_calendar_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/settings/screens/faq_screen.dart';
import '../features/legal/screens/terms_condition_screen.dart';
import '../features/legal/screens/privacy_policy_screen.dart';
import '../features/legal/screens/about_us_screen.dart';
import '../features/legal/bindings/legal_binding.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/notifications/bindings/notifications_binding.dart';
import 'app_routes.dart';

class RouteHelper {
  static String getSplashRoute() => AppRoutes.splash;
  static String getLoginRoute() => AppRoutes.login;
  static String getOtpRoute() => AppRoutes.otp;
  static String getProfileSetupRoute() => AppRoutes.profileSetup;
  static String getDashboardRoute() => AppRoutes.dashboard;
  static String getComboPlanRoute() => AppRoutes.comboPlan;
  static String getGalleryRoute() => AppRoutes.gallery;
  static String getImageViewerRoute() => AppRoutes.imageViewer;
  static String getVideoAdsRoute() => AppRoutes.videoAds;
  static String getPdfCalendarRoute() => AppRoutes.pdfCalendar;
  static String getProfileRoute() => AppRoutes.profile;
  static String getSettingsRoute() => AppRoutes.settings;
  static String getLicPlansRoute() => AppRoutes.licPlans;
  static String getFaqRoute() => AppRoutes.faq;
  static String getTermsConditionRoute() => AppRoutes.termsCondition;
  static String getPrivacyPolicyRoute() => AppRoutes.privacyPolicy;
  static String getAboutUsRoute() => AppRoutes.aboutUs;
  static String getNotificationRoute() => AppRoutes.notifications;
  static String getPromotionalVideosRoute() => '/promotional-videos';
  static String getVideoPlayerRoute() => '/video-player';

  static List<GetPage> routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.profileSetup,
      page: () => const ProfileSetupScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const MainScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.comboPlan,
      page: () => const ComboPlanScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.gallery,
      page: () => const GalleryScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.imageViewer,
      page: () => const ImageViewerScreen(),
      transition: Transition.zoom,
    ),
    GetPage(
      name: AppRoutes.videoAds,
      page: () => const VideoAdsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.pdfCalendar,
      page: () => const PdfCalendarScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.faq,
      page: () => FaqScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.termsCondition,
      page: () => const TermsConditionScreen(),
      binding: LegalBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyScreen(),
      binding: LegalBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.aboutUs,
      page: () => const AboutUsScreen(),
      binding: LegalBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      binding: NotificationsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.licPlans,
      page: () => const ComboPlanScreen(), // Temporary using ComboPlanScreen as they are similar
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/promotional-videos',
      page: () => const PromotionalVideosScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/video-player',
      page: () => const VideoViewerScreen(),
      transition: Transition.zoom,
    ),
  ];
}
