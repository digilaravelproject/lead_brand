import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildBackgroundPattern(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 60),
                            Text(
                              'Welcome to\n${AppConstants.appName}',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                                letterSpacing: -1,
                                color: theme.textTheme.displayLarge?.color ?? Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Enter your email address to receive a secure OTP and unlock your potential.',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textColorSecondary,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 40),
                            Obx(() => CustomTextField(
                              controller: controller.emailController,
                              hintText: 'Enter Email Address',
                              keyboardType: TextInputType.emailAddress,
                              errorText: controller.emailErrorText.value,
                            )),
                            const SizedBox(height: 25),
                            Obx(() => CustomButton(
                              text: 'SEND OTP',
                              isLoading: controller.isLoading.value,
                              onPressed: controller.login,
                            )),
                            /*
                            const SizedBox(height: 35),
                            Row(
                              children: const [
                                Expanded(child: Divider(color: AppColors.dividerColor)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(color: AppColors.textColorHint, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(child: Divider(color: AppColors.dividerColor)),
                              ],
                            ),
                            const SizedBox(height: 35),
                            Container(
                              width: double.infinity,
                              height: 52, // Matched height with SEND OTP button
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.borderColor, width: 1.5),
                              ),
                              child: TextButton(
                                onPressed: controller.signInWithGoogle,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      'https://www.gstatic.com/images/branding/googleg/1x/googleg_standard_color_128dp.png',
                                      height: 24,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, color: AppColors.textColorHint, size: 30),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Continue with Google',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            */
                            const Spacer(),
                            const SizedBox(height: 20),
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 20),
                                child: Text(
                                  'By continuing, you agree to our Terms & Privacy Policy',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textColorHint,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.1,
        child: Stack(
          children: [
            Positioned(top: -50, left: -50, child: _circle(200)),
            Positioned(bottom: 100, right: -80, child: _circle(300)),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cardColor,
      ),
    );
  }
}
