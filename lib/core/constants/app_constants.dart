import '../services/config/env_config.dart';

class AppConstants {
    static String appName = EnvConfig.appName;
    static const String baseUrl = 'https://sienna-owl-749505.hostingersite.com';
    static const String fontFamily = 'Poppins';
    static const String defaultTag = 'PCB_APP'; // default tag for log checking

    static const bool isHandleInternetScreen = true;
    static const bool isHandleErrorScreen = false;
    static const bool handleError = true; // manages logic-level error flow.
    static const bool showToaster = false; // manages UI-level notifications.

    // API base URLs
    static const String imageUrl = baseUrl;

    // API endpoints
    static const String userSignupUrl = '/api/user_signup';
    static const String userLoginUrl = '/api/user_login';
    static const String otpVerifyUrl = '/api/otp_verify';
    static const String sendOtpUrl = '/api/auth/send-otp';
    static const String verifyOtpUrl = '/api/auth/verify-otp';
    static const String resendOtpUrl = '/api/auth/resend-otp';
    static const String completeSetupUrl = '/api/auth/complete-setup';

    // Shared Preferences keys
    static const String theme = 'theme';
    static const String language = 'language';
    static const String token = 'token';
    static const String userData = 'user_data';
    static const String isLoggedIn = 'is_logged_in';

    // App URLs
    static const String websiteUrl = 'https://google.com';
    static const String termsUrl = 'https://google.com';
    static const String privacyUrl = 'https://google.com';
    static const String aboutUrl = 'https://google.com';
    static const String packageId = 'com.leadbrandhub';
    static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=$packageId';
}
