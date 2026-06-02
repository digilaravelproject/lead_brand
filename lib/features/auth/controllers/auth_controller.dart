import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../routes/route_helper.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final imagePath = ''.obs;
  final logoPath = ''.obs;
  final _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      imagePath.value = image.path;
    }
  }

  Future<void> pickLogo() async {
    final XFile? logo = await _picker.pickImage(source: ImageSource.gallery);
    if (logo != null) {
      logoPath.value = logo.path;
    }
  }
  final emailController = TextEditingController(text: 'test@blessapp.com');
  final otpController = TextEditingController();
  final nameController = TextEditingController(text: 'Firoz Mohammad');
  final designationController = TextEditingController(text: 'Software Developer');
  final phoneController = TextEditingController(text: '9876543210');
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

  @override
  void onClose() {
    emailController.dispose();
    otpController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void login() {
    Get.toNamed(RouteHelper.getOtpRoute());
  }

  void verifyOtp() {
    Get.toNamed(RouteHelper.getProfileSetupRoute());
  }

  void saveProfile() {
    Get.offAllNamed(RouteHelper.getDashboardRoute());
  }

  void logout() {
    Get.offAllNamed(RouteHelper.getLoginRoute());
  }
}
