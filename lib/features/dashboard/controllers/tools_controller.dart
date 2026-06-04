import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../domain/models/tool_model.dart';
import '../domain/usecases/get_tools_usecase.dart';
import '../domain/repositories/tools_repository_interface.dart';
import '../domain/repositories/tools_repository.dart';
import '../../../core/services/network/api_client.dart';
import '../../../routes/route_helper.dart';

class ToolsController extends GetxController {
  final GetToolsUseCase? _getToolsUseCase;

  ToolsController({GetToolsUseCase? getToolsUseCase}) : _getToolsUseCase = getToolsUseCase;

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

  final tools = <ToolItem>[].obs;
  final isLoading = true.obs;
  final isDetailLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDefaultTools();
    fetchTools();
  }

  void _initializeDefaultTools() {
    tools.assignAll(_getStaticTools());
  }

  List<ToolItem> _getStaticTools() {
    return [
      ToolItem(
        id: 6,
        title: "Promotional\nVideos",
        description: "Watch and share promotional videos",
        icon: Icons.play_circle_fill_rounded,
        route: '/promotional-videos',
        color: Colors.red,
      ),
      ToolItem(
        id: 7,
        title: "Create\nVideo Ads",
        description: "Create premium short promotional videos",
        icon: Icons.video_call_rounded,
        route: RouteHelper.getVideoAdsRoute(),
        color: Colors.indigo,
      ),
      ToolItem(
        id: 8,
        title: "Create\nPDF Calendar",
        description: "Generate custom PDF business calendars",
        icon: Icons.calendar_today_rounded,
        route: RouteHelper.getPdfCalendarRoute(),
        color: Colors.teal,
      ),
    ];
  }

  Future<void> fetchTools() async {
    isLoading.value = true;
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
          final List<ToolItem> updatedList = [];
          int index = 0;
          for (var item in toolsList) {
            final toolModel = ToolModel.fromJson(item);
            
            // Skip the three static tools from the API response to avoid duplication
            if (toolModel.id == 6 || toolModel.id == 7 || toolModel.id == 8) {
              continue;
            }

            final icon = _getIconData(toolModel.icon);
            final color = _getColor(toolModel.icon, index);
            final route = toolModel.subtools.isNotEmpty
                ? RouteHelper.getComboPlanRoute()
                : RouteHelper.getGalleryRoute();

            updatedList.add(ToolItem(
              id: toolModel.id,
              title: toolModel.title.isNotEmpty ? toolModel.title.replaceAll(' ', '\n') : '',
              description: toolModel.description,
              icon: icon,
              route: route,
              color: color,
              subtools: toolModel.subtools.map((s) => s.toJson()).toList(),
              media: toolModel.media.map((m) => m.toJson()).toList(),
            ));
            index++;
          }

          // Always append the three static tools at the end
          updatedList.addAll(_getStaticTools());

          if (updatedList.isNotEmpty) {
            tools.assignAll(updatedList);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching tools: $e');
    } finally {
      isLoading.value = false;
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

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'combo_plans':
        return Icons.auto_awesome_motion_rounded;
      case 'combo_posters':
        return Icons.dashboard_customize_rounded;
      case 'concept_brochures':
        return Icons.menu_book_rounded;
      case 'lic_plans':
        return Icons.description_rounded;
      case 'agent_recruitment':
        return Icons.person_add_rounded;
      case 'promotional_videos':
        return Icons.play_circle_fill_rounded;
      case 'create_video_ads':
        return Icons.video_call_rounded;
      case 'create_pdf_calendar':
        return Icons.calendar_today_rounded;
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
}
