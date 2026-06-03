import '../../../../core/services/network/response_model.dart';
import '../repositories/training_repository_interface.dart';

class GetTrainingDetailsUseCase {
  final TrainingRepositoryInterface repository;

  GetTrainingDetailsUseCase({required this.repository});

  Future<ResponseModel> execute(int id) async {
    return await repository.getTrainingDetails(id);
  }
}
