import '../../../../core/services/network/response_model.dart';
import '../repositories/tools_repository_interface.dart';

class GetToolsUseCase {
  final ToolsRepositoryInterface repository;

  GetToolsUseCase({required this.repository});

  Future<ResponseModel> execute() async {
    return await repository.getTools();
  }

  Future<ResponseModel> executeDetail(int id) async {
    return await repository.getToolDetail(id);
  }
}
