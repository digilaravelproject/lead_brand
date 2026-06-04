import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/route_helper.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/constants/app_constants.dart';

class DashboardController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentBannerIndex = 0.obs;
  final RxList<String> bannerImages = <String>[].obs;
  final RxBool isBannersLoading = false.obs;

  final List<String> _fallbackBanners = [
    "https://images.unsplash.com/photo-1542744173-8e7e53415bb0?q=80&w=600&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1460925895917-afdab827c52f?q=80&w=600&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1557804506-669a67965ba0?q=80&w=600&auto=format&fit=crop",
  ];

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
    _startAutoPlay();
  }

  Future<void> fetchBanners() async {
    isBannersLoading.value = true;
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.get(AppConstants.bannersUrl);
      if (response.isSuccess && response.body != null) {
        List<dynamic>? data;
        if (response.body is List) {
          data = response.body as List;
        } else if (response.body is Map && response.body['data'] is List) {
          data = response.body['data'] as List;
        }
        if (data != null) {
          final urls = data
              .map((item) => item['image_url'] as String?)
              .whereType<String>()
              .toList();
          if (urls.isNotEmpty) {
            bannerImages.assignAll(urls);
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching banners: $e');
    } finally {
      isBannersLoading.value = false;
      if (bannerImages.isEmpty) {
        bannerImages.assignAll(_fallbackBanners);
      }
    }
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 4), () {
      if (pageController.hasClients) {
        if (bannerImages.isNotEmpty) {
          int nextPage = (currentBannerIndex.value + 1) % bannerImages.length;
          pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        }
        _startAutoPlay();
      }
    });
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  final List<DashboardFeature> features = [
    DashboardFeature(
      title: 'Combo King',
      icon: Icons.auto_awesome_motion,
      route: RouteHelper.getComboPlanRoute(),
      color: Colors.blue,
    ),
    DashboardFeature(
      title: 'Combo Poster',
      icon: Icons.dashboard_customize,
      route: RouteHelper.getGalleryRoute(), // Using gallery as a placeholder
      color: Colors.lightBlue,
    ),
    DashboardFeature(
      title: 'Concept Brochures',
      icon: Icons.menu_book,
      route: RouteHelper.getGalleryRoute(),
      color: Colors.orange,
    ),
    DashboardFeature(
      title: 'LIC Plans',
      icon: Icons.description,
      route: RouteHelper.getLicPlansRoute(),
      color: Colors.green,
    ),
    DashboardFeature(
      title: 'Agent Recruitment',
      icon: Icons.person_add,
      route: RouteHelper.getGalleryRoute(),
      color: Colors.purple,
    ),
    DashboardFeature(
      title: 'Promotional Videos',
      icon: Icons.play_circle_filled,
      route: '/promotional-videos',
      color: Colors.red,
    ),
    DashboardFeature(
      title: 'Create Video Ads',
      icon: Icons.video_call,
      route: RouteHelper.getVideoAdsRoute(),
      color: Colors.indigo,
    ),
    DashboardFeature(
      title: 'Create PDF Calendar',
      icon: Icons.calendar_today,
      route: RouteHelper.getPdfCalendarRoute(),
      color: Colors.teal,
    ),
  ];

  void navigateToFeature(String route) {
    Get.toNamed(route);
  }

  void openProfile() {
    Get.toNamed(RouteHelper.getProfileRoute());
  }
}

class DashboardFeature {
  final String title;
  final IconData icon;
  final String route;
  final Color color;

  DashboardFeature({
    required this.title,
    required this.icon,
    required this.route,
    required this.color,
  });
}
