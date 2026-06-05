import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/image_constants.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../../auth/domain/models/complete_setup_response.dart';

class BrandingBanner extends StatelessWidget {
  final String fallbackName;
  final String fallbackPhone;
  final String fallbackEmail;

  const BrandingBanner({
    Key? key,
    required this.fallbackName,
    required this.fallbackPhone,
    required this.fallbackEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userJson = SharedPrefs.getString(AppConstants.userData);
    UserSetupModel? user;
    if (userJson != null && userJson.isNotEmpty) {
      try {
        user = UserSetupModel.fromJson(jsonDecode(userJson));
      } catch (_) {}
    }

    final String displayName = user?.name.isNotEmpty == true ? user!.name : fallbackName;
    final String displayPhone = user?.phoneNumber?.isNotEmpty == true ? user!.phoneNumber! : fallbackPhone;
    final String displayEmail = user?.email.isNotEmpty == true ? user!.email : fallbackEmail;
    final String displayDesignation = user?.destination?.isNotEmpty == true ? user!.destination! : "SOFTWARE COMPANY";
    final String? profilePhoto = user?.profilePhoto;
    final String? logo = user?.logo;

    final String lang = SharedPrefs.getString(AppConstants.language) ?? 'en';

    final sloganMap = {
      'en': "Doctors Save Lives, We Save Lifestyle",
      'hi': "डॉक्टर जीवन बचाते हैं, हम लाइफस्टाइल बचाते हैं",
      'mr': "डॉक्टर जीवन वाचवतात, आम्ही जीवनशैली वाचवतो",
      'gu': "ડોકટરો જીવન બચાવે છે, અમે જીવનશૈલી બચાવીએ છીએ",
    };

    final consultancyTitleMap = {
      'en': "Servicing Consultancy",
      'hi': "सर्विसिंग कंसल्टेंसी",
      'mr': "सर्व्हिसिंग कन्सल्टन्सी",
      'gu': "સર્વિસિંગ કન્સલ્ટન્સી",
    };

    final disclaimerMap = {
      'en': "DISCLAIMER: The above concept has been developed after research by financial experts. Results are based on current bonus & FAB rates announced by respective company. For Premium budget, nearest sum assured has been taken. This is a special concept designed only for training purpose, Terms & Conditions will be apply. Depending on age, actual premium may increase or decrease. This is not a single policy but combination of policy design for cater people special needs and requirements.",
      'hi': "अस्वीकरण: उपरोक्त अवधारणा वित्तीय विशेषज्ञों द्वारा शोध के बाद विकसित की गई है। परिणाम संबंधित कंपनी द्वारा घोषित वर्तमान बोनस और एफएबी दरों पर आधारित हैं। प्रीमियम बजट के लिए, निकटतम बीमा राशि ली गई है। यह एक विशेष अवधारणा है जो केवल प्रशिक्षण उद्देश्य के लिए डिज़ाइन की गई है, नियम और शर्तें लागू होंगी। उम्र के आधार पर, वास्तविक प्रीमियम बढ़ या घट सकता है। यह कोई एकल पॉलिसी नहीं है बल्कि लोगों की विशेष जरूरतों और आवश्यकताओं को पूरा करने के लिए डिज़ाइन की गई पॉलिसियों का संयोजन है।",
      'mr': "अस्वीकरण: वरील संकल्पना वित्तीय तज्ञांच्या संशोधनानंतर विकसित केली गेली आहे. निकाल संबंधित कंपनीने घोषित केलेल्या चालू बोनस आणि FAB दरांवर आधारित आहेत. प्रीमियम बजेटसाठी, जवळची विमा रक्कम घेतली गेली आहे. ही केवळ प्रशिक्षणाच्या उद्देशाने तयार केलेली विशेष संकल्पना आहे, अटी व शर्ती लागू राहतील. वयानुसार, वास्तविक प्रीमियम वाढू किंवा कमी होऊ शकतो. ही एकच पॉलिसी नसून लोकांच्या विशेष गरजा आणि आवश्यकता पूर्ण करण्यासाठी डिझाइन केलेल्या पॉलिसींचे संयोजन आहे।",
      'gu': "ડિસ્ક્લેમર: ઉપરોક્ત ખ્યાલ નાણાકીય નિષ્ણાતો દ્વારા સંશોધન પછી વિકસાવવામાં આવ્યો છે. પરિણામો સંબંધિત કંપની દ્વારા જાહેર કરાયેલા વર્તમાન બોનસ અને FAB દરો પર આધારિત છે. પ્રીમિયમ બજેટ માટે, નજીકની વીમા રકમ લેવામાં આવી છે. આ માત્ર તાલીમ હેતુ માટે રચાયેલ એક વિશેષ ખ્યાલ છે, નિયમો અને શરતો લાગુ થશે. ઉંમરના આધારે, વાસ્તવિક પ્રીમિયમ વધી કે ઘટી શકે છે. આ કોઈ એક પોલિસી નથી પરંતુ લોકોની વિશેષ જરૂરિયાતો અને આવશ્યકતાઓને પૂરી કરવા માટે રચાયેલ પોલિસીઓનું સંયોજન છે.",
    };

    final slogan = sloganMap[lang] ?? sloganMap['en']!;
    final consultancyTitle = consultancyTitleMap[lang] ?? consultancyTitleMap['en']!;
    final disclaimer = disclaimerMap[lang] ?? disclaimerMap['en']!;

    return Container(
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Profile Image (Left-most, spans full height of the banner)
          Container(
            width: 72,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(right: BorderSide(color: Colors.grey[200]!, width: 1.5)),
            ),
            clipBehavior: Clip.antiAlias,
            child: (profilePhoto != null && profilePhoto.isNotEmpty)
                ? (profilePhoto.startsWith('/') || profilePhoto.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: profilePhoto.startsWith('/')
                            ? '${AppConstants.imageBaseUrl}$profilePhoto'
                            : profilePhoto,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildFallbackLogo(logo),
                        errorWidget: (context, url, error) => _buildFallbackLogo(logo),
                      )
                    : Image.file(
                        File(profilePhoto),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildFallbackLogo(logo),
                      ))
                : _buildFallbackLogo(logo),
          ),
          const SizedBox(width: 5),

          // 2. Right-side content (Info Section, Consultancy Section, and Disclaimer)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3, bottom: 3, right: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Info Section (Slogan, Name, Designation at top; Phone, Email, Logo at bottom)
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Slogan
                              Text(
                                slogan,
                                style: const TextStyle(
                                  color: Color(0xFF2E7D32), // Premium Green
                                  fontSize: 7.2,
                                  fontWeight: FontWeight.w900,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 1),
                              // Name
                              Text(
                                displayName.toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF1E3A8A), // Dark Indigo/Blue
                                  fontSize: 10.8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                  height: 1.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 1),
                              // Designation
                              Text(
                                displayDesignation.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 6.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 1.5),
                              // Phone, Email and Logo positioned side-by-side
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // WhatsApp & Phone
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(0.8),
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF25D366),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.phone,
                                                color: Colors.white,
                                                size: 6.5,
                                              ),
                                            ),
                                            const SizedBox(width: 3),
                                            Expanded(
                                              child: Text(
                                                displayPhone,
                                                style: const TextStyle(
                                                  color: Color(0xFFD32F2F), // Dark Red
                                                  fontSize: 8.2,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 1),
                                        // Email
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.email,
                                              color: Colors.black87,
                                              size: 8,
                                            ),
                                            const SizedBox(width: 3),
                                            Expanded(
                                              child: Text(
                                                displayEmail,
                                                style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 6.8,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  // Logo Section (Yellow Circle, next to contact info)
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFFBBF24), // Premium Yellow Background
                                      border: Border.all(color: Colors.white, width: 1.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 2,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: (logo != null && logo.isNotEmpty)
                                        ? (File(logo).existsSync()
                                            ? Image.file(
                                                File(logo),
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => const Center(
                                                  child: Icon(
                                                    Icons.business,
                                                    color: Colors.white,
                                                    size: 15,
                                                  ),
                                                ),
                                              )
                                            : CachedNetworkImage(
                                                imageUrl: logo.startsWith('http')
                                                    ? logo
                                                    : (logo.startsWith('/')
                                                        ? '${AppConstants.imageBaseUrl}$logo'
                                                        : '${AppConstants.imageBaseUrl}/$logo'),
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) => const Center(
                                                  child: SizedBox(
                                                    width: 12,
                                                    height: 12,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 1.5,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                errorWidget: (context, url, error) => const Center(
                                                  child: Icon(
                                                    Icons.business,
                                                    color: Colors.white,
                                                    size: 15,
                                                  ),
                                                ),
                                              ))
                                        : const Center(
                                            child: Icon(
                                              Icons.business,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),

                        // Servicing Consultancy Section (Right-most)
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                consultancyTitle,
                                style: const TextStyle(
                                  color: Color(0xFF1E3A8A), // Dark Indigo/Blue
                                  fontSize: 7.2,
                                  fontWeight: FontWeight.w900,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 1),
                              Expanded(
                                child: SingleChildScrollView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: _buildConsultancyItems(lang),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 1.5),
                  // Disclaimer Section (at the bottom of right-side content)
                  Text(
                    disclaimer,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 4.2,
                      fontWeight: FontWeight.w500,
                      height: 1.05,
                    ),
                    textAlign: TextAlign.justify,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackLogo(String? logoPath) {
    if (logoPath != null && logoPath.isNotEmpty) {
      if (logoPath.startsWith('/') || logoPath.startsWith('http')) {
        return CachedNetworkImage(
          imageUrl: logoPath.startsWith('/')
              ? '${AppConstants.imageBaseUrl}$logoPath'
              : logoPath,
          fit: BoxFit.cover,
          placeholder: (context, url) => Image.asset(
            ImageConstants.logo,
            fit: BoxFit.cover,
          ),
          errorWidget: (context, url, error) => Image.asset(
            ImageConstants.logo,
            fit: BoxFit.cover,
          ),
        );
      } else {
        return Image.file(
          File(logoPath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            ImageConstants.logo,
            fit: BoxFit.cover,
          ),
        );
      }
    }
    return Image.asset(
      ImageConstants.logo,
      fit: BoxFit.cover,
    );
  }

  List<Widget> _buildConsultancyItems(String lang) {
    final consultancyItemsMap = {
      'en': [
        "Premium Payment",
        "Maturity Claim",
        "Policy Revival",
        "Policy Loan",
        "Change in Address",
        "Change in Nomination",
      ],
      'hi': [
        "प्रीमियम भुगतान",
        "परिपक्वता दावा",
        "पॉलिसी पुनरुद्धार",
        "पॉलिसी ऋण",
        "पते में परिवर्तन",
        "नामांकन में परिवर्तन",
      ],
      'mr': [
        "प्रीमियम भरणे",
        "मॅच्युरिटी क्लेम",
        "पॉलिसी पुनरुज्जीवन",
        "पॉलिसी कर्ज",
        "पत्ता बदल",
        "वारसदार बदल",
      ],
      'gu': [
        "પ્રીમિયમ ચુકવણી",
        "મેચ્યોરિટી ક્લેમ",
        "પોલિસી પુનઃજીવન",
        "પોલિસી લોન",
        "સરનામામાં ફેરફાર",
        "નામાંકનમાં ફેરફાર",
      ],
    };

    final List<String> items = consultancyItemsMap[lang] ?? consultancyItemsMap['en']!;

    return items.map((item) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.diamond,
            size: 3.8,
            color: Colors.blue[800],
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              item,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 5.8,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    )).toList();
  }
}
