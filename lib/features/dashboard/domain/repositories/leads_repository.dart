import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import 'leads_repository_interface.dart';

class LeadsRepository implements LeadsRepositoryInterface {
  final ApiClient apiClient;

  LeadsRepository({required this.apiClient});

  @override
  Future<ResponseModel> getLeads({String? status, String? search}) async {
    final Map<String, dynamic> queryParameters = {};
    if (status != null) {
      queryParameters['status'] = status;
    }
    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }
    return await apiClient.get(AppConstants.leadsUrl, queryParameters: queryParameters);
  }

  @override
  Future<ResponseModel> createLead(String fullName, String phoneNumber, String status) async {
    final Map<String, dynamic> data = {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'status': status,
    };
    return await apiClient.post(AppConstants.leadsUrl, data: data);
  }

  @override
  Future<ResponseModel> updateLead(int id, String fullName, String phoneNumber, String status) async {
    final Map<String, dynamic> data = {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'status': status,
    };
    return await apiClient.put('${AppConstants.leadsUrl}/$id', data: data);
  }

  @override
  Future<ResponseModel> updateLeadStatus(int id, String status) async {
    final Map<String, dynamic> data = {
      'status': status,
    };
    return await apiClient.post('${AppConstants.leadsUrl}/$id/change-status', data: data);
  }

  @override
  Future<ResponseModel> deleteLead(int id) async {
    return await apiClient.delete('${AppConstants.leadsUrl}/$id');
  }

  @override
  Future<ResponseModel> getMessages() async {
    return await apiClient.get(AppConstants.messagesUrl);
  }
}
