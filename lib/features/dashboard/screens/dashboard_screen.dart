import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/route_helper.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/main_screen_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../notifications/controllers/notifications_controller.dart';
import '../../training/screens/training_pdfs_screen.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DashboardController>()) {
      Get.put(DashboardController());
    }
    
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    return Scaffold(
      backgroundColor: const Color(0xFF080B11), // Premium Obsidian black background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        leadingWidth: 70,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: GestureDetector(
              onTap: () => Get.toNamed(RouteHelper.getProfileRoute()),
              child: Obx(() {
                final localPath = authController.imagePath.value;
                final photo = authController.rxUser.value?.profilePhoto;
                
                ImageProvider? imageProvider;
                if (localPath.isNotEmpty) {
                  imageProvider = FileImage(File(localPath));
                } else if (photo != null && photo.isNotEmpty) {
                  imageProvider = photo.startsWith('/')
                      ? NetworkImage('${AppConstants.baseUrl}$photo')
                      : FileImage(File(photo)) as ImageProvider;
                }

                return Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryColor, width: 1.5),
                    color: const Color(0xFF0F121A),
                    image: imageProvider != null
                        ? DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageProvider == null
                      ? const Center(
                          child: Icon(
                            Icons.person,
                            color: AppColors.primaryColor,
                            size: 24,
                          ),
                        )
                      : null,
                );
              }),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Builder(
              builder: (context) {
                final name = AppConstants.appName;
                final words = name.split(' ');
                if (words.length > 1) {
                  final lastWord = words.last;
                  final prefix = words.sublist(0, words.length - 1).join(' ');
                  return Row(
                    children: [
                      Text(
                        prefix.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        lastWord.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  );
                } else {
                  return Text(
                    name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  );
                }
              },
            ),
            const Text(
              "Grow Your Insurance Business Digitally",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Obx(() {
            final notificationsController = Get.find<NotificationsController>();
            final unreadCount = notificationsController.unreadCount.value;
            
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: () => Get.toNamed(RouteHelper.getNotificationRoute()),
                  icon: const Icon(Icons.notifications_none_outlined, color: Colors.white, size: 26),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "$unreadCount",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Greeting row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                children: [
                  Text(
                    "Hello, Welcome! 👋",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // Hero Banner Image Slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryColor.withOpacity(0.2), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.05),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: controller.pageController,
                        onPageChanged: (index) {
                          controller.currentBannerIndex.value = index;
                        },
                        itemCount: controller.bannerImages.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            controller.bannerImages[index],
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: const Color(0xFF0F121A),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFF0F121A),
                                child: const Center(
                                  child: Icon(Icons.broken_image, color: Colors.grey, size: 42),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      Positioned(
                        bottom: 12,
                        left: 16,
                        child: Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: List.generate(
                              controller.bannerImages.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: controller.currentBannerIndex.value == index ? 16 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: controller.currentBannerIndex.value == index
                                      ? AppColors.primaryColor
                                      : Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Horizontal Stats Card Row
           /* SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildStatsCard(
                    icon: Icons.people_alt_rounded,
                    color: AppColors.leadColor,
                    value: "25",
                    label: "Hot Leads",
                    points: [10, 15, 12, 18, 14, 22, 25],
                    trend: "12% this week",
                  ),
                  const SizedBox(width: 12),
                  _buildStatsCard(
                    icon: Icons.calendar_month_rounded,
                    color: AppColors.appointmentColor,
                    value: "4",
                    label: "Appointments",
                    points: [1, 3, 2, 4, 3, 2, 4],
                    trend: "8% this week",
                  ),
                  const SizedBox(width: 12),
                  _buildStatsCard(
                    icon: Icons.access_time_filled_rounded,
                    color: AppColors.followUpColor,
                    value: "8",
                    label: "Follow-ups",
                    points: [5, 4, 6, 5, 7, 6, 8],
                    trend: "10% this week",
                  ),
                  const SizedBox(width: 12),
                  _buildStatsCard(
                    icon: Icons.check_circle_rounded,
                    color: AppColors.trainingColor,
                    value: "12",
                    label: "Completed",
                    points: [4, 6, 8, 7, 9, 10, 12],
                    trend: "15% this week",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),*/

            // Quick Access header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quick Access',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final mainScreenController = Get.isRegistered<MainScreenController>()
                          ? Get.find<MainScreenController>()
                          : Get.put(MainScreenController());
                      mainScreenController.changeTab(1);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'View All',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(Icons.chevron_right, color: AppColors.primaryColor, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // Features Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  final feature = controller.features[index];
                  return _buildFeatureCard(feature);
                },
              ),
            ),

            const SizedBox(height: 25),

            // Tools & Resources Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF071424).withOpacity(0.9),
                      const Color(0xFF040A12).withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withOpacity(0.15), width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
                      ),
                      child: const Icon(Icons.diamond, color: Colors.blue, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tools & Resources",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Everything you need to grow your business in one place.",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Get.to(() => const TrainingPdfsScreen()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Explore Tools",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /*const SizedBox(height: 25),

            // Today's Activity Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Activity",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F121A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildActivityItem(
                            icon: Icons.phone_rounded,
                            color: const Color(0xFFAB47BC),
                            value: "5",
                            label: "Calls Done",
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _buildDottedConnector(
                            color1: const Color(0xFFAB47BC),
                            color2: const Color(0xFFFFB74D),
                            width: 12,
                          ),
                        ),
                        Expanded(
                          child: _buildActivityItem(
                            icon: Icons.person_rounded,
                            color: const Color(0xFFFFB74D),
                            value: "3",
                            label: "Meetings",
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _buildDottedConnector(
                            color1: const Color(0xFFFFB74D),
                            color2: const Color(0xFF81C784),
                            width: 12,
                          ),
                        ),
                        Expanded(
                          child: _buildActivityItem(
                            icon: Icons.assignment_turned_in_rounded,
                            color: const Color(0xFF81C784),
                            value: "2",
                            label: "Proposals Sent",
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _buildDottedConnector(
                            color1: const Color(0xFF81C784),
                            color2: const Color(0xFF64B5F6),
                            width: 12,
                          ),
                        ),
                        Expanded(
                          child: _buildActivityItem(
                            icon: Icons.shield_rounded,
                            color: const Color(0xFF64B5F6),
                            value: "1",
                            label: "Policy Sold",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),*/

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
    required List<double> points,
    required String trend,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F121A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 25,
            width: double.infinity,
            child: CustomPaint(
              painter: MiniGraphPainter(color: color, points: points),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.arrow_upward, color: Colors.green, size: 12),
              const SizedBox(width: 2),
              Text(
                trend,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(DashboardFeature feature) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.navigateToFeature(feature.route),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F121A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: feature.color.withOpacity(0.15), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: feature.color.withOpacity(0.03),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(-1, -1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: feature.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(feature.icon, size: 24, color: feature.color),
              ),
              const SizedBox(height: 12),
              Text(
                feature.title,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.2,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0F121A),
                border: Border.all(color: color.withOpacity(0.8), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 5,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withOpacity(0.25),
                      color.withOpacity(0.05),
                    ],
                    radius: 0.6,
                  ),
                ),
                child: Icon(icon, color: color, size: 11),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withOpacity(0.55),
            fontSize: 8,
            fontWeight: FontWeight.w500,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildDottedConnector({
    required Color color1,
    required Color color2,
    required double width,
  }) {
    return Container(
      width: width,
      height: 2,
      child: CustomPaint(
        painter: DottedConnectorPainter(color1: color1, color2: color2),
      ),
    );
  }
}

class DottedConnectorPainter extends CustomPainter {
  final Color color1;
  final Color color2;

  DottedConnectorPainter({required this.color1, required this.color2});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = LinearGradient(
      colors: [color1, color2],
    ).createShader(rect);

    double startX = 0;
    const double dashWidth = 1.5;
    const double dashSpace = 3.0;

    while (startX < size.width) {
      canvas.drawCircle(Offset(startX + dashWidth / 2, size.height / 2), dashWidth / 2, paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MiniGraphPainter extends CustomPainter {
  final Color color;
  final List<double> points;

  MiniGraphPainter({required this.color, required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (points.isEmpty) return;

    final double dx = size.width / (points.length - 1);
    
    double minY = points.reduce((a, b) => a < b ? a : b);
    double maxY = points.reduce((a, b) => a > b ? a : b);
    double rangeY = maxY - minY;
    if (rangeY == 0) rangeY = 1.0;

    for (int i = 0; i < points.length; i++) {
      double x = i * dx;
      double y = size.height - ((points[i] - minY) / rangeY) * (size.height - 4) - 2;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ContinuousDottedLinePainter extends CustomPainter {
  final List<Color> colors;

  ContinuousDottedLinePainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = LinearGradient(
      colors: colors,
    ).createShader(rect);

    double startX = 0;
    const double dashWidth = 1.5;
    const double dashSpace = 3.0;

    while (startX < size.width) {
      canvas.drawCircle(Offset(startX + dashWidth / 2, size.height / 2), dashWidth / 2, paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
