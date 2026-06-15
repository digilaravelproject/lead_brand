import 'package:get/get.dart';
import '../services/network/api_client.dart';
import '../../features/dashboard/controllers/dashboard_controller.dart';
import '../../features/plans/controllers/plans_controller.dart';
import '../../features/gallery/controllers/gallery_controller.dart';
import '../../features/video_ads/controllers/video_ads_controller.dart';
import '../../features/pdf_calendar/controllers/pdf_calendar_controller.dart';
import '../../features/settings/controllers/faq_controller.dart';
import '../../features/notifications/domain/repositories/notifications_repository_interface.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../../features/notifications/controllers/notifications_controller.dart';
import '../../features/training/domain/repositories/category_repository_interface.dart';
import '../../features/training/domain/repositories/category_repository.dart';
import '../../features/training/domain/usecases/get_categories_usecase.dart';
import '../../features/training/controllers/category_controller.dart';
import '../../features/training/domain/repositories/training_repository_interface.dart';
import '../../features/training/domain/repositories/training_repository.dart';
import '../../features/training/domain/usecases/get_trainings_usecase.dart';
import '../../features/training/domain/usecases/get_training_details_usecase.dart';
import '../../features/training/domain/usecases/search_trainings_usecase.dart';
import '../../features/training/controllers/training_controller.dart';
import '../../features/dashboard/domain/repositories/leads_repository_interface.dart';
import '../../features/dashboard/domain/repositories/leads_repository.dart';
import '../../features/dashboard/controllers/leads_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Core services
    Get.lazyPut(() => ApiClient(), fenix: true);
    
    // Dashboard
    Get.lazyPut(() => DashboardController(), fenix: true);
    Get.lazyPut<LeadsRepositoryInterface>(
      () => LeadsRepository(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut(() => LeadsController(leadsRepository: Get.find<LeadsRepositoryInterface>()), fenix: true);
    
    // Plans
    Get.lazyPut(() => PlansController(), fenix: true);
    
    // Gallery
    Get.lazyPut(() => GalleryController(), fenix: true);
    
    // Video Ads
    Get.lazyPut(() => VideoAdsController(), fenix: true);
    
    // PDF Calendar
    Get.lazyPut(() => PdfCalendarController(), fenix: true);
    
    // FAQs
    Get.lazyPut(() => FaqController(), fenix: true);
    
    // Notifications
    Get.lazyPut<NotificationsRepositoryInterface>(
      () => NotificationsRepository(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut(() => GetNotificationsUseCase(repository: Get.find<NotificationsRepositoryInterface>()), fenix: true);
    Get.lazyPut(() => NotificationsController(getNotificationsUseCase: Get.find<GetNotificationsUseCase>()), fenix: true);

    // Training Category
    Get.lazyPut<CategoryRepositoryInterface>(
      () => CategoryRepository(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut(() => GetCategoriesUseCase(repository: Get.find<CategoryRepositoryInterface>()), fenix: true);
    Get.lazyPut(() => CategoryController(getCategoriesUseCase: Get.find<GetCategoriesUseCase>()), fenix: true);

    // Training Items
    Get.lazyPut<TrainingRepositoryInterface>(
      () => TrainingRepository(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut(() => GetTrainingsUseCase(repository: Get.find<TrainingRepositoryInterface>()), fenix: true);
    Get.lazyPut(() => GetTrainingDetailsUseCase(repository: Get.find<TrainingRepositoryInterface>()), fenix: true);
    Get.lazyPut(() => SearchTrainingsUseCase(repository: Get.find<TrainingRepositoryInterface>()), fenix: true);
    Get.lazyPut(() => TrainingController(
      getTrainingsUseCase: Get.find<GetTrainingsUseCase>(),
      getTrainingDetailsUseCase: Get.find<GetTrainingDetailsUseCase>(),
      searchTrainingsUseCase: Get.find<SearchTrainingsUseCase>(),
    ), fenix: true);
  }
}

