import '../../../../core/services/network/response_model.dart';

abstract class AuthRepositoryInterface {
  Future<ResponseModel> sendOtp(String email);
  Future<ResponseModel> verifyOtp(String email, String otp);
  Future<ResponseModel> resendOtp(String email);
  Future<ResponseModel> completeSetup(String email, String name, String? profilePhotoPath);
}
