import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../routes/route_helper.dart';

class MyProfileDetailsScreen extends GetView<AuthController> {
  const MyProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController());
    }
    
    // Fetch user profile on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchUserProfile();
    });

    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: AppColors.primaryColor, size: 20),
              ),
              onPressed: () => Get.toNamed(RouteHelper.getEditProfileRoute()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final isProfileLoading = controller.isProfileLoading.value;
          final user = controller.rxUser.value;

          if (isProfileLoading && user == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
          }

          if (user == null) {
            return const Center(child: Text("No user details found", style: TextStyle(color: Colors.white)));
          }

          // Calculate remaining validity if dates exist
          String remainingValidity = "N/A";
          if (user.subscriptionEndsAt != null) {
            try {
              DateTime endDate = DateTime.parse(user.subscriptionEndsAt!);
              Duration diff = endDate.difference(DateTime.now());
              if (diff.isNegative) {
                remainingValidity = "Expired";
              } else {
                remainingValidity = "${diff.inDays} Days";
              }
            } catch (e) {
              remainingValidity = "Invalid Date";
            }
          }

          String formatDate(String? dateStr) {
            if (dateStr == null || dateStr.isEmpty) return "N/A";
            try {
              DateTime date = DateTime.parse(dateStr);
              return DateFormat('dd MMM yyyy').format(date);
            } catch (e) {
              return dateStr;
            }
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Avatar with Glow
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryColor, Colors.orangeAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.scaffoldBackgroundColor,
                    ),
                    child: ClipOval(
                      child: user.profilePhoto != null && user.profilePhoto!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: '${AppConstants.imageBaseUrl}${user.profilePhoto}',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const CircularProgressIndicator(color: AppColors.primaryColor),
                              errorWidget: (context, url, error) => const Icon(Icons.person, size: 50, color: AppColors.textColorHint),
                            )
                          : const Icon(Icons.person, size: 50, color: AppColors.textColorHint),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                Text(
                  user.name.isNotEmpty ? user.name : 'Unknown User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.textColorHint.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.email,
                    style: const TextStyle(
                      color: AppColors.textColorHint,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                const SizedBox(height: 35),
                
                // Personal Details Card
                _buildInfoCard(
                  title: "Personal Details",
                  icon: Icons.person_outline,
                  children: [
                    _buildListItem(Icons.phone, "Phone Number", user.phoneNumber ?? "N/A"),
                    _buildDivider(),
                    _buildListItem(Icons.phone_android, "WhatsApp Number", user.whatsappNumber ?? "N/A"),
                    _buildDivider(),
                    _buildListItem(Icons.location_on_outlined, "Address", user.address ?? "N/A"),
                    _buildDivider(),
                    _buildListItem(Icons.badge_outlined, "Designation", user.destination ?? "N/A"),
                  ],
                ),
                
                const SizedBox(height: 25),
                
                // License Details Card
                _buildInfoCard(
                  title: "License Details",
                  icon: Icons.shield_outlined,
                  children: [
                    _buildListItem(Icons.info_outline, "License Version", "Standard"), // Placeholder
                    _buildDivider(),
                    _buildListItem(Icons.calendar_month_outlined, "Activation Date", formatDate(user.subscriptionStartedAt)),
                    _buildDivider(),
                    _buildListItem(Icons.event_busy_outlined, "Expiry Date", formatDate(user.subscriptionEndsAt)),
                    _buildDivider(),
                    _buildListItem(
                      Icons.verified_outlined, 
                      "Status", 
                      user.approvalStatus?.toUpperCase() ?? "N/A", 
                      isStatus: true,
                      statusValue: user.approvalStatus ?? "pending"
                    ),
                    _buildDivider(),
                    _buildListItem(Icons.timer_outlined, "Remaining Validity", remainingValidity, isHighlight: remainingValidity != "Expired"),
                  ],
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1F2A), // Dark elegant card color
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: AppColors.primaryColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(IconData icon, String label, String value, {bool isStatus = false, String statusValue = "", bool isHighlight = false}) {
    Color valueColor = Colors.white;
    if (isHighlight) {
      valueColor = AppColors.primaryColor;
    }
    
    Widget valueWidget;
    if (isStatus) {
      Color statusColor = Colors.grey;
      if (statusValue.toLowerCase() == 'active' || statusValue.toLowerCase() == 'approved') {
        statusColor = Colors.greenAccent;
      } else if (statusValue.toLowerCase() == 'pending') {
        statusColor = Colors.orangeAccent;
      } else if (statusValue.toLowerCase() == 'expired' || statusValue.toLowerCase() == 'rejected') {
        statusColor = Colors.redAccent;
      }
      
      valueWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: statusColor.withOpacity(0.5)),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: statusColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      valueWidget = Text(
        value,
        style: TextStyle(
          color: valueColor,
          fontSize: 14,
          fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
        ),
        textAlign: TextAlign.right,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textColorHint.withOpacity(0.7), size: 18),
          const SizedBox(width: 15),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textColorHint,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: valueWidget,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withOpacity(0.05),
      height: 20,
      thickness: 1,
    );
  }
}
