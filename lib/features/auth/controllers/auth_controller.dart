import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../routes/route_helper.dart';
import '../domain/repositories/auth_repository_interface.dart';
import '../domain/repositories/auth_repository.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../../../core/services/storage/token_manger.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/models/complete_setup_response.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  final AuthRepositoryInterface authRepository;

  AuthController({AuthRepositoryInterface? authRepository})
      : authRepository = authRepository ?? (Get.isRegistered<AuthRepositoryInterface>()
            ? Get.find<AuthRepositoryInterface>()
            : Get.put<AuthRepositoryInterface>(AuthRepository(apiClient: Get.find<ApiClient>())));

  final isLoading = false.obs;
  final isProfileLoading = false.obs;
  final imagePath = ''.obs;
  final logoPath = ''.obs;
  final profilePhotoUrl = ''.obs;
  final logoUrl = ''.obs;
  final _picker = ImagePicker();

  Future<void> pickImage() async {
    try {
      print("pickImage called, controller hash = ${identityHashCode(this)}");
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      print("pickImage result: ${image?.path}");
      if (image != null) {
        final file = File(image.path);
        final sizeInBytes = await file.length();
        final sizeInMb = sizeInBytes / (1024 * 1024);
        print("Image size: $sizeInMb MB");
        if (sizeInMb > 5) {
          CustomSnackbar.showError('Selected image is too large. Please select an image under 5MB.');
          return;
        }
        imagePath.value = image.path;
        print("imagePath updated to: ${imagePath.value}");
        if (SharedPrefs.getBool(AppConstants.isLoggedIn) == true) {
          await updateProfileChanges();
        }
      }
    } catch (e) {
      print("Error in pickImage: $e");
      CustomSnackbar.showError('Error picking image: $e');
    }
  }

  Future<void> pickLogo() async {
    try {
      final XFile? logo = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (logo != null) {
        final file = File(logo.path);
        final sizeInBytes = await file.length();
        final sizeInMb = sizeInBytes / (1024 * 1024);
        if (sizeInMb > 5) {
          CustomSnackbar.showError('Selected logo is too large. Please select an image under 5MB.');
          return;
        }
        logoPath.value = logo.path;
        if (SharedPrefs.getBool(AppConstants.isLoggedIn) == true) {
          await updateProfileChanges();
        }
      }
    } catch (e) {
      print("Error in pickLogo: $e");
      CustomSnackbar.showError('Error picking logo: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: AppConstants.googleServerClientId,
      );
      await GoogleSignIn.instance.signOut();
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate(scopeHint: ['email']);
      
      isLoading.value = true;
      final String email = googleUser.email;
      final String name = googleUser.displayName ?? '';
      final String? image = googleUser.photoUrl;
      final String googleId = googleUser.id;

      final response = await authRepository.googleLogin(email, googleId);
      if (response.isSuccess) {
        Future.delayed(const Duration(milliseconds: 300), () {
          CustomSnackbar.showSuccess(response.message);
        });

        int isNew = 1;
        if (response.body != null && response.body is Map) {
          if (response.body['data'] != null && response.body['data'] is Map && response.body['data']['is_new'] != null) {
            isNew = response.body['data']['is_new'];
          } else {
            isNew = response.body['is_new'] ?? 1;
          }
        }

        if (isNew == 1) {
          String? localImagePath;
          if (image != null && image.isNotEmpty) {
            try {
              final tempDir = await getTemporaryDirectory();
              final file = File('${tempDir.path}/google_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg');
              final downloadResponse = await http.get(Uri.parse(image));
              if (downloadResponse.statusCode == 200) {
                await file.writeAsBytes(downloadResponse.bodyBytes);
                localImagePath = file.path;
              }
            } catch (e) {
              debugPrint("Error downloading Google avatar for profile prefill: $e");
            }
          }
          if (localImagePath != null) {
            imagePath.value = localImagePath;
          } else {
            imagePath.value = '';
          }

          Get.offAllNamed(RouteHelper.getProfileSetupRoute(), arguments: {
            'email': email,
            'name': name,
          });
        } else {
          if (response.body != null && response.body is Map) {
            final responseData = response.body['data'] ?? response.body;
            final setupData = CompleteSetupData.fromJson(responseData);

            if (setupData.accessToken.isNotEmpty) {
              await TokenManager.saveToken(setupData.accessToken);
            }

            if (setupData.user != null) {
              final userJson = jsonEncode(setupData.user!.toJson());
              await SharedPrefs.setString(AppConstants.userData, userJson);
              rxUser.value = setupData.user;
              currentUser.value = UserInfoModel(
                name: setupData.user!.name,
                mobile: setupData.user!.phoneNumber ?? '',
              );
            }
          }

          await SharedPrefs.setBool(AppConstants.isLoggedIn, true);
          Get.offAllNamed(RouteHelper.getDashboardRoute());
        }
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (error) {
      debugPrint("Google sign-in error: $error");
      CustomSnackbar.showError("Google sign-in failed: $error");
    } finally {
      isLoading.value = false;
    }
  }
  final currentUser = Rxn<UserInfoModel>();
  final rxUser = Rxn<UserSetupModel>();
  final emailErrorText = RxnString();
  final nameErrorText = RxnString();
  final otpErrorText = RxnString();
  final List<TextEditingController> otpControllers = List.generate(4, (_) => TextEditingController());

  @override
  void onInit() {
    super.onInit();
    loadSavedUser();
    currentUser.value = UserInfoModel(
      name: nameController.text,
      mobile: phoneController.text,
    );

    // Clear error when user changes text
    emailController.addListener(() {
      if (emailErrorText.value != null) {
        emailErrorText.value = null;
      }
    });

    nameController.addListener(() {
      if (nameErrorText.value != null) {
        nameErrorText.value = null;
      }
    });

    for (var c in otpControllers) {
      c.addListener(() {
        if (otpErrorText.value != null) {
          otpErrorText.value = null;
        }
      });
    }
  }

  void loadSavedUser() {
    final userJson = SharedPrefs.getString(AppConstants.userData);
    if (userJson != null && userJson.isNotEmpty) {
      try {
        final Map<String, dynamic> userMap = jsonDecode(userJson);
        final user = UserSetupModel.fromJson(userMap);
        rxUser.value = user;
        if (nameController.text.isEmpty) {
          nameController.text = user.name;
        }
        if (emailController.text.isEmpty) {
          emailController.text = user.email;
        }
        if (phoneController.text.isEmpty) {
          phoneController.text = user.phoneNumber ?? '';
        }
        if (destinationController.text.isEmpty) {
          destinationController.text = user.destination ?? '';
        }
        if (profilePhotoUrl.value.isEmpty) {
          profilePhotoUrl.value = user.profilePhoto ?? '';
        }
        if (logoUrl.value.isEmpty) {
          logoUrl.value = user.logo ?? '';
        }
      } catch (e) {
        // Ignore parsing errors
      }
    }
  }

  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final destinationController = TextEditingController();
  final phoneController = TextEditingController();
  final referenceCodeController = TextEditingController();
  final selectedCountryCode = '+91'.obs;
  final selectedCountryFlag = '🇮🇳'.obs;
  final selectedCountryName = 'India'.obs;

  final List<Map<String, String>> countries = [
    {'name': 'India', 'code': '+91', 'flag': '🇮🇳'},
    {'name': 'United States', 'code': '+1', 'flag': '🇺🇸'},
    {'name': 'United Kingdom', 'code': '+44', 'flag': '🇬🇧'},
    {'name': 'United Arab Emirates', 'code': '+971', 'flag': '🇦🇪'},
    {'name': 'Australia', 'code': '+61', 'flag': '🇦🇺'},
    {'name': 'Canada', 'code': '+1', 'flag': '🇨🇦'},
    {'name': 'Germany', 'code': '+49', 'flag': '🇩🇪'},
    {'name': 'France', 'code': '+33', 'flag': '🇫🇷'},
    {'name': 'Japan', 'code': '+81', 'flag': '🇯🇵'},
    {'name': 'China', 'code': '+86', 'flag': '🇨🇳'},
    {'name': 'Brazil', 'code': '+55', 'flag': '🇧🇷'},
    {'name': 'Russia', 'code': '+7', 'flag': '🇷🇺'},
    {'name': 'South Africa', 'code': '+27', 'flag': '🇿🇦'},
    {'name': 'Singapore', 'code': '+65', 'flag': '🇸🇬'},
    {'name': 'Malaysia', 'code': '+60', 'flag': '🇲🇾'},
    {'name': 'Pakistan', 'code': '+92', 'flag': '🇵🇰'},
    {'name': 'Bangladesh', 'code': '+880', 'flag': '🇧🇩'},
    {'name': 'Sri Lanka', 'code': '+94', 'flag': '🇱🇰'},
    {'name': 'Nepal', 'code': '+977', 'flag': '🇳🇵'},
    {'name': 'Saudi Arabia', 'code': '+966', 'flag': '🇸🇦'},
  ];
  
  final formKey = GlobalKey<FormState>();



  Future<void> login() async {
    final email = emailController.text.trim();
    final emailError = AppValidators.validateEmail(email);
    emailErrorText.value = emailError;
    if (emailError != null) {
      return;
    }

    final referCode = referenceCodeController.text.trim();

    isLoading.value = true;
    try {
      final response = await authRepository.sendOtp(email, referCode: referCode);
      if (response.isSuccess) {
        for (var c in otpControllers) {
          c.clear();
        }
        otpErrorText.value = null;
        Get.toNamed(RouteHelper.getOtpRoute(), arguments: email);
        Future.delayed(const Duration(milliseconds: 300), () {
          CustomSnackbar.showSuccess(response.message);
        });
      } else {
        emailErrorText.value = response.message;
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      CustomSnackbar.showError('An error occurred. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    final email = Get.arguments as String? ?? emailController.text.trim();
    final otp = otpControllers.map((c) => c.text).join().trim();

    if (otp.length < 4) {
      otpErrorText.value = "Enter complete 4-digit OTP";
      return;
    }

    isLoading.value = true;
    try {
      final response = await authRepository.verifyOtp(email, otp);
      if (response.isSuccess) {
        // Show success snackbar safely
        Future.delayed(const Duration(milliseconds: 300), () {
          CustomSnackbar.showSuccess(response.message);
        });

        int isNew = 1;
        if (response.body != null && response.body is Map) {
          if (response.body['data'] != null && response.body['data'] is Map && response.body['data']['is_new'] != null) {
            isNew = response.body['data']['is_new'];
          } else {
            isNew = response.body['is_new'] ?? 1;
          }
        }

        if (isNew == 1) {
          Get.offAllNamed(RouteHelper.getProfileSetupRoute(), arguments: email);
        } else {
          if (response.body != null && response.body is Map) {
            final responseData = response.body['data'] ?? response.body;
            final setupData = CompleteSetupData.fromJson(responseData);

            // Save Access Token
            if (setupData.accessToken.isNotEmpty) {
              await TokenManager.saveToken(setupData.accessToken);
            }

            // Save User Data (in JSON string)
            if (setupData.user != null) {
              final userJson = jsonEncode(setupData.user!.toJson());
              await SharedPrefs.setString(AppConstants.userData, userJson);
              rxUser.value = setupData.user;

              // Set currentUser info model in controller
              currentUser.value = UserInfoModel(
                name: setupData.user!.name,
                mobile: setupData.user!.phoneNumber ?? '',
              );
            }
          }

          // Set is logged in to true
          await SharedPrefs.setBool(AppConstants.isLoggedIn, true);

          Get.offAllNamed(RouteHelper.getDashboardRoute());
        }
      } else {
        otpErrorText.value = response.message;
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      CustomSnackbar.showError('An error occurred. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    final email = Get.arguments as String? ?? emailController.text.trim();
    if (email.isEmpty) {
      CustomSnackbar.showError("Email is required to resend OTP");
      return;
    }

    isLoading.value = true;
    try {
      final response = await authRepository.resendOtp(email);
      if (response.isSuccess) {
        for (var c in otpControllers) {
          c.clear();
        }
        otpErrorText.value = null;

        Future.delayed(const Duration(milliseconds: 300), () {
          CustomSnackbar.showSuccess(response.message);
        });
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      CustomSnackbar.showError('An error occurred. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProfile() async {
    final name = nameController.text.trim();
    final nameError = AppValidators.validateEmpty(name, fieldName: "Name");
    nameErrorText.value = nameError;
    if (nameError != null) {
      return;
    }

    if (imagePath.value.isNotEmpty) {
      final file = File(imagePath.value);
      if (await file.exists()) {
        final sizeInBytes = await file.length();
        if (sizeInBytes > 5 * 1024 * 1024) {
          CustomSnackbar.showError('Profile photo is too large. Please select an image under 5MB.');
          return;
        }
      }
    }

    final email = Get.arguments as String? ?? emailController.text.trim();

    isLoading.value = true;
    try {
      final response = await authRepository.completeSetup(email, name, imagePath.value);
      if (response.isSuccess) {
        if (response.body != null) {
          final responseData = response.body['data'] ?? response.body;
          final setupData = CompleteSetupData.fromJson(responseData);

          // Save Access Token
          if (setupData.accessToken.isNotEmpty) {
            await TokenManager.saveToken(setupData.accessToken);
          }

          // Save User Data (in JSON string)
          if (setupData.user != null) {
            final userJson = jsonEncode(setupData.user!.toJson());
            await SharedPrefs.setString(AppConstants.userData, userJson);
            rxUser.value = setupData.user;

            // Set currentUser info model in controller
            currentUser.value = UserInfoModel(
              name: setupData.user!.name,
              mobile: setupData.user!.phoneNumber ?? '',
            );
          }
        }

        // Set is logged in to true
        await SharedPrefs.setBool(AppConstants.isLoggedIn, true);

        // Success snackbar
        Future.delayed(const Duration(milliseconds: 300), () {
          CustomSnackbar.showSuccess(response.message);
        });

        Get.offAllNamed(RouteHelper.getDashboardRoute());
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      CustomSnackbar.showError('An error occurred. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserProfile() async {
    isProfileLoading.value = true;
    try {
      final response = await authRepository.getUserProfile();
      if (response.isSuccess && response.body != null) {
        Map<String, dynamic>? userData;
        if (response.body['user'] != null) {
          userData = response.body['user'] as Map<String, dynamic>;
        } else if (response.body['data'] != null) {
          final dataObj = response.body['data'];
          if (dataObj is Map<String, dynamic>) {
            if (dataObj['user'] != null) {
              userData = dataObj['user'] as Map<String, dynamic>;
            } else {
              userData = dataObj;
            }
          }
        }
        if (userData != null) {
          final user = UserSetupModel.fromJson(userData);
          nameController.text = user.name;
          emailController.text = user.email;
          destinationController.text = user.destination ?? '';
          phoneController.text = user.phoneNumber ?? '';
          profilePhotoUrl.value = user.profilePhoto ?? '';
          logoUrl.value = user.logo ?? '';

          // Reset local picked file paths when fresh data is loaded
          imagePath.value = '';
          logoPath.value = '';

          // Save updated user data to shared preferences and update reactive state
          final userJson = jsonEncode(user.toJson());
          await SharedPrefs.setString(AppConstants.userData, userJson);
          rxUser.value = user;

          // Update current user info
          currentUser.value = UserInfoModel(
            name: user.name,
            mobile: user.phoneNumber ?? '',
          );
        }
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      CustomSnackbar.showError('Failed to load profile details.');
    } finally {
      isProfileLoading.value = false;
    }
  }

  Future<bool> updateProfileChanges() async {
    final name = nameController.text.trim();
    final dest = destinationController.text.trim();
    final phone = phoneController.text.trim();

    final nameError = AppValidators.validateEmpty(name, fieldName: 'Name');
    nameErrorText.value = nameError;
    if (nameError != null) {
      return false;
    }

    if (imagePath.value.isNotEmpty) {
      final file = File(imagePath.value);
      if (await file.exists()) {
        final sizeInBytes = await file.length();
        if (sizeInBytes > 5 * 1024 * 1024) {
          CustomSnackbar.showError('Profile photo is too large. Please select an image under 5MB.');
          return false;
        }
      }
    }

    if (logoPath.value.isNotEmpty) {
      final file = File(logoPath.value);
      if (await file.exists()) {
        final sizeInBytes = await file.length();
        if (sizeInBytes > 5 * 1024 * 1024) {
          CustomSnackbar.showError('Company logo is too large. Please select an image under 5MB.');
          return false;
        }
      }
    }

    isLoading.value = true;
    isProfileLoading.value = true;
    try {
      final response = await authRepository.updateProfile(
        name: name,
        phoneNumber: phone,
        destination: dest,
        profilePhotoPath: imagePath.value,
        logoPath: logoPath.value,
      );

      if (response.isSuccess) {
        Map<String, dynamic>? userData;
        if (response.body != null) {
          if (response.body['user'] != null) {
            userData = response.body['user'] as Map<String, dynamic>;
          } else if (response.body['data'] != null) {
            final dataObj = response.body['data'];
            if (dataObj is Map<String, dynamic>) {
              if (dataObj['user'] != null) {
                userData = dataObj['user'] as Map<String, dynamic>;
              } else {
                userData = dataObj;
              }
            }
          }
        }
        if (userData != null) {
          final user = UserSetupModel.fromJson(userData);

          // Save updated user data to shared preferences and update reactive state
          final userJson = jsonEncode(user.toJson());
          await SharedPrefs.setString(AppConstants.userData, userJson);
          rxUser.value = user;

          // Update current user info
          currentUser.value = UserInfoModel(
            name: user.name,
            mobile: user.phoneNumber ?? '',
          );

          // Clear local picked file paths since they have been uploaded and saved on server
          imagePath.value = '';
          logoPath.value = '';
          profilePhotoUrl.value = user.profilePhoto ?? '';
          logoUrl.value = user.logo ?? '';
        } else {
          // Update local state fallback if backend doesn't return user object directly
          final currentUserVal = rxUser.value;
          if (currentUserVal != null) {
            final updatedUser = UserSetupModel(
              id: currentUserVal.id,
              name: name,
              email: currentUserVal.email,
              destination: dest.isNotEmpty ? dest : currentUserVal.destination,
              phoneNumber: phone.isNotEmpty ? phone : currentUserVal.phoneNumber,
              profilePhoto: profilePhotoUrl.value,
              logo: logoUrl.value,
              emailVerifiedAt: currentUserVal.emailVerifiedAt,
            );
            final userJson = jsonEncode(updatedUser.toJson());
            await SharedPrefs.setString(AppConstants.userData, userJson);
            rxUser.value = updatedUser;
            currentUser.value = UserInfoModel(
              name: name,
              mobile: phone,
            );
          }
        }

        Future.delayed(const Duration(milliseconds: 300), () {
          CustomSnackbar.showSuccess(response.message);
        });
        return true;
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      CustomSnackbar.showError('Failed to update profile details.');
    } finally {
      isLoading.value = false;
      isProfileLoading.value = false;
    }
    return false;
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await authRepository.logout();
    } catch (e) {
      // Ignore API errors to ensure local logout still completes
    } finally {
      await TokenManager.clearToken();
      await SharedPrefs.remove(AppConstants.userData);
      await SharedPrefs.setBool(AppConstants.isLoggedIn, false);

      // Reset controller variables
      emailController.clear();
      nameController.clear();
      destinationController.clear();
      phoneController.clear();
      imagePath.value = '';
      logoPath.value = '';
      profilePhotoUrl.value = '';
      logoUrl.value = '';
      rxUser.value = null;

      isLoading.value = false;
      Get.offAllNamed(RouteHelper.getLoginRoute());
    }
  }
}

class UserInfoModel {
  final String name;
  final String mobile;

  UserInfoModel({required this.name, required this.mobile});
}
