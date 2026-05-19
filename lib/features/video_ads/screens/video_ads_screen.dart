import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/video_ads_controller.dart';
import '../../auth/controllers/auth_controller.dart';

class VideoAdsScreen extends GetView<VideoAdsController> {
  const VideoAdsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final String userName = authController.nameController.text.isNotEmpty 
        ? authController.nameController.text 
        : "Firoz Mohammad";
    final String userPhone = authController.phoneController.text.isNotEmpty
        ? authController.phoneController.text
        : "+91 9876543210";

    if (!Get.isRegistered<VideoAdsController>()) {
      Get.put(VideoAdsController());
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Create Video Ads', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildUploadUI(context),
    );
  }

  Widget _buildUploadUI(BuildContext context) {
    return Container(
      color: AppColors.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryColor.withOpacity(0.3), width: 2),
              ),
              child: const Icon(Icons.video_library, size: 80, color: AppColors.primaryColor),
            ),
            const SizedBox(height: 30),
            const Text(
              'Create Professional Video Ads',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Upload your 30-second video and we will automatically add your professional branding frame to it.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: controller.pickVideo,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Upload Video from Gallery'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
