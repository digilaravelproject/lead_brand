import '../../../../core/services/network/response_model.dart';

abstract class ToolsRepositoryInterface {
  Future<ResponseModel> getTools();
  Future<ResponseModel> getToolDetail(int id);
}
