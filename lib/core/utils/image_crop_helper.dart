import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import '../theme/app_colors.dart';
import 'custom_snackbar.dart';

class ImageCropHelper {
  /// Crops an image to a fixed 1:1 square ratio with minimum size validation.
  /// Returns the path to the cropped image, or null if cancelled or invalid.
  static Future<String?> cropSquareImage({
    required String sourcePath,
    String title = 'Crop Image',
    int minWidth = 200,
    int minHeight = 200,
  }) async {
    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: sourcePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: title,
            toolbarColor: AppColors.cardColor,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: AppColors.primaryColor,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: title,
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
          ),
        ],
      );

      if (croppedFile == null) {
        // User cancelled cropping
        return null;
      }

      // Check minimum resolution
      final file = File(croppedFile.path);
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final width = frame.image.width;
      final height = frame.image.height;

      if (width < minWidth || height < minHeight) {
        CustomSnackbar.showError(
          'Image resolution is too low (${width}x${height}px). Minimum required is ${minWidth}x${minHeight}px.',
        );
        return null;
      }

      return croppedFile.path;
    } catch (e) {
      debugPrint('Error in cropSquareImage: $e');
      return null;
    }
  }
}
