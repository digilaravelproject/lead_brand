import 'package:get/get.dart';
import '../domain/models/notification_model.dart';
import '../domain/usecases/get_notifications_usecase.dart';
import '../../../../core/utils/custom_snackbar.dart';

class NotificationsController extends GetxController {
  final GetNotificationsUseCase getNotificationsUseCase;

  NotificationsController({required this.getNotificationsUseCase});

  final notifications = <NotificationModel>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;
  final selectedNotification = Rxn<NotificationModel>();
  final isDetailLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final response = await getNotificationsUseCase.execute();
      if (response.isSuccess && response.body != null) {
        final data = response.body;
        final notifResponse = NotificationResponse.fromJson(data);
        notifications.assignAll(notifResponse.notifications);
        unreadCount.value = notifResponse.unreadCount;
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      CustomSnackbar.showError('Failed to load notifications.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAllAsRead() async {
    isLoading.value = true;
    try {
      final response = await getNotificationsUseCase.markAllRead();
      if (response.isSuccess) {
        for (var notif in notifications) {
          notif.isRead = true;
        }
        notifications.refresh();
        unreadCount.value = 0;
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      CustomSnackbar.showError('Failed to mark all notifications as read.');
    } finally {
      isLoading.value = false;
    }
  }

  void markAsRead(int index) {
    if (!notifications[index].isRead) {
      notifications[index].isRead = true;
      notifications.refresh();
      if (unreadCount.value > 0) {
        unreadCount.value--;
      }
    }
  }

  Future<void> fetchNotificationDetail(int id) async {
    isDetailLoading.value = true;
    try {
      final response = await getNotificationsUseCase.executeDetail(id);
      if (response.isSuccess && response.body != null) {
        final data = response.body['notification'];
        if (data != null) {
          selectedNotification.value = NotificationModel.fromJson(data);
          
          // Mark as read in the list if not already read
          final index = notifications.indexWhere((n) => n.id == id);
          if (index != -1 && !notifications[index].isRead) {
            notifications[index].isRead = true;
            notifications.refresh();
            if (unreadCount.value > 0) {
              unreadCount.value--;
            }
          }
        }
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      CustomSnackbar.showError('Failed to load notification details.');
    } finally {
      isDetailLoading.value = false;
    }
  }
}
