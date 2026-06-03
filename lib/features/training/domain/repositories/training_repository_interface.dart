import '../../../../core/services/network/response_model.dart';

abstract class TrainingRepositoryInterface {
  Future<ResponseModel> getTrainings({required String type, String? categoryId});
  Future<ResponseModel> getTrainingDetails(int id);
  Future<ResponseModel> searchTrainings({required String query, required String type});
}
