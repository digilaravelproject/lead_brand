import 'package:get/get.dart';
import '../../../routes/route_helper.dart';

class GalleryController extends GetxController {
  final planName = ''.obs;
  final columnCount = 3.obs;
  
  final List<String> images = List.generate(
    12, 
    (index) => 'https://picsum.photos/500/800?random=$index'
  );

  void toggleColumns() {
    columnCount.value = columnCount.value == 3 ? 2 : 3;
  }

  @override
  void onInit() {
    super.onInit();
    planName.value = Get.arguments ?? 'Gallery';
  }

  void openImageViewer(String imageUrl) {
    Get.toNamed(RouteHelper.getImageViewerRoute(), arguments: imageUrl);
  }
}
