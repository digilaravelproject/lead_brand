import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/plans_controller.dart';

class ComboPlanScreen extends GetView<PlansController> {
  const ComboPlanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<PlansController>()) {
      Get.put(PlansController());
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(
          controller.title.value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        )),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }
        if (controller.currentPlans.isEmpty) {
          return Center(
            child: Text(
              'No plans available',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: controller.currentPlans.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final plan = controller.currentPlans[index];
                  return _buildPlanCard(plan, index);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPlanCard(String title, int index) {
    final List<IconData> icons = [
      Icons.child_care,
      Icons.assignment,
      Icons.elderly,
      Icons.health_and_safety,
      Icons.monetization_on,
      Icons.account_balance_wallet,
      Icons.security,
    ];
    
    final List<Color> colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.selectPlan(title),
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors[index % colors.length].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icons[index % icons.length], 
                    color: colors[index % colors.length],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textColorPrimary,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textColorSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
