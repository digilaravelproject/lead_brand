import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/models/notification_model.dart';
import '../controllers/notifications_controller.dart';
import 'notification_detail_screen.dart';

class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({Key? key}) : super(key: key);

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'tools':
        return Icons.collections_outlined;
      case 'training':
        return Icons.play_circle_rounded;
      case 'system_update':
        return Icons.system_update_alt_rounded;
      case 'lead_status':
        return Icons.assignment_turned_in_rounded;
      case 'promotion':
        return Icons.campaign_rounded;
      case 'follow_up':
        return Icons.event_note_rounded;
      case 'hot_lead':
        return Icons.local_fire_department_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'tools':
        return const Color(0xFF5B8DEF); // Premium Blue
      case 'training':
        return const Color(0xFF4CD964); // Premium Green
      case 'system_update':
        return const Color(0xFFAA8CFF); // Premium Purple
      case 'lead_status':
        return AppColors.primaryColor; // Amber/Orange
      case 'promotion':
        return const Color(0xFFFF5252); // Soft Red
      case 'follow_up':
        return const Color(0xFFFFB74D); // Soft Orange
      case 'hot_lead':
        return const Color(0xFFE040FB); // Magenta/Pink
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080B11),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NOTIFICATIONS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
            if (controller.unreadCount.value > 0)
              Text(
                '${controller.unreadCount.value} unread',
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        )),
        actions: [
          Obx(() {
            if (controller.unreadCount.value > 0) {
              return TextButton(
                onPressed: controller.markAllAsRead,
                child: const Text(
                  'Mark all read',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        if (controller.notifications.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          color: AppColors.primaryColor,
          backgroundColor: const Color(0xFF0F121A),
          onRefresh: controller.fetchNotifications,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: controller.notifications.length,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final notif = controller.notifications[index];
              return _buildNotificationCard(notif, index);
            },
          ),
        );
      }),
    );
  }

  Widget _buildNotificationCard(NotificationModel notif, int index) {
    final iconColor = _getTypeColor(notif.type);
    final icon = _getTypeIcon(notif.type);

    return GestureDetector(
      onTap: () {
        controller.markAsRead(index);
        Get.to(() => NotificationDetailScreen(notification: notif));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: notif.isRead ? const Color(0xFF0F121A) : const Color(0xFF13171F),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: notif.isRead
                ? Colors.white.withOpacity(0.04)
                : iconColor.withOpacity(0.25),
            width: 1.5,
          ),
          boxShadow: notif.isRead
              ? []
              : [
                  BoxShadow(
                    color: iconColor.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
                              fontSize: 13.5,
                              height: 1.2,
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: iconColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notif.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(notif.isRead ? 0.4 : 0.6),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notif.timeAgo,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: const Color(0xFF0F121A),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: const Icon(Icons.notifications_off_rounded, size: 52, color: Colors.white24),
          ),
          const SizedBox(height: 20),
          const Text('No Notifications Yet', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('You\'re all caught up!', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14)),
        ],
      ),
    );
  }
}
