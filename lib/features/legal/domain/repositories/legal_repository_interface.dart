import '../../../../core/services/network/response_model.dart';

abstract class LegalRepositoryInterface {
  Future<ResponseModel> getTermsCondition();
  Future<ResponseModel> getPrivacyPolicy();
  Future<ResponseModel> getAboutUs();
}
