import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../routes/route_helper.dart';
import '../../../core/widgets/custom_web_view.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _openInternalWebView(String url, String title) {
    Get.to(() => CustomWebView(url: url, title: title));
  }

  void _showLogoutDialog(AuthController authController, ThemeData theme) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout_rounded, color: Colors.red, size: 50),
              const SizedBox(height: 20),
              const Text(
                'Logout',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text(
                'Are you sure you want to logout from the app?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textColorSecondary, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textColorSecondary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        authController.logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        children: [
          const SizedBox(height: 10),
          
          // Profile Section
          _buildProfileHeader(authController, theme),
          
          const Divider(thickness: 1, height: 40, color: AppColors.borderColor),
          
          _buildSectionHeader('Support'),
          _buildSettingItem(
            icon: Icons.share_outlined,
            title: 'Share App',
            onTap: () {
              Share.share('Check out the ${AppConstants.appName}! Download now: ${AppConstants.playStoreUrl}');
            },
          ),
          _buildSettingItem(
            icon: Icons.star_outline,
            title: 'Rate Us',
            onTap: () async {
              final Uri uri = Uri.parse(AppConstants.playStoreUrl);
              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                Get.snackbar('Error', 'Could not open Play Store');
              }
            },
          ),
          _buildSettingItem(
            icon: Icons.question_answer_outlined,
            title: 'FAQs',
            onTap: () => Get.toNamed(RouteHelper.getFaqRoute()),
          ),
          
          const Divider(thickness: 1, height: 30, color: AppColors.borderColor),
          
          _buildSectionHeader('Legal'),
          _buildSettingItem(
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            onTap: () => Get.toNamed(RouteHelper.getTermsConditionRoute()),
          ),
          _buildSettingItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => Get.toNamed(RouteHelper.getPrivacyPolicyRoute()),
          ),
          
          const Divider(thickness: 1, height: 30, color: AppColors.borderColor),
          
          _buildSectionHeader('About'),
          _buildSettingItem(
            icon: Icons.info_outline,
            title: 'About App',
            onTap: () => Get.toNamed(RouteHelper.getAboutUsRoute()),
          ),
          
          const SizedBox(height: 40),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: OutlinedButton(
              onPressed: () => _showLogoutDialog(authController, theme),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          
          const SizedBox(height: 25),
          const Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: AppColors.textColorHint, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(AuthController controller, ThemeData theme) {
    return InkWell(
      onTap: () => Get.toNamed(RouteHelper.getProfileRoute()),
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Obx(() {
          final user = controller.rxUser.value;
          final name = user?.name ?? 'User Name';
          final email = user?.email ?? 'user@example.com';
          final photo = user?.profilePhoto;

          return Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.12),
                child: ClipOval(
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: photo != null && photo.isNotEmpty
                        ? (photo.startsWith('/')
                            ? CachedNetworkImage(
                                imageUrl: '${AppConstants.imageBaseUrl}$photo',
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                                  ),
                                ),
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.person,
                                  size: 38,
                                  color: AppColors.primaryColor,
                                ),
                              )
                            : Image.file(
                                File(photo),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.person,
                                  size: 38,
                                  color: AppColors.primaryColor,
                                ),
                              ))
                        : const Icon(
                            Icons.person,
                            size: 38,
                            color: AppColors.primaryColor,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textColorSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textColorHint, size: 22),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.textColorHint,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primaryColor, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textColorHint),
      onTap: onTap,
    );
  }
}
