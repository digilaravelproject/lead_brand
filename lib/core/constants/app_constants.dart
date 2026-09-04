import '../services/config/env_config.dart';

class AppConstants {
    static String appName = EnvConfig.appName;
   // static const String baseUrl = 'https://sienna-owl-749505.hostingersite.com';
    static const String baseUrl = 'https://leadbrandapp.leadbrandhub.com';
   //static const String imageBaseUrl = 'https://sienna-owl-749505.hostingersite.com';
    static const String imageBaseUrl = 'https://leadbrandapp.leadbrandhub.com';
    static const String fontFamily = 'Poppins';
    static const String defaultTag = 'PCB_APP'; // default tag for log checking

    static const bool isHandleInternetScreen = true;
    static const bool isHandleErrorScreen = false;
    static const bool handleError = true; // manages logic-level error flow.
    static const bool showToaster = false; // manages UI-level notifications.

    // API base URLs

    // API endpoints

    static const String sendOtpUrl = '/api/auth/send-otp';
    static const String verifyOtpUrl = '/api/auth/verify-otp';
    static const String resendOtpUrl = '/api/auth/resend-otp';
    static const String completeSetupUrl = '/api/auth/complete-setup';
    static const String googleLoginUrl = '/api/auth/google-login';
    static const String getUserUrl = '/api/user';
    static const String updateProfileUrl = '/api/user/update-profile';
    static const String logoutUrl = '/api/logout';
    static const String faqsUrl = '/api/faqs';
    static const String termsConditionUrl = '/api/pages/terms_condition';
    static const String privacyPolicyUrl = '/api/pages/privacy_policy';
    static const String aboutUsUrl = '/api/pages/about_us';
    static const String notificationsUrl = '/api/notifications';
    static const String trainingCategoriesUrl = '/api/training-categories';
    static const String trainingsUrl = '/api/trainings';
    static const String trainingsSearchUrl = '/api/trainings/search';
    static const String bannersUrl = '/api/banners';
    static const String toolsUrl = '/api/tools';
    static const String leadsUrl = '/api/leads';
    static const String leadStatsUrl = '/api/leads/stats';
    static const String messagesUrl = '/api/messages';

    // Shared Preferences keys
    static const String theme = 'theme';
    static const String language = 'language';
    static const String token = 'token';
    static const String userData = 'user_data';
    static const String isLoggedIn = 'is_logged_in';

    // App URLs
    static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.leadbrandhub';

    // Google Sign-In Credentials (From Google Cloud Console -> APIs & Services -> Credentials -> OAuth 2.0 Web Client ID)
    // NOTE: Even on Android, you must use the WEB Client ID here.
    static const String googleServerClientId = '7458086472-dummywebclientid.apps.googleusercontent.com'; // Replace this with your actual Web Client ID
}
