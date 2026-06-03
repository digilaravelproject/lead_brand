import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_constants.dart';
import 'legal_repository_interface.dart';

class LegalRepository implements LegalRepositoryInterface {
  final ApiClient apiClient;

  LegalRepository({required this.apiClient});

  @override
  Future<ResponseModel> getTermsCondition() async {
    return await apiClient.get(AppConstants.termsConditionUrl);
  }

  @override
  Future<ResponseModel> getPrivacyPolicy() async {
    return await apiClient.get(AppConstants.privacyPolicyUrl);
  }

  @override
  Future<ResponseModel> getAboutUs() async {
    return await apiClient.get(AppConstants.aboutUsUrl);
  }
}
