import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_constants.dart';
import 'category_repository_interface.dart';

class CategoryRepository implements CategoryRepositoryInterface {
  final ApiClient apiClient;

  CategoryRepository({required this.apiClient});

  @override
  Future<ResponseModel> getCategories() async {
    return await apiClient.get(AppConstants.trainingCategoriesUrl);
  }
}
