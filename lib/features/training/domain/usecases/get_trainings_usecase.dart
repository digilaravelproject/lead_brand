import '../../../../core/services/network/response_model.dart';
import '../repositories/training_repository_interface.dart';

class GetTrainingsUseCase {
  final TrainingRepositoryInterface repository;

  GetTrainingsUseCase({required this.repository});

  Future<ResponseModel> execute({required String type, String? categoryId}) async {
    return await repository.getTrainings(type: type, categoryId: categoryId);
  }
}
