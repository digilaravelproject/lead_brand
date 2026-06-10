import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileScreen extends GetView<AuthController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController());
    }
    final controller = Get.find<AuthController>();

    // Fetch user profile on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("ProfileScreen build: controller hash = ${identityHashCode(controller)}");
      controller.fetchUserProfile();
    });

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final isProfileLoading = controller.isProfileLoading.value;
          
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // Modern Profile & Logo Image Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Profile Image Upload
                              Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Obx(() => Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: theme.cardColor,
                                          border: Border.all(color: AppColors.borderColor, width: 2),
                                        ),
                                        child: ClipOval(
                                          child: controller.imagePath.value.isNotEmpty
                                              ? Image.file(
                                                  File(controller.imagePath.value),
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) =>
                                                      const Icon(Icons.person, size: 50, color: AppColors.textColorHint),
                                                )
                                              : (controller.profilePhotoUrl.value.isNotEmpty
                                                  ? CachedNetworkImage(
                                                      imageUrl: '${AppConstants.imageBaseUrl}${controller.profilePhotoUrl.value}',
                                                      fit: BoxFit.cover,
                                                      placeholder: (context, url) => const Center(
                                                        child: SizedBox(
                                                          width: 24,
                                                          height: 24,
                                                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                                                        ),
                                                      ),
                                                      errorWidget: (context, url, error) =>
                                                          const Icon(Icons.person, size: 50, color: AppColors.textColorHint),
                                                    )
                                                  : const Icon(Icons.person, size: 50, color: AppColors.textColorHint)),
                                        ),
                                      )),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: InkWell(
                                          onTap: () => controller.pickImage(),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: AppColors.primaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.camera_alt, color: Colors.black, size: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Profile Picture',
                                    style: TextStyle(
                                      color: AppColors.textColorSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                               ),
                              const SizedBox(width: 40),
                              // Logo Upload
                              Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Obx(() => Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: theme.cardColor,
                                          border: Border.all(color: AppColors.borderColor, width: 2),
                                        ),
                                        child: ClipOval(
                                          child: controller.logoPath.value.isNotEmpty
                                              ? Image.file(
                                                  File(controller.logoPath.value),
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) =>
                                                      const Icon(Icons.business, size: 50, color: AppColors.textColorHint),
                                                )
                                              : (controller.logoUrl.value.isNotEmpty
                                                  ? CachedNetworkImage(
                                                      imageUrl: '${AppConstants.imageBaseUrl}${controller.logoUrl.value}',
                                                      fit: BoxFit.cover,
                                                      placeholder: (context, url) => const Center(
                                                        child: SizedBox(
                                                          width: 24,
                                                          height: 24,
                                                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                                                        ),
                                                      ),
                                                      errorWidget: (context, url, error) =>
                                                          const Icon(Icons.business, size: 50, color: AppColors.textColorHint),
                                                    )
                                                  : const Icon(Icons.business, size: 50, color: AppColors.textColorHint)),
                                        ),
                                      )),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: InkWell(
                                          onTap: () => controller.pickLogo(),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: AppColors.primaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.camera_alt, color: Colors.black, size: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Company Logo',
                                    style: TextStyle(
                                      color: AppColors.textColorSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),

                          // Inputs Section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Full Name',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              CustomTextField(
                                controller: controller.nameController,
                                hintText: 'Enter your full name',
                                prefixIcon: Icons.person_outline,
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                'Email Address',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              CustomTextField(
                                controller: controller.emailController,
                                hintText: 'Email address',
                                prefixIcon: Icons.email_outlined,
                                readOnly: true,
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                'Designation',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              CustomTextField(
                                controller: controller.destinationController,
                                hintText: 'Designation',
                                prefixIcon: Icons.badge_outlined,
                                readOnly: false,
                                suffixIcon: PopupMenuButton<String>(
                                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textColorHint),
                                  color: AppColors.cardColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: AppColors.borderColor, width: 1.5),
                                  ),
                                  onSelected: (String value) {
                                    controller.destinationController.text = value;
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return [
                                      'Developer Officer',
                                      'Insurance advisor',
                                      'Financial Advisor',
                                      'Financial planner',
                                    ].map((String choice) {
                                      return PopupMenuItem<String>(
                                        value: choice,
                                        child: Text(
                                          choice,
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                'Phone Number',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              IntlPhoneField(
                                controller: controller.phoneController,
                                initialCountryCode: 'IN',
                                dropdownIconPosition: IconPosition.trailing,
                                dropdownIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textColorHint, size: 18),
                                flagsButtonPadding: const EdgeInsets.only(left: 15),
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                                dropdownTextStyle: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Phone Number',
                                  hintStyle: const TextStyle(color: AppColors.textColorHint, fontWeight: FontWeight.w500, fontSize: 14),
                                  filled: true,
                                  fillColor: theme.cardColor,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(color: AppColors.borderColor, width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(color: AppColors.borderColor),
                                  ),
                                ),
                                onChanged: (phone) {
                                  controller.selectedCountryCode.value = phone.countryCode;
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Pinned Save Button
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Obx(() => CustomButton(
                      text: 'SAVE CHANGES',
                      isLoading: controller.isLoading.value,
                      onPressed: () async {
                        final success = await controller.updateProfileChanges();
                        if (success && context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    )),
                  ),
                ],
              ),
              if (isProfileLoading)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.35),
                      child: const Center(
                        child: CircularProgressIndicator(color: AppColors.primaryColor),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
     // ),
    );
  }
}
