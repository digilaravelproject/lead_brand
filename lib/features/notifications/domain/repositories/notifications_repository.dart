import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_constants.dart';
import 'notifications_repository_interface.dart';

class NotificationsRepository implements NotificationsRepositoryInterface {
  final ApiClient apiClient;

  NotificationsRepository({required this.apiClient});

  @override
  Future<ResponseModel> getNotifications() async {
    return await apiClient.get(AppConstants.notificationsUrl);
  }

  @override
  Future<ResponseModel> getNotificationDetail(int id) async {
    return await apiClient.get('${AppConstants.notificationsUrl}/$id');
  }

  @override
  Future<ResponseModel> markAllAsRead() async {
    return await apiClient.post('${AppConstants.notificationsUrl}/mark-all-read', data: {});
  }
}
