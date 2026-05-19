import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../promotional_videos/controllers/promotional_videos_controller.dart';

class VideoAdsController extends GetxController {
  final RxString videoPath = ''.obs;
  final RxBool isVideoSelected = false.obs;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      Get.toNamed('/video-player', arguments: PromotionalVideo(
        title: video.name,
        thumbnailUrl: '',
        localPath: video.path,
      ));
    }
  }

  void reset() {
    videoPath.value = '';
    isVideoSelected.value = false;
  }
}
