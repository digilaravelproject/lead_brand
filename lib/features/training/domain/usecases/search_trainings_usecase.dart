import '../../../../core/services/network/response_model.dart';
import '../repositories/training_repository_interface.dart';

class SearchTrainingsUseCase {
  final TrainingRepositoryInterface repository;

  SearchTrainingsUseCase({required this.repository});

  Future<ResponseModel> execute({required String query, required String type}) async {
    return await repository.searchTrainings(query: query, type: type);
  }
}
