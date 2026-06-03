import 'dart:io';
import 'dart:ui';
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

    // Fetch user profile on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
                                          image: controller.imagePath.value.isNotEmpty
                                              ? DecorationImage(
                                                  image: FileImage(File(controller.imagePath.value)),
                                                  fit: BoxFit.cover,
                                                )
                                              : (controller.profilePhotoUrl.value.isNotEmpty
                                                  ? DecorationImage(
                                                      image: NetworkImage('${AppConstants.baseUrl}${controller.profilePhotoUrl.value}'),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : null),
                                        ),
                                        child: controller.imagePath.value.isEmpty && controller.profilePhotoUrl.value.isEmpty
                                            ? const Icon(Icons.person, size: 50, color: AppColors.textColorHint)
                                            : null,
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
                                          image: controller.logoPath.value.isNotEmpty
                                              ? DecorationImage(
                                                  image: FileImage(File(controller.logoPath.value)),
                                                  fit: BoxFit.cover,
                                                )
                                              : (controller.logoUrl.value.isNotEmpty
                                                  ? DecorationImage(
                                                      image: NetworkImage('${AppConstants.baseUrl}${controller.logoUrl.value}'),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : null),
                                        ),
                                        child: controller.logoPath.value.isEmpty && controller.logoUrl.value.isEmpty
                                            ? const Icon(Icons.business, size: 50, color: AppColors.textColorHint)
                                            : null,
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
                                'Destination',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              CustomTextField(
                                controller: controller.destinationController,
                                hintText: 'Destination',
                                prefixIcon: Icons.location_on_outlined,
                                readOnly: false,
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
                        if (success) {
                          Get.back();
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
