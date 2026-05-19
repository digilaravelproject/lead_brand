import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import 'notification_detail_screen.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String time;
  final String type; // 'lead', 'promo', 'system', 'training'
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<AppNotification> _notifications = [
    AppNotification(
      id: '1',
      title: '🔥 New Hot Lead Added',
      message: 'Rahul Sharma has been marked as a Hot Lead. Take action now before they cool off.',
      time: '2 min ago',
      type: 'lead',
      isRead: false,
    ),
    AppNotification(
      id: '2',
      title: '📅 Follow-up Reminder',
      message: 'You have a follow-up scheduled with Priya Mehta today at 4:00 PM. Don\'t miss it!',
      time: '15 min ago',
      type: 'lead',
      isRead: false,
    ),
    AppNotification(
      id: '3',
      title: '🎬 New Training Video Added',
      message: 'A new video "Handling Sales Objections" has been added to the Training Hub.',
      time: '1 hr ago',
      type: 'training',
      isRead: false,
    ),
    AppNotification(
      id: '4',
      title: '🎉 Plan Promotion Live!',
      message: 'New combo plan posters are available. Share them now to attract more clients.',
      time: '3 hrs ago',
      type: 'promo',
      isRead: true,
    ),
    AppNotification(
      id: '5',
      title: '✅ Lead Status Updated',
      message: 'Anita Singh\'s status has been changed from "Follow Up" to "Appointment".',
      time: 'Yesterday',
      type: 'lead',
      isRead: true,
    ),
    AppNotification(
      id: '6',
      title: '📣 System Update',
      message: 'LeadBrandHub has been updated to v2.1. Enjoy new features and bug fixes.',
      time: '2 days ago',
      type: 'system',
      isRead: true,
    ),
  ];

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'lead': return Icons.person_add_rounded;
      case 'promo': return Icons.campaign_rounded;
      case 'training': return Icons.play_circle_rounded;
      case 'system': return Icons.info_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'lead': return AppColors.primaryColor;
      case 'promo': return const Color(0xFF5B8DEF);
      case 'training': return const Color(0xFF4CD964);
      case 'system': return const Color(0xFFAA8CFF);
      default: return Colors.grey;
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
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
        title: Column(
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
            if (_unreadCount > 0)
              Text(
                '$_unreadCount unread',
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                return _buildNotificationCard(notif);
              },
            ),
    );
  }

  Widget _buildNotificationCard(AppNotification notif) {
    final iconColor = _getTypeColor(notif.type);
    final icon = _getTypeIcon(notif.type);

    return GestureDetector(
      onTap: () {
        setState(() => notif.isRead = true);
        Get.to(() => NotificationDetailScreen(notification: notif));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
                      notif.time,
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
