import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/auth/controllers/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(
              () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.successColor,
                  size: 80,
                ),

                SizedBox(height: Dimensions.height20),

                Text(
                  'Welcome, ${authController.currentUser.value?.name ?? 'User'}!',
                  style: TextStyle(
                    fontSize: Dimensions.font20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorPrimary,
                  ),
                ),

                SizedBox(height: Dimensions.height10),

                Text(
                  'You have successfully logged in.',
                  style: TextStyle(
                    fontSize: Dimensions.font16,
                    color: AppColors.textColorSecondary,
                  ),
                ),

                SizedBox(height: Dimensions.height20),

                Text(
                  'Mobile: ${authController.currentUser.value?.mobile ?? ''}',
                  style: TextStyle(
                    fontSize: Dimensions.font16,
                    color: AppColors.textColorPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
