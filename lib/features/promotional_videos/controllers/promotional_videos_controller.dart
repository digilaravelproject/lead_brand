import 'package:get/get.dart';

class PromotionalVideo {
  final String title;
  final String thumbnailUrl;
  final String? youtubeId;
  final String? localPath;

  PromotionalVideo({
    required this.title,
    required this.thumbnailUrl,
    this.youtubeId,
    this.localPath,
  });
}

class PromotionalVideosController extends GetxController {
  final RxList<PromotionalVideo> videos = <PromotionalVideo>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadVideos();
  }

  void _loadVideos() {
    isLoading.value = true;
    // Updated with guaranteed embeddable YouTube IDs
    videos.assignAll([
      PromotionalVideo(
        title: "Life Insurance Benefits",
        thumbnailUrl: "https://picsum.photos/seed/ins1/500/300",
        youtubeId: "M7lc1UVf-VE", // YouTube Dev Video (Allows Embed)
      ),
      PromotionalVideo(
        title: "Retirement Planning",
        thumbnailUrl: "https://picsum.photos/seed/ret1/500/300",
        youtubeId: "AqS4u_yYn0Y", // Google Developers
      ),
      PromotionalVideo(
        title: "Child Education Fund",
        thumbnailUrl: "https://picsum.photos/seed/edu1/500/300",
        youtubeId: "AqS4u_yYn0Y",
      ),
      PromotionalVideo(
        title: "Health Insurance",
        thumbnailUrl: "https://picsum.photos/seed/health1/500/300",
        youtubeId: "M7lc1UVf-VE",
      ),
      PromotionalVideo(
        title: "Tax Savings Guide",
        thumbnailUrl: "https://picsum.photos/seed/tax1/500/300",
        youtubeId: "AqS4u_yYn0Y",
      ),
      PromotionalVideo(
        title: "Family Protection Plan",
        thumbnailUrl: "https://picsum.photos/seed/fam1/500/300",
        youtubeId: "M7lc1UVf-VE",
      ),
    ]);
    isLoading.value = false;
  }
}
