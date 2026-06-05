import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class CustomSnackbar {
  static void _show({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Color? textColor,
  }) {
    // Auto-adjust text color for readability
    final Color effectiveTextColor =
        textColor ?? (backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white);

    final context = Get.context;
    if (context != null) {
      try {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: backgroundColor,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
            content: Row(
              children: [
                Icon(icon, color: effectiveTextColor, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title.isNotEmpty)
                        Text(
                          title,
                          style: TextStyle(
                            color: effectiveTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      Text(
                        message,
                        style: TextStyle(
                          color: effectiveTextColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
        return;
      } catch (e) {
        debugPrint("ScaffoldMessenger error: $e");
      }
    }

    try {
      Get.snackbar(
        title,
        message,
        backgroundColor: backgroundColor,
        colorText: effectiveTextColor,
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        icon: Icon(icon, color: effectiveTextColor),
        shouldIconPulse: false,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        mainButton: TextButton(
          onPressed: () => Get.back(),
          child: Text(
            "DISMISS",
            style: TextStyle(color: effectiveTextColor, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } catch (e) {
      debugPrint("CustomSnackbar error showing snackbar: $e");
    }
  }

  static void showSuccess(String message, {String title = 'Success'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.successColor,
      icon: Icons.check_circle,
    );
  }

  static void showError(String message, {String title = 'Error'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.errorColor,
      icon: Icons.error,
    );
  }

  static void showInfo(String message, {String title = 'Info'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.infoColor,
      icon: Icons.info,
    );
  }

  static void showWarning(String message, {String title = 'Warning'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.warningColor,
      icon: Icons.warning,
    );
  }
}
