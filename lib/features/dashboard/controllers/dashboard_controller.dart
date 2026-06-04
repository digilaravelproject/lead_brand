import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/route_helper.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/models/tool_model.dart';
import '../domain/usecases/get_tools_usecase.dart';
import '../domain/repositories/tools_repository_interface.dart';
import '../domain/repositories/tools_repository.dart';

class DashboardController extends GetxController {
  final GetToolsUseCase? _getToolsUseCase;

  DashboardController({GetToolsUseCase? getToolsUseCase}) : _getToolsUseCase = getToolsUseCase;

  GetToolsUseCase get getToolsUseCase {
    if (_getToolsUseCase != null) return _getToolsUseCase;
    
    // Self-healing fallback DI registration:
    if (!Get.isRegistered<ToolsRepositoryInterface>()) {
      Get.lazyPut<ToolsRepositoryInterface>(
        () => ToolsRepository(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<GetToolsUseCase>()) {
      Get.lazyPut<GetToolsUseCase>(
        () => GetToolsUseCase(repository: Get.find<ToolsRepositoryInterface>()),
        fenix: true,
      );
    }
    return Get.find<GetToolsUseCase>();
  }

  final PageController pageController = PageController();
  final RxInt currentBannerIndex = 0.obs;
  final RxList<String> bannerImages = <String>[].obs;
  final RxBool isBannersLoading = false.obs;

  final List<String> _fallbackBanners = [
    "https://images.unsplash.com/photo-1542744173-8e7e53415bb0?q=80&w=600&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1460925895917-afdab827c52f?q=80&w=600&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1557804506-669a67965ba0?q=80&w=600&auto=format&fit=crop",
  ];

  final RxList<DashboardFeature> features = <DashboardFeature>[].obs;
  final RxBool isFeaturesLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeFeatures();
    fetchBanners();
    fetchFeatures();
    _startAutoPlay();
  }

  void _initializeFeatures() {
    features.assignAll([
      DashboardFeature(
        id: 1,
        title: 'Combo King',
        icon: Icons.auto_awesome_motion,
        route: RouteHelper.getComboPlanRoute(),
        color: Colors.blue,
      ),
      DashboardFeature(
        id: 2,
        title: 'Combo Poster',
        icon: Icons.dashboard_customize,
        route: RouteHelper.getGalleryRoute(),
        color: Colors.lightBlue,
      ),
      DashboardFeature(
        id: 3,
        title: 'Concept Brochures',
        icon: Icons.menu_book,
        route: RouteHelper.getGalleryRoute(),
        color: Colors.orange,
      ),
      DashboardFeature(
        id: 4,
        title: 'LIC Plans',
        icon: Icons.description,
        route: RouteHelper.getLicPlansRoute(),
        color: Colors.green,
      ),
      DashboardFeature(
        id: 5,
        title: 'Agent Recruitment',
        icon: Icons.person_add,
        route: RouteHelper.getGalleryRoute(),
        color: Colors.purple,
      ),
      DashboardFeature(
        id: 6,
        title: 'Promotional Videos',
        icon: Icons.play_circle_filled,
        route: '/promotional-videos',
        color: Colors.red,
      ),
    ]);
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

  Future<void> fetchFeatures() async {
    try {
      final response = await getToolsUseCase.execute();
      if (response.isSuccess && response.body != null) {
        List<dynamic>? toolsList;
        if (response.body is List) {
          toolsList = response.body as List;
        } else if (response.body is Map) {
          toolsList = response.body['tools'] ?? response.body['data'];
        }

        if (toolsList != null) {
          final List<DashboardFeature> updatedList = [];
          int index = 0;
          for (var item in toolsList) {
            final toolModel = ToolModel.fromJson(item);
            
            // Skip the static tools with IDs 6, 7, 8 if they are in the API response to handle them manually
            if (toolModel.id == 6 || toolModel.id == 7 || toolModel.id == 8) {
              continue;
            }

            final icon = _getIconData(toolModel.icon);
            final color = _getColor(toolModel.icon, index);
            final route = toolModel.subtools.isNotEmpty
                ? RouteHelper.getComboPlanRoute()
                : RouteHelper.getGalleryRoute();

            // We translate "Combo Plans" to "Combo King" to keep the dashboard branding
            String displayTitle = toolModel.title;
            if (toolModel.title.toLowerCase().contains('combo') && toolModel.title.toLowerCase().contains('plan')) {
              displayTitle = 'Combo King';
            }

            updatedList.add(DashboardFeature(
              id: toolModel.id,
              title: displayTitle,
              icon: icon,
              route: route,
              color: color,
              subtools: toolModel.subtools.map((s) => s.toJson()).toList(),
              media: toolModel.media.map((m) => m.toJson()).toList(),
            ));
            index++;
          }

          // Append the static Promotional Videos (id: 6) to make it 6 items in total
          updatedList.add(DashboardFeature(
            id: 6,
            title: 'Promotional Videos',
            icon: Icons.play_circle_filled,
            route: '/promotional-videos',
            color: Colors.red,
          ));

          if (updatedList.isNotEmpty) {
            features.assignAll(updatedList);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching features: $e');
    }
  }

  Future<Map<String, dynamic>?> fetchToolDetail(int id) async {
    try {
      final response = await getToolsUseCase.executeDetail(id);
      if (response.isSuccess && response.body != null) {
        if (response.body is Map) {
          return response.body['tool'] ?? response.body['data'];
        }
      }
    } catch (e) {
      debugPrint('Error fetching tool detail: $e');
    }
    return null;
  }

  void navigateToFeature(DashboardFeature feature) async {
    if (feature.id == 6 || feature.id == 7 || feature.id == 8) {
      Get.toNamed(feature.route);
    } else {
      isFeaturesLoading.value = true;
      final detail = await fetchToolDetail(feature.id);
      isFeaturesLoading.value = false;

      if (detail != null) {
        final List<dynamic> subtools = detail['subtools'] ?? [];
        if (subtools.isNotEmpty) {
          Get.toNamed(feature.route, arguments: {
            'title': feature.title,
            'subtools': subtools,
          });
        } else {
          final List<dynamic> media = detail['media'] ?? [];
          final List<String> imageUrls = media.map((m) => m['full_url'].toString()).toList();
          Get.toNamed(RouteHelper.getGalleryRoute(), arguments: {
            'title': feature.title,
            'images': imageUrls,
          });
        }
      } else {
        // Fallback to pre-fetched data
        if (feature.subtools != null && feature.subtools!.isNotEmpty) {
          Get.toNamed(feature.route, arguments: {
            'title': feature.title,
            'subtools': feature.subtools,
          });
        } else {
          final List<String> imageUrls = feature.media?.map((m) => m['full_url'].toString()).toList() ?? [];
          Get.toNamed(RouteHelper.getGalleryRoute(), arguments: {
            'title': feature.title,
            'images': imageUrls,
          });
        }
      }
    }
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'combo_plans':
        return Icons.auto_awesome_motion;
      case 'combo_posters':
        return Icons.dashboard_customize;
      case 'concept_brochures':
        return Icons.menu_book;
      case 'lic_plans':
        return Icons.description;
      case 'agent_recruitment':
        return Icons.person_add;
      case 'promotional_videos':
        return Icons.play_circle_filled;
      case 'create_video_ads':
        return Icons.video_call;
      case 'create_pdf_calendar':
        return Icons.calendar_today;
      default:
        return Icons.build_rounded;
    }
  }

  Color _getColor(String? iconName, int index) {
    switch (iconName) {
      case 'combo_plans':
        return Colors.blue;
      case 'combo_posters':
        return Colors.lightBlue;
      case 'concept_brochures':
        return Colors.orange;
      case 'lic_plans':
        return Colors.green;
      case 'agent_recruitment':
        return Colors.purple;
      case 'promotional_videos':
        return Colors.red;
      case 'create_video_ads':
        return Colors.indigo;
      case 'create_pdf_calendar':
        return Colors.teal;
      default:
        final List<Color> colors = [
          Colors.blue,
          Colors.orange,
          Colors.green,
          Colors.red,
          Colors.purple,
          Colors.teal,
          Colors.indigo,
          Colors.lightBlue,
        ];
        return colors[index % colors.length];
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

  void openProfile() {
    Get.toNamed(RouteHelper.getProfileRoute());
  }
}

class DashboardFeature {
  final int id;
  final String title;
  final IconData icon;
  final String route;
  final Color color;
  final List<dynamic>? subtools;
  final List<dynamic>? media;

  DashboardFeature({
    required this.id,
    required this.title,
    required this.icon,
    required this.route,
    required this.color,
    this.subtools,
    this.media,
  });
}
