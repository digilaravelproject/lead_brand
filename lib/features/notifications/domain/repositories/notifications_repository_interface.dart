import '../../../../core/services/network/response_model.dart';

abstract class NotificationsRepositoryInterface {
  Future<ResponseModel> getNotifications();
  Future<ResponseModel> getNotificationDetail(int id);
  Future<ResponseModel> markAllAsRead();
}
