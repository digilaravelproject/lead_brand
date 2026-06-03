import '../../../../core/services/network/response_model.dart';
import '../repositories/legal_repository_interface.dart';

class GetPageUseCase {
  final LegalRepositoryInterface repository;

  GetPageUseCase({required this.repository});

  Future<ResponseModel> getTermsCondition() async {
    return await repository.getTermsCondition();
  }

  Future<ResponseModel> getPrivacyPolicy() async {
    return await repository.getPrivacyPolicy();
  }

  Future<ResponseModel> getAboutUs() async {
    return await repository.getAboutUs();
  }
}
