import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/auth_repository_interface.dart';
import '../../../../core/services/network/api_client.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepositoryInterface>(
      () => AuthRepository(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<AuthController>(
      () => AuthController(authRepository: Get.find<AuthRepositoryInterface>()),
      fenix: true,
    );
  }
}
