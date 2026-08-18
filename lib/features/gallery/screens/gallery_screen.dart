import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/gallery_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

class GalleryScreen extends GetView<GalleryController> {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<GalleryController>()) {
      Get.put(GalleryController());
    }
    
    final authController = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : Get.put(AuthController());

    void launchUrlSafely(String scheme, String path) async {
      final Uri url = Uri(scheme: scheme, path: path);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }

    void showFreeTrialDialog(BuildContext context, Map<String, dynamic>? dealer, Map<String, dynamic>? admin) {
      String name = '';
      String phone = '';
      String altPhone = '';
      String email = '';
      String role = '';

      if (dealer != null && dealer.isNotEmpty) {
        name = dealer['name'] ?? 'Assigned Dealer';
        phone = dealer['phone_number'] ?? '';
        altPhone = dealer['alternative_phone_number'] ?? '';
        email = dealer['email'] ?? '';
        role = 'Dealer';
      } else if (admin != null && admin.isNotEmpty) {
        name = admin['name'] ?? 'System Admin';
        phone = admin['phone_number'] ?? '';
        altPhone = admin['alternative_phone_number'] ?? '';
        email = admin['email'] ?? '';
        role = 'Admin';
      } else {
        name = 'Support Team';
        role = 'Support';
        email = 'support@leadbrand.com';
      }

      showDialog(
        context: context,
        builder: (context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: AlertDialog(
            backgroundColor: const Color(0xFF0F121A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF2196F3), width: 1.5),
            ),
            title: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFF2196F3), size: 28),
                SizedBox(width: 10),
                Text(
                  "Free Trial Access",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "You are currently using a free trial. Access to this content is restricted.",
                  style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 16),
                Text(
                  "Please contact your assigned $role to purchase a subscription and unlock all features.",
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500, height: 1.4),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 12),
                      if (phone.isNotEmpty)
                        InkWell(
                          onTap: () => launchUrlSafely('tel', phone),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.phone_rounded, color: Color(0xFF2196F3), size: 16),
                                const SizedBox(width: 8),
                                Text(phone, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
                              ],
                            ),
                          ),
                        ),
                      if (altPhone.isNotEmpty)
                        InkWell(
                          onTap: () => launchUrlSafely('tel', altPhone),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.phone_android_rounded, color: Color(0xFF2196F3), size: 16),
                                const SizedBox(width: 8),
                                Text(altPhone, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
                              ],
                            ),
                          ),
                        ),
                      if (email.isNotEmpty)
                        InkWell(
                          onTap: () => launchUrlSafely('mailto', email),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.email_rounded, color: Color(0xFF2196F3), size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text(email, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, decoration: TextDecoration.underline), overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
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
      body: Obx(() => controller.images.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    size: 64,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No image found",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
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
                
                return Obx(() {
                  final user = authController.rxUser.value;
                  bool isFreeTrial = false;
                  if (user?.approvalStatus == 'pending' && user?.subscriptionEndsAt != null) {
                    final endsAt = DateTime.tryParse(user!.subscriptionEndsAt!);
                    if (endsAt != null && endsAt.isAfter(DateTime.now())) {
                      isFreeTrial = true;
                    }
                  }
                  final bool isLocked = isFreeTrial && index >= 6;

                  return GestureDetector(
                    onTap: () {
                      if (isLocked) {
                        Map<String, dynamic>? dealer = user?.dealer;
                        Map<String, dynamic>? admin = user?.admin;
                        
                        // Fallback to DashboardController if local data is missing
                        if (dealer == null && admin == null && Get.isRegistered<DashboardController>()) {
                          final dashCtrl = Get.find<DashboardController>();
                          if (dashCtrl.dealerInfo.isNotEmpty) dealer = dashCtrl.dealerInfo;
                          else if (dashCtrl.adminInfo.isNotEmpty) admin = dashCtrl.adminInfo;
                        }

                        showFreeTrialDialog(context, dealer, admin);
                      } else {
                        controller.openImageViewer(imageUrl);
                      }
                    },
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
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
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
                            if (isLocked)
                              BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                                child: Container(
                                  color: Colors.black.withOpacity(0.3),
                                  child: const Center(
                                    child: Icon(
                                      Icons.lock_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
              },
            )),
    );
  }
}
