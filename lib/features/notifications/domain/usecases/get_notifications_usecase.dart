import '../../../../core/services/network/response_model.dart';
import '../repositories/notifications_repository_interface.dart';

class GetNotificationsUseCase {
  final NotificationsRepositoryInterface repository;

  GetNotificationsUseCase({required this.repository});

  Future<ResponseModel> execute() async {
    return await repository.getNotifications();
  }

  Future<ResponseModel> executeDetail(int id) async {
    return await repository.getNotificationDetail(id);
  }

  Future<ResponseModel> markAllRead() async {
    return await repository.markAllAsRead();
  }
}
