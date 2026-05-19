import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/gallery_controller.dart';

class GalleryScreen extends GetView<GalleryController> {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<GalleryController>()) {
      Get.put(GalleryController());
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(
          controller.planName.value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        )),
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              controller.columnCount.value == 3 ? Icons.grid_view_rounded : Icons.view_comfy_rounded,
              color: Colors.white,
            ),
            onPressed: () => controller.toggleColumns(),
          )),
          const SizedBox(width: 10),
        ],
      ),
      body: Obx(() => GridView.builder(
        padding: const EdgeInsets.fromLTRB(10, 15, 10, 20),
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: controller.columnCount.value,
          crossAxisSpacing: controller.columnCount.value == 3 ? 8 : 12,
          mainAxisSpacing: controller.columnCount.value == 3 ? 8 : 12,
          childAspectRatio: controller.columnCount.value == 3 ? 0.8 : 0.75,
        ),
        itemCount: controller.images.length,
        itemBuilder: (context, index) {
          final imageUrl = controller.images[index];
          return GestureDetector(
            onTap: () => controller.openImageViewer(imageUrl),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(controller.columnCount.value == 3 ? 12 : 16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.04),
                  width: 1.2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(controller.columnCount.value == 3 ? 11 : 15),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: const Color(0xFF151821),
                    highlightColor: const Color(0xFF1F2430),
                    child: Container(color: const Color(0xFF0F121A)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFF0F121A),
                    child: const Icon(Icons.error_outline, color: Colors.white24),
                  ),
                ),
              ),
            ),
          );
        },
      )),
    );
  }
}
