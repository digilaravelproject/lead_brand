import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/auth_controller.dart';

class OtpScreen extends GetView<AuthController> {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Verify Email',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the 4-digit code sent to\n${controller.emailController.text}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textColorSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 50),
                      // OTP Input Fields
                      Obx(() {
                        final hasError = controller.otpErrorText.value != null;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(4, (index) => _otpTextField(context, index)),
                            ),
                            if (hasError) ...[
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  controller.otpErrorText.value!,
                                  style: const TextStyle(
                                    color: AppColors.errorColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      }),
                      const SizedBox(height: 30),
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              "Didn't receive the code?",
                              style: TextStyle(color: AppColors.textColorSecondary, fontSize: 14),
                            ),
                            TextButton(
                              onPressed: controller.resendOtp,
                              child: const Text(
                                'Resend Code',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Obx(() => CustomButton(
                  text: 'Verify & Continue',
                  isLoading: controller.isLoading.value,
                  onPressed: controller.verifyOtp,
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otpTextField(BuildContext context, int index) {
    final theme = Theme.of(context);
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.borderColor, width: 1.5),
      ),
      child: Center(
        child: TextField(
          controller: controller.otpControllers[index],
          onChanged: (value) {
            if (value.length == 1 && index < 3) {
              FocusScope.of(context).nextFocus();
            } else if (value.isEmpty && index > 0) {
              FocusScope.of(context).previousFocus();
            }
          },
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            fillColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
