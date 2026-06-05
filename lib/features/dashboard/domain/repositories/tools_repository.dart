import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import 'tools_repository_interface.dart';

class ToolsRepository implements ToolsRepositoryInterface {
  final ApiClient apiClient;

  ToolsRepository({required this.apiClient});

  @override
  Future<ResponseModel> getTools() async {
    return await apiClient.get(AppConstants.toolsUrl);
  }

  @override
  Future<ResponseModel> getToolDetail(int id) async {
    return await apiClient.get('${AppConstants.toolsUrl}/$id');
  }
}
