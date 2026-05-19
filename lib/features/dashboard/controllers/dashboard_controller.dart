import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/route_helper.dart';

class DashboardController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentBannerIndex = 0.obs;

  final List<String> bannerImages = [
    "https://images.unsplash.com/photo-1542744173-8e7e53415bb0?q=80&w=600&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1460925895917-afdab827c52f?q=80&w=600&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1557804506-669a67965ba0?q=80&w=600&auto=format&fit=crop",
  ];

  @override
  void onInit() {
    super.onInit();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 4), () {
      if (pageController.hasClients) {
        int nextPage = (currentBannerIndex.value + 1) % bannerImages.length;
        pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
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
      title: 'Combo Plan',
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
