import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileSetupScreen extends GetView<AuthController> {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    
    // Prefill name and email if coming from Google login, or only email (clearing name) if from OTP
    if (Get.arguments != null) {
      if (Get.arguments is Map) {
        final Map args = Get.arguments;
        if (args['email'] != null) {
          controller.emailController.text = args['email'];
        }
        if (args['name'] != null) {
          controller.nameController.text = args['name'];
        }
      } else if (Get.arguments is String) {
        controller.emailController.text = Get.arguments;
        controller.nameController.clear();
        controller.imagePath.value = '';
      }
    }

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Complete Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: () => controller.pickImage(),
                        child: Obx(() {
                          print("ProfileSetupScreen Obx build: controller hash = ${identityHashCode(controller)}, imagePath = ${controller.imagePath.value}");
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.borderColor, width: 2),
                                ),
                              child: ClipOval(
                                child: Container(
                                  color: theme.cardColor,
                                  child: controller.imagePath.value.isNotEmpty
                                      ? Image.file(
                                          File(controller.imagePath.value),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            print("Image.file error: $error");
                                            return const Icon(Icons.error, size: 60, color: Colors.red);
                                          },
                                        )
                                      : const Icon(Icons.person, size: 60, color: AppColors.textColorHint),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.black, size: 18),
                              ),
                            ),
                          ],
                        );
                        }),
                      ),
                      const SizedBox(height: 50),
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
                          Obx(() => CustomTextField(
                            controller: controller.nameController,
                            hintText: 'Enter your full name',
                            prefixIcon: Icons.person_outline,
                            errorText: controller.nameErrorText.value,
                          )),
                          const SizedBox(height: 25),
                          const Text(
                            'WhatsApp Number',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: controller.whatsappController,
                            hintText: 'Enter your WhatsApp number',
                            prefixIcon: Icons.phone_android,
                          ),
                          const SizedBox(height: 25),
                          const Text(
                            'Address',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: controller.addressController,
                            hintText: 'Enter your address',
                            prefixIcon: Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 25),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Obx(() => CustomButton(
                  text: 'Complete Setup',
                  isLoading: controller.isLoading.value,
                  onPressed: controller.saveProfile,
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
