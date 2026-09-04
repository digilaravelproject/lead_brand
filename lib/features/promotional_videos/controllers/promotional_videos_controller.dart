import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/network/api_client.dart';

class PromotionalVideo {
  final String title;
  final String thumbnailUrl;
  final String? youtubeId;
  final String? localPath;
  final String? videoUrl;

  PromotionalVideo({
    required this.title,
    required this.thumbnailUrl,
    this.youtubeId,
    this.localPath,
    this.videoUrl,
  });
}

class PromotionalSubtool {
  final String title;
  final List<PromotionalVideo> videos;

  PromotionalSubtool({required this.title, required this.videos});
}

class PromotionalVideosController extends GetxController {
  final RxList<PromotionalVideo> videos = <PromotionalVideo>[].obs;
  final RxList<PromotionalSubtool> subtools = <PromotionalSubtool>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadVideos();
  }

  void _loadVideos() async {
    isLoading.value = true;
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.get(AppConstants.toolsUrl);
      if (response.isSuccess && response.body != null) {
        List<dynamic>? toolsList;
        if (response.body is List) {
          toolsList = response.body as List;
        } else if (response.body is Map) {
          toolsList = response.body['tools'] ?? response.body['data'];
        }

        if (toolsList != null) {
          final promoTool = toolsList.firstWhere(
            (t) => t['id'] == 6 || t['icon'] == 'promotional_videos' || t['title']?.toString().toLowerCase().contains('promotional') == true,
            orElse: () => null,
          );

          if (promoTool != null) {
            if (promoTool['media'] != null) {
              final List<dynamic> mediaList = promoTool['media'] as List;
              final List<PromotionalVideo> loadedVideos = [];
              for (var m in mediaList) {
                final String fullUrl = m['full_url'] ?? '';
                final String title = m['title'] ?? 'Promotional Video';
                final int id = m['id'] ?? 0;
                final String thumbnail = m['thumbnail_url'] ?? "https://picsum.photos/seed/video_$id/500/300";

                loadedVideos.add(PromotionalVideo(
                  title: title,
                  thumbnailUrl: thumbnail.isNotEmpty ? thumbnail : "https://picsum.photos/seed/video_$id/500/300",
                  videoUrl: fullUrl,
                ));
              }
              if (loadedVideos.isNotEmpty) {
                videos.assignAll(loadedVideos);
              }
            }

            if (promoTool['subtools'] != null) {
              final List<dynamic> subtoolsList = promoTool['subtools'] as List;
              final List<PromotionalSubtool> loadedSubtools = [];
              for (var s in subtoolsList) {
                final String subTitle = s['title'] ?? 'Category';
                final List<dynamic> sMedia = s['media'] ?? [];
                final List<PromotionalVideo> sVideos = [];
                for (var m in sMedia) {
                  final String fullUrl = m['full_url'] ?? '';
                  final String title = m['title'] ?? 'Video';
                  final int id = m['id'] ?? 0;
                  final String thumbnail = m['thumbnail_url'] ?? "https://picsum.photos/seed/video_$id/500/300";

                  sVideos.add(PromotionalVideo(
                    title: title,
                    thumbnailUrl: thumbnail.isNotEmpty ? thumbnail : "https://picsum.photos/seed/video_$id/500/300",
                    videoUrl: fullUrl,
                  ));
                }
                if (sVideos.isNotEmpty) {
                  loadedSubtools.add(PromotionalSubtool(title: subTitle, videos: sVideos));
                }
              }
              if (loadedSubtools.isNotEmpty) {
                subtools.assignAll(loadedSubtools);
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching promotional videos dynamically: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
