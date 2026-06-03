import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../domain/repositories/legal_repository.dart';
import '../domain/repositories/legal_repository_interface.dart';
import '../domain/usecases/get_page_usecase.dart';
import '../controllers/legal_controller.dart';

class LegalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LegalRepositoryInterface>(
      () => LegalRepository(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<GetPageUseCase>(
      () => GetPageUseCase(repository: Get.find<LegalRepositoryInterface>()),
      fenix: true,
    );

    Get.lazyPut<LegalController>(
      () => LegalController(getPageUseCase: Get.find<GetPageUseCase>()),
      fenix: true,
    );
  }
}
