import '../../../../core/services/network/response_model.dart';

abstract class AuthRepositoryInterface {
  Future<ResponseModel> sendOtp(String email, {String referCode = ""});
  Future<ResponseModel> verifyOtp(String email, String otp);
  Future<ResponseModel> resendOtp(String email);
  Future<ResponseModel> completeSetup(String email, String name, String? profilePhotoPath);
  Future<ResponseModel> getUserProfile();
  Future<ResponseModel> updateProfile({
    required String name,
    required String phoneNumber,
    required String destination,
    String? profilePhotoPath,
    String? logoPath,
  });
  Future<ResponseModel> logout();
  Future<ResponseModel> googleLogin(String email, String googleId);
}
