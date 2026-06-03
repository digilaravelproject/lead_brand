import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_constants.dart';
import 'training_repository_interface.dart';

class TrainingRepository implements TrainingRepositoryInterface {
  final ApiClient apiClient;

  TrainingRepository({required this.apiClient});

  @override
  Future<ResponseModel> getTrainings({required String type, String? categoryId}) async {
    final Map<String, dynamic> queryParameters = {
      'type': type,
    };
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParameters['category_id'] = categoryId;
    }
    return await apiClient.get(
      AppConstants.trainingsUrl,
      queryParameters: queryParameters,
    );
  }

  @override
  Future<ResponseModel> getTrainingDetails(int id) async {
    return await apiClient.get('${AppConstants.trainingsUrl}/$id');
  }

  @override
  Future<ResponseModel> searchTrainings({required String query, required String type}) async {
    final Map<String, dynamic> queryParameters = {
      'q': query,
      'type': type,
    };
    return await apiClient.get(
      AppConstants.trainingsSearchUrl,
      queryParameters: queryParameters,
    );
  }
}
