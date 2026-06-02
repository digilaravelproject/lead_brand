import 'package:get/get.dart';

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
    videos.assignAll([
      PromotionalVideo(
        title: "Life Insurance Benefits",
        thumbnailUrl: "https://picsum.photos/seed/ins1/500/300",
        videoUrl: "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4?v=1",
      ),
      PromotionalVideo(
        title: "Retirement Planning",
        thumbnailUrl: "https://picsum.photos/seed/ret1/500/300",
        videoUrl: "https://www.w3schools.com/html/mov_bbb.mp4?v=2",
      ),
      PromotionalVideo(
        title: "Child Education Fund",
        thumbnailUrl: "https://picsum.photos/seed/edu1/500/300",
        videoUrl: "https://www.w3schools.com/html/movie.mp4?v=3",
      ),
      PromotionalVideo(
        title: "Health Insurance",
        thumbnailUrl: "https://picsum.photos/seed/health1/500/300",
        videoUrl: "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4?v=4",
      ),
      PromotionalVideo(
        title: "Tax Savings Guide",
        thumbnailUrl: "https://picsum.photos/seed/tax1/500/300",
        videoUrl: "https://www.w3schools.com/html/mov_bbb.mp4?v=5",
      ),
      PromotionalVideo(
        title: "Family Protection Plan",
        thumbnailUrl: "https://picsum.photos/seed/fam1/500/300",
        videoUrl: "https://www.w3schools.com/html/movie.mp4?v=6",
      ),
    ]);
    isLoading.value = false;
  }
}
