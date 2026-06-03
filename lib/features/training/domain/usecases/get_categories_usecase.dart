import '../../../../core/services/network/response_model.dart';
import '../repositories/category_repository_interface.dart';

class GetCategoriesUseCase {
  final CategoryRepositoryInterface repository;

  GetCategoriesUseCase({required this.repository});

  Future<ResponseModel> execute() async {
    return await repository.getCategories();
  }
}
