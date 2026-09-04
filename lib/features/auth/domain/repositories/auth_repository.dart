import 'package:image_picker/image_picker.dart';
import '../../../../core/services/network/multipart.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_constants.dart';
import 'auth_repository_interface.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class AuthRepository implements AuthRepositoryInterface {
  final ApiClient apiClient;

  AuthRepository({required this.apiClient});

  @override
  Future<ResponseModel> sendOtp(String email, {String referCode = ""}) async {
    return await apiClient.post(
      AppConstants.sendOtpUrl,
      data: {
        'email': email,
        'refer_code': referCode,
      },
    );
  }

  @override
  Future<ResponseModel> verifyOtp(String email, String otp) async {
    return await apiClient.post(
      AppConstants.verifyOtpUrl,
      data: {
        'email': email,
        'otp': otp,
      },
    );
  }

  @override
  Future<ResponseModel> resendOtp(String email) async {
    return await apiClient.post(
      AppConstants.resendOtpUrl,
      data: {'email': email},
    );
  }

  @override
  Future<ResponseModel> completeSetup(String email, String name, String whatsappNumber, String address, String? profilePhotoPath) async {
    if (profilePhotoPath != null && profilePhotoPath.isNotEmpty) {
      final multipartBody = [
        MultipartBody('profile_photo', XFile(profilePhotoPath)),
      ];
      return await apiClient.postMultipartData(
        AppConstants.completeSetupUrl,
        {
          'email': email,
          'name': name,
          'whatsapp_number': whatsappNumber,
          'address': address,
        },
        multipartBody,
        [],
      );
    } else {
      return await apiClient.post(
        AppConstants.completeSetupUrl,
        data: {
          'email': email,
          'name': name,
          'whatsapp_number': whatsappNumber,
          'address': address,
          'profile_photo': null,
        },
      );
    }
  }

  @override
  Future<ResponseModel> getUserProfile() async {
    return await apiClient.get(AppConstants.getUserUrl);
  }

  @override
  Future<ResponseModel> updateProfile({
    required String name,
    required String phoneNumber,
    required String destination,
    required String whatsappNumber,
    required String address,
    String? profilePhotoPath,
    String? logoPath,
  }) async {
    final body = {
      'name': name,
      'phone_number': phoneNumber,
      'destination': destination,
      'whatsapp_number': whatsappNumber,
      'address': address,
    };

    final List<MultipartBody> multipartBody = [];
    if (profilePhotoPath != null && profilePhotoPath.isNotEmpty) {
      multipartBody.add(MultipartBody('profile_photo', XFile(profilePhotoPath)));
    }
    if (logoPath != null && logoPath.isNotEmpty) {
      multipartBody.add(MultipartBody('logo', XFile(logoPath)));
    }

    return await apiClient.postMultipartData(
      AppConstants.updateProfileUrl,
      body,
      multipartBody,
      [],
    );
  }

  @override
  Future<ResponseModel> logout() async {
    return await apiClient.post(AppConstants.logoutUrl);
  }

  @override
  Future<ResponseModel> googleLogin(String email, String googleId) async {
    return await apiClient.post(
      AppConstants.googleLoginUrl,
      data: {
        'email': email,
        'google_id': googleId,
      },
    );
  }
}
