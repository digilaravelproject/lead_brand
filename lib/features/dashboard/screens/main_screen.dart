import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/main_screen_controller.dart';
import 'dashboard_screen.dart';
import 'leads_screen.dart';
import 'tools_screen.dart';
import '../../training/screens/training_screen.dart';
import '../../settings/screens/settings_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  Future<bool?> _showExitConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121722),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: Colors.white.withOpacity(0.08),
            width: 1.5,
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.exit_to_app_rounded, color: AppColors.primaryColor, size: 28),
            SizedBox(width: 12),
            Text(
              "Exit Application",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to exit the app?",
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14.5,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white.withOpacity(0.55),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              "Cancel",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "OK",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<MainScreenController>()
        ? Get.find<MainScreenController>()
        : Get.put(MainScreenController());

    final List<Widget> screens = [
      const DashboardScreen(),
      const LeadsScreen(),
      const ToolsScreen(),
      const TrainingScreen(),
      const SettingsScreen(),
    ];

    Widget buildNavItem(int index, IconData icon, String label) {
      return Obx(() {
        final bool isSelected = controller.selectedIndex.value == index;
        return GestureDetector(
          onTap: () => controller.changeTab(index),
          behavior: HitTestBehavior.opaque,
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            decoration: isSelected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryColor,
                        Colors.white30,
                        AppColors.primaryColor,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  )
                : const BoxDecoration(),
            child: isSelected
                ? Padding(
                    padding: const EdgeInsets.all(1.2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F121A),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, color: AppColors.primaryColor, size: 20),
                            const SizedBox(height: 2),
                            Text(
                              label,
                              style: const TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: Colors.grey[500], size: 20),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitConfirmationDialog(context);
        if (shouldExit == true) {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF080B11),
        body: Obx(() => IndexedStack(
              index: controller.selectedIndex.value,
              children: screens,
            )),
        bottomNavigationBar: Container(
          height: 80 + MediaQuery.of(context).padding.bottom,
          padding: EdgeInsets.only(
            left: 6,
            right: 6,
            top: 4,
            bottom: MediaQuery.of(context).padding.bottom + 4,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0F121A),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(child: buildNavItem(0, Icons.home_rounded, 'Home')),
              Expanded(child: buildNavItem(2, Icons.business_center_rounded, 'Tools')),
              Expanded(child: buildNavItem(3, Icons.school_rounded, 'Training')),
              Expanded(child: buildNavItem(1, Icons.whatshot_rounded, 'Leads')),
              Expanded(child: buildNavItem(4, Icons.person_outline_rounded, 'Profile')),
            ],
          ),
        ),
      ),
    );
  }
}
