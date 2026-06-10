import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/route_helper.dart';
import '../../dashboard/domain/models/tool_model.dart';
import '../../dashboard/domain/usecases/get_tools_usecase.dart';
import '../../dashboard/domain/repositories/tools_repository_interface.dart';
import '../../dashboard/domain/repositories/tools_repository.dart';
import '../../../core/services/network/api_client.dart';

class PlansController extends GetxController {
  final GetToolsUseCase? _getToolsUseCase;

  PlansController({GetToolsUseCase? getToolsUseCase}) : _getToolsUseCase = getToolsUseCase;

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

  final RxList<String> currentPlans = <String>[].obs;
  final RxList<dynamic> dynamicSubtools = <dynamic>[].obs;
  final RxString title = 'Select Plan'.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPlans();
  }

  void _loadPlans() {
    final args = Get.arguments;
    if (args is Map && args.containsKey('subtools')) {
      title.value = args['title'] ?? 'Select Plan';
      final List<dynamic> subs = args['subtools'] ?? [];
      dynamicSubtools.assignAll(subs);
      currentPlans.assignAll(subs.map((s) => s['title'].toString()).toList());
    } else {
      // If we don't have subtools, try to fetch them dynamically from API
      _fetchSubtoolsFromApi();
    }
  }

  Future<void> _fetchSubtoolsFromApi() async {
    isLoading.value = true;
    final route = Get.currentRoute;
    final bool isCombo = route.contains('combo');
    title.value = isCombo ? 'Select Combo Plan' : 'Select LIC Plan';

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
          for (var item in toolsList) {
            final toolModel = ToolModel.fromJson(item);
            
            // Check if this tool matches the category
            final bool match = isCombo 
                ? (toolModel.icon == 'combo_plans' || toolModel.title.toLowerCase().contains('combo'))
                : (toolModel.icon == 'lic_plans' || toolModel.title.toLowerCase().contains('lic'));

            if (match) {
              title.value = toolModel.title;
              dynamicSubtools.assignAll(toolModel.subtools.map((s) => s.toJson()).toList());
              currentPlans.assignAll(toolModel.subtools.map((s) => s.title).toList());
              
              // We also fetch detail in case full subtool media data is required
              _fetchFullToolDetails(toolModel.id);
              break;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching plans from API: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchFullToolDetails(int toolId) async {
    try {
      final detail = await getToolsUseCase.executeDetail(toolId);
      if (detail.isSuccess && detail.body != null) {
        Map<String, dynamic>? data;
        if (detail.body is Map) {
          data = detail.body['tool'] ?? detail.body['data'];
        }
        if (data != null) {
          final List<dynamic> subtools = data['subtools'] ?? [];
          if (subtools.isNotEmpty) {
            dynamicSubtools.assignAll(subtools);
            currentPlans.assignAll(subtools.map((s) => s['title'].toString()).toList());
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching full tool details: $e');
    }
  }

  void selectPlan(String planName) {
    if (dynamicSubtools.isNotEmpty) {
      final subtool = dynamicSubtools.firstWhere(
        (s) => s['title'] == planName,
        orElse: () => null,
      );
      if (subtool != null) {
        final List<dynamic> media = subtool['media'] ?? [];
        final List<String> imageUrls = media.map((m) => m['full_url'].toString()).toList();
        Get.toNamed(RouteHelper.getGalleryRoute(), arguments: {
          'title': planName,
          'images': imageUrls,
          'media': media,
        });
        return;
      }
    }
    Get.toNamed(RouteHelper.getGalleryRoute(), arguments: planName);
  }
}
