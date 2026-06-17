import 'package:get/get.dart';
import '../../../routes/route_helper.dart';

class GalleryController extends GetxController {
  final planName = ''.obs;
  final columnCount = 3.obs;
  
  final RxList<String> images = <String>[].obs;
  final RxMap<String, String> imageUrlToPdfUrl = <String, String>{}.obs;
  final RxMap<String, String> imageUrlToDescription = <String, String>{}.obs;
  final RxMap<String, String> imageUrlToInfoImageUrl = <String, String>{}.obs;

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
      
      final List<dynamic> mediaList = args['media'] ?? [];
      for (var m in mediaList) {
        if (m is Map) {
          final String? fullUrl = m['full_url']?.toString();
          final String? pdfUrl = m['pdf_url']?.toString();
          final String? desc = m['description']?.toString();
          final String? infoImageUrl = m['info_image_url']?.toString();
          if (fullUrl != null) {
            if (pdfUrl != null && pdfUrl.isNotEmpty) {
              imageUrlToPdfUrl[fullUrl] = pdfUrl;
            }
            if (desc != null && desc.isNotEmpty) {
              imageUrlToDescription[fullUrl] = desc;
            }
            if (infoImageUrl != null && infoImageUrl.isNotEmpty) {
              imageUrlToInfoImageUrl[fullUrl] = infoImageUrl;
            }
          }
        }
      }
    } else {
      planName.value = args is String ? args : 'Gallery';
      images.assignAll(List.generate(
        12, 
        (index) => 'https://picsum.photos/500/800?random=$index'
      ));
    }
  }

  void openImageViewer(String imageUrl) {
    final pdfUrl = imageUrlToPdfUrl[imageUrl];
    final description = imageUrlToDescription[imageUrl];
    final infoImageUrl = imageUrlToInfoImageUrl[imageUrl];
    Get.toNamed(RouteHelper.getImageViewerRoute(), arguments: {
      'imageUrl': imageUrl,
      'pdfUrl': pdfUrl,
      'description': description,
      'infoImageUrl': infoImageUrl,
    });
  }
}
