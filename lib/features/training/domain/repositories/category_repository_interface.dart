import '../../../../core/services/network/response_model.dart';

abstract class CategoryRepositoryInterface {
  Future<ResponseModel> getCategories();
}
