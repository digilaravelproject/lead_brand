import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../domain/repositories/notifications_repository_interface.dart';
import '../domain/repositories/notifications_repository.dart';
import '../domain/usecases/get_notifications_usecase.dart';
import '../controllers/notifications_controller.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationsRepositoryInterface>(
      () => NotificationsRepository(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<GetNotificationsUseCase>(
      () => GetNotificationsUseCase(repository: Get.find<NotificationsRepositoryInterface>()),
      fenix: true,
    );

    Get.lazyPut<NotificationsController>(
      () => NotificationsController(getNotificationsUseCase: Get.find<GetNotificationsUseCase>()),
      fenix: true,
    );
  }
}
