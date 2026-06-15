import '../../../../core/services/network/response_model.dart';

abstract class LeadsRepositoryInterface {
  Future<ResponseModel> getLeads({String? status, String? search});
  Future<ResponseModel> createLead(String fullName, String phoneNumber, String status);
  Future<ResponseModel> updateLead(int id, String fullName, String phoneNumber, String status);
  Future<ResponseModel> updateLeadStatus(int id, String status);
  Future<ResponseModel> deleteLead(int id);
}
