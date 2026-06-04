import 'package:get/get.dart';
import '../../../routes/route_helper.dart';

class GalleryController extends GetxController {
  final planName = ''.obs;
  final columnCount = 3.obs;
  
  final RxList<String> images = <String>[].obs;

  void toggleColumns() {
    columnCount.value = columnCount.value == 3 ? 2 : 3;
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args.containsKey('images')) {
      planName.value = args['title'] ?? 'Gallery';
      final List<dynamic> list = args['images'] ?? [];
      images.assignAll(list.cast<String>());
    } else {
      planName.value = args is String ? args : 'Gallery';
      images.assignAll(List.generate(
        12, 
        (index) => 'https://picsum.photos/500/800?random=$index'
      ));
    }
  }

  void openImageViewer(String imageUrl) {
    Get.toNamed(RouteHelper.getImageViewerRoute(), arguments: imageUrl);
  }
}
