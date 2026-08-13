import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B11), // Premium dark obsidian
      body: Stack(
        children: [
          // Concentric Soft Circles (gold tint)
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildCircle(650, 0.02),
                _buildCircle(500, 0.04),
                _buildCircle(350, 0.06),
                _buildCircle(220, 0.08),
              ],
            ),
          ),
          
          // Central Logo
          Center(
            child: _buildLogoContainer(),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryColor.withOpacity(opacity),
      ),
    );
  }

  Widget _buildLogoContainer() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dashed Circle Border
          CustomPaint(
            size: const Size(150, 150),
            painter: DashedCirclePainter(),
          ),
          const Text(
            "AdvisorX \nPro",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryColor
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    
    // We need 8 dashes as seen in the image
    const int dashCount = 8;
    const double dashAngle = (2 * 3.14159) / dashCount;
    const double gapPercentage = 0.3; // Space between dashes

    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        (i * dashAngle) + (dashAngle * gapPercentage / 2),
        dashAngle * (1 - gapPercentage),
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
