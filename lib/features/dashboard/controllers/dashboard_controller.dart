import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../../../routes/route_helper.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/models/tool_model.dart';
import '../domain/usecases/get_tools_usecase.dart';
import '../domain/repositories/tools_repository_interface.dart';
import '../domain/repositories/tools_repository.dart';
import '../../auth/controllers/auth_controller.dart';

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

  final PageController pageController = PageController(initialPage: 1200);
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

  // Lead Stats Observables
  final RxInt hotLeadsCount = 0.obs;
  final RxString hotLeadsTrend = '0% this week'.obs;
  final RxBool hotLeadsTrendUp = true.obs;

  final RxInt appointmentsCount = 0.obs;
  final RxString appointmentsTrend = '0% this week'.obs;
  final RxBool appointmentsTrendUp = true.obs;

  final RxInt followupsCount = 0.obs;
  final RxString followupsTrend = '0% this week'.obs;
  final RxBool followupsTrendUp = true.obs;

  final RxInt doneLeadsCount = 0.obs;
  final RxString doneLeadsTrend = '0% this week'.obs;
  final RxBool doneLeadsTrendUp = true.obs;

  final RxBool isLeadStatsLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeFeatures();
    checkSubscriptionStatus();
    fetchBanners();
    fetchFeatures();
    fetchLeadStats();
    _startAutoPlay();
  }

  Future<void> checkSubscriptionStatus() async {
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.get(AppConstants.getUserUrl);
      if (response.isSuccess && response.body != null) {
        final data = response.body['data'] ?? response.body;
        final user = data['user'];
        final dealer = data['dealer'];
        final admin = data['admin'];

        if (user != null) {
          final subscriptionEndsAtStr = user['subscription_ends_at'];
          if (subscriptionEndsAtStr != null) {
            final subscriptionEndsAt = DateTime.parse(subscriptionEndsAtStr);
            if (subscriptionEndsAt.isBefore(DateTime.now())) {
              _showSubscriptionExpiredDialog(dealer, admin);
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error checking subscription: $e");
    }
  }

  Future<void> _launchUrl(String scheme, String path) async {
    final Uri url = Uri(scheme: scheme, path: path);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _showSubscriptionExpiredDialog(Map<String, dynamic>? dealer, Map<String, dynamic>? admin) {
    String name = '';
    String phone = '';
    String altPhone = '';
    String email = '';
    String role = '';

    if (dealer != null) {
      name = dealer['name'] ?? 'Assigned Dealer';
      phone = dealer['phone_number'] ?? '';
      altPhone = dealer['alternative_phone_number'] ?? '';
      email = dealer['email'] ?? '';
      role = 'Dealer';
    } else if (admin != null) {
      name = admin['name'] ?? 'System Admin';
      phone = admin['phone_number'] ?? '';
      altPhone = admin['alternative_phone_number'] ?? '';
      email = admin['email'] ?? '';
      role = 'Admin';
    } else {
      name = 'Support Team';
      role = 'Support';
    }

    DateTime? lastQuitTime;

    Get.dialog(
      WillPopScope(
        onWillPop: () async {
          final now = DateTime.now();
          if (lastQuitTime == null || now.difference(lastQuitTime!) > const Duration(seconds: 2)) {
            lastQuitTime = now;
            Get.snackbar(
              "Exit",
              "Press back again to close the app",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF0F121A),
              colorText: Colors.white,
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            );
            return false;
          }
          SystemNavigator.pop();
          return true;
        },
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: AlertDialog(
            backgroundColor: const Color(0xFF0F121A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFEC407A), width: 1.5), // distinct color
            ),
            title: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFEC407A), size: 28),
                SizedBox(width: 10),
                Text(
                  "Subscription Expired",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your subscription has expired, and access to the platform's features is currently restricted.",
                  style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 16),
                Text(
                  "Please contact your assigned $role to make a payment and renew your subscription to continue growing your business seamlessly.",
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500, height: 1.4),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 12),
                      if (phone.isNotEmpty)
                        InkWell(
                          onTap: () => _launchUrl('tel', phone),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.phone_rounded, color: Color(0xFF2196F3), size: 16),
                                const SizedBox(width: 8),
                                Text(phone, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
                              ],
                            ),
                          ),
                        ),
                      if (altPhone.isNotEmpty)
                        InkWell(
                          onTap: () => _launchUrl('tel', altPhone),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.phone_android_rounded, color: Color(0xFF2196F3), size: 16),
                                const SizedBox(width: 8),
                                Text(altPhone, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
                              ],
                            ),
                          ),
                        ),
                      if (email.isNotEmpty)
                        InkWell(
                          onTap: () => _launchUrl('mailto', email),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.email_rounded, color: Color(0xFF2196F3), size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text(email, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, decoration: TextDecoration.underline), overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      backgroundColor: const Color(0xFF0F121A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
                      ),
                      title: const Text("Confirm Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      content: const Text("Are you sure you want to log out from this account?", style: TextStyle(color: Colors.white70)),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                        ),
                        TextButton(
                          onPressed: () {
                            if (Get.isRegistered<AuthController>()) {
                              Get.find<AuthController>().logout();
                            } else {
                              Get.put(AuthController()).logout();
                            }
                          },
                          child: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text("Logout", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _initializeFeatures() {
    features.assignAll([
      DashboardFeature(
        id: 5,
        title: 'Agent Recruitment',
        icon: Icons.people_alt_rounded,
        route: RouteHelper.getGalleryRoute(),
        color: const Color(0xFFAB47BC),
      ),
      DashboardFeature(
        id: 4,
        title: 'LIC Plans',
        icon: Icons.description_rounded,
        route: RouteHelper.getLicPlansRoute(),
        color: const Color(0xFF2196F3),
      ),
      DashboardFeature(
        id: 6,
        title: 'Promotional Videos',
        icon: Icons.play_circle_filled_rounded,
        route: '/promotional-videos',
        color: const Color(0xFFEC407A),
      ),
      DashboardFeature(
        id: 3,
        title: 'Concept Brochures',
        icon: Icons.menu_book_rounded,
        route: RouteHelper.getGalleryRoute(),
        color: const Color(0xFFFF9800),
      ),
      DashboardFeature(
        id: 2,
        title: 'Marketing Tools',
        icon: Icons.campaign_rounded,
        route: RouteHelper.getGalleryRoute(),
        color: const Color(0xFF00B0FF),
      ),
      DashboardFeature(
        id: 1,
        title: 'Lead Management',
        icon: Icons.groups_rounded,
        route: RouteHelper.getGalleryRoute(),
        color: const Color(0xFFFFA000),
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
              .map((item) {
                final imgUrl = item['image_url'] as String?;
                if (imgUrl != null && imgUrl.isNotEmpty) {
                  if (imgUrl.startsWith('/')) {
                    return '${AppConstants.imageBaseUrl}$imgUrl';
                  } else if (!imgUrl.startsWith('http')) {
                    return '${AppConstants.imageBaseUrl}/$imgUrl';
                  }
                  return imgUrl;
                }
                return null;
              })
              .whereType<String>()
              .toList();
          if (urls.isNotEmpty) {
            bannerImages.assignAll(urls);
            _jumpToInitialPage();
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
      _jumpToInitialPage();
    }
  }

  void _jumpToInitialPage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageController.hasClients && bannerImages.isNotEmpty) {
        int targetPage = 1200 - (1200 % bannerImages.length);
        pageController.jumpToPage(targetPage);
        currentBannerIndex.value = 0;
      }
    });
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
          for (var item in toolsList) {
            final toolModel = ToolModel.fromJson(item);

            String title = toolModel.title;
            IconData icon = _getIconData(toolModel.icon);
            Color color = _getColor(toolModel.icon, 0);
            
            // Map keys dynamically to match user screenshot design:
            if (toolModel.icon == 'combo_posters') {
              icon = Icons.campaign_rounded;
              color = const Color(0xFF00B0FF);
            } else if (toolModel.icon == 'combo_plans') {
              icon = Icons.groups_rounded;
              color = const Color(0xFFFFA000);
            } else if (toolModel.icon == 'agent_recruitment') {
              icon = Icons.people_alt_rounded;
              color = const Color(0xFFAB47BC);
            } else if (toolModel.icon == 'lic_plans') {
              icon = Icons.description_rounded;
              color = const Color(0xFF2196F3);
            } else if (toolModel.icon == 'concept_brochures') {
              icon = Icons.menu_book_rounded;
              color = const Color(0xFFFF9800);
            }

            final route = toolModel.id == 6 
                ? '/promotional-videos'
                : (toolModel.id == 7
                    ? RouteHelper.getVideoAdsRoute()
                    : (toolModel.id == 8
                        ? RouteHelper.getPdfCalendarRoute()
                        : (toolModel.subtools.isNotEmpty
                            ? RouteHelper.getComboPlanRoute()
                            : RouteHelper.getGalleryRoute())));

            updatedList.add(DashboardFeature(
              id: toolModel.id,
              title: title,
              icon: icon,
              route: route,
              color: color,
              subtools: toolModel.subtools.map((s) => s.toJson()).toList(),
              media: toolModel.media.map((m) => m.toJson()).toList(),
            ));
          }

          if (updatedList.isNotEmpty) {
            features.assignAll(updatedList);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching features: $e');
    }
  }

  Future<void> fetchLeadStats() async {
    isLeadStatsLoading.value = true;
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.get(
        AppConstants.leadStatsUrl,
        queryParameters: {'day': 'today'},
      );
      if (response.isSuccess && response.body != null) {
        final dynamic data = (response.body is Map && (response.body as Map).containsKey('hot_leads'))
            ? response.body
            : (response.rawBody is Map ? response.rawBody['data'] : null);
        if (data != null) {
          // Hot Leads
          final hot = data['hot_leads'];
          if (hot != null) {
            hotLeadsCount.value = hot['count'] ?? 0;
            hotLeadsTrend.value = '${hot['percentage'] ?? 0}% this week';
            hotLeadsTrendUp.value = (hot['trend'] ?? 'up') == 'up';
          }

          // Appointments
          final appt = data['appointments_today'];
          if (appt != null) {
            appointmentsCount.value = appt['count'] ?? 0;
            appointmentsTrend.value = '${appt['percentage'] ?? 0}% this week';
            appointmentsTrendUp.value = (appt['trend'] ?? 'up') == 'up';
          }

          // Followups
          final follow = data['followups_pending'];
          if (follow != null) {
            followupsCount.value = follow['count'] ?? 0;
            followupsTrend.value = '${follow['percentage'] ?? 0}% this week';
            followupsTrendUp.value = (follow['trend'] ?? 'up') == 'up';
          }

          // Done Leads
          final done = data['done_leads'];
          if (done != null) {
            doneLeadsCount.value = done['count'] ?? 0;
            doneLeadsTrend.value = '${done['percentage'] ?? 0}% this week';
            doneLeadsTrendUp.value = (done['trend'] ?? 'up') == 'up';
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching lead stats: $e');
    } finally {
      isLeadStatsLoading.value = false;
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
            'media': media,
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
            'media': feature.media,
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

  bool _isDisposed = false;

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 4), () {
      if (_isDisposed) return;
      if (pageController.hasClients && bannerImages.isNotEmpty) {
        int nextPage = pageController.page!.round() + 1;
        pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
      _startAutoPlay();
    });
  }

  @override
  void onClose() {
    _isDisposed = true;
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
