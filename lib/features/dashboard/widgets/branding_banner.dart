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
  final int styleIndex;

  const BrandingBanner({
    Key? key,
    required this.fallbackName,
    required this.fallbackPhone,
    required this.fallbackEmail,
    this.styleIndex = 0,
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
    final String displayWhatsapp = user?.whatsappNumber?.isNotEmpty == true ? user!.whatsappNumber! : displayPhone;
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
      'bn': "ডাক্তাররা জীবন বাঁচান, আমরা জীবনযাত্রা বাঁচাই",
      'te': "వైద్యులు ప్రాణాలను కాపాడతారు, మేము జీవనశైలిని కాపాడుతాము",
      'ta': "மருத்துவர்கள் உயிர்களை காப்பாற்றுகிறார்கள், நாங்கள் வாழ்க்கை முறையை காப்பாற்றுகிறோம்",
      'kn': "ವೈದ್ಯರು ಜೀವಗಳನ್ನು ಉಳಿಸುತ್ತಾರೆ, ನಾವು ಜೀವನಶೈಲಿಯನ್ನು ಉಳಿಸುತ್ತೇವೆ",
      'pa': "ਡਾਕਟਰ ਜ਼ਿੰਦਗੀਆਂ ਬਚਾਉਂਦੇ ਹਨ, ਅਸੀਂ ਜੀਵਨ ਸ਼ੈਲੀ ਬਚਾਉਂਦੇ ਹਾਂ",
    };

    final consultancyTitleMap = {
      'en': "Servicing Consultancy",
      'hi': "सर्विसिंग कंसल्टेंसी",
      'mr': "सर्व्हिसिंग कन्सल्टन्सी",
      'gu': "સર્વિસિંગ કન્સલ્ટન્સી",
      'bn': "সার্ভিসিং কনসালটেন্সি",
      'te': "సర్వీసింగ్ కన్సల్టెన్సీ",
      'ta': "சேவை ஆலோசனை",
      'kn': "ಸರ್ವಿಸಿಂಗ್ ಕನ್ಸಲ್ಟೆನ್ಸಿ",
      'pa': "ਸਰਵਿਸਿੰਗ ਕਨਸਲਟੈਂਸੀ",
    };

    final disclaimerMap = {
      'en': "DISCLAIMER: Concepts based on current company bonus/FAB rates & nearest sum assured. For training & illustration only; T&C apply. Actual premium may vary by age.",
      'hi': "अस्वीकरण: यह अवधारणा कंपनी के वर्तमान बोनस/FAB दरों पर आधारित है। केवल प्रशिक्षण व प्रेजेंटेशन उद्देश्य हेतु; नियम व शर्तें लागू। उम्र के अनुसार प्रीमियम बदल सकता है।",
      'mr': "अस्वीकरण: ही संकल्पना कंपनीच्या चालू बोनस/FAB दरांवर आधारित आहे. केवळ प्रशिक्षण व सादरीकरणासाठी; नियम व अटी लागू. वयानुसार प्रीमियम बदलू शकतो.",
      'gu': "ડિસ્ક્લેમર: આ ખ્યાલ કંપનીના વર્તમાન બોનસ/FAB દરો પર આધારિત છે. માત્ર તાલીમ અને પ્રેઝન્ટેશન હેતુ માટે; નિયમો અને શરતો લાગુ. ઉંમર અનુસાર પ્રીમિયમ બદલાઈ શકે છે.",
      'bn': "দাবিত্যাগ: এই ধারণাটি কোম্পানির বর্তমান বোনাস/FAB হারের ওপর ভিত্তি করে তৈরি। শুধুমাত্র প্রশিক্ষণ ও উপস্থাপনার উদ্দেশ্যে; শর্তাবলী প্রযোজ্য। বয়স অনুযায়ী প্রিমিয়াম পরিবর্তিত হতে পারে।",
      'te': "నిరాకరణ: ఈ కాన్సెప్ట్ ప్రస్తుత బోనస్/FAB రేట్లపై ఆధారపడి ఉంటుంది. కేవలం శిక్షణ మరియు ప్రదర్శన ప్రయోజనాల కోసం మాత్రమే; నిబంధనలు వర్తిస్తాయి. వయస్సును బట్టి ప్రీమియం మారవచ్చు.",
      'ta': "பொறுப்புத்துறப்பு: இந்த கருத்து நிறுவனத்தின் தற்போதைய போனஸ்/FAB விகிதங்களை அடிப்படையாகக் கொண்டது. பயிற்சி நோக்கத்திற்காக மட்டுமே; விதிமுறைகள் பொருந்தும். வயதைப் பொறுத்து பிரீமியம் மாறுபடலாம்.",
      'kn': "ಹಕ್ಕುತ್ಯಾಗ: ಈ ಪರಿಕಲ್ಪನೆಯು ಪ್ರಸ್ತುತ ಬೋನಸ್/FAB ದರಗಳನ್ನು ಆಧರಿಸಿದೆ. ಕೇವಲ ತರಬೇತಿ ಮತ್ತು ವಿವರಣೆಯ ಉದ್ದೇಶಕ್ಕಾಗಿ ಮಾತ್ರ; ನಿಯಮಗಳು ಅನ್ವಯಿಸುತ್ತವೆ. ವಯಸ್ಸಿನ ಆಧಾರದ ಮೇಲೆ ಪ್ರೀಮಿಯಂ ಬದಲಾಗಬಹುದು.",
      'pa': "ਬੇਦਾਅਵਾ: ਇਹ ਧਾਰਨਾ ਕੰਪਨੀ ਦੇ ਮੌਜੂਦਾ ਬੋਨਸ/FAB ਦਰਾਂ 'ਤੇ ਆਧਾਰਿਤ ਹੈ। ਸਿਰਫ਼ ਸਿਖਲਾਈ ਅਤੇ ਪੇਸ਼ਕਾਰੀ ਦੇ ਮਕਸਦ ਲਈ; ਨਿਯਮ ਅਤੇ ਸ਼ਰਤਾਂ ਲਾਗੂ। ਉਮਰ ਅਨੁਸਾਰ ਪ੍ਰੀਮੀਅਮ ਬਦਲ ਸਕਦਾ ਹੈ।",
    };

    final slogan = sloganMap[lang] ?? sloganMap['en']!;
    final consultancyTitle = consultancyTitleMap[lang] ?? consultancyTitleMap['en']!;
    final disclaimer = disclaimerMap[lang] ?? disclaimerMap['en']!;

    // 100 style calculations: 10 themes, 10 blocks of hiding/mirroring configurations
    final int baseThemeIndex = styleIndex % 10;
    final bool photoOnRight = (styleIndex % 20) >= 10;
    final int block = styleIndex ~/ 10;

    bool showConsultancy = true;
    bool showProfilePhoto = true;
    bool showLogo = true;
    bool showPhone = true;
    bool showEmail = true;
    bool showDesignation = true;

    if (block == 2) {
      showConsultancy = false;
    } else if (block == 3) {
      showProfilePhoto = false;
    } else if (block == 4) {
      showLogo = false;
    } else if (block == 5) {
      showPhone = false;
    } else if (block == 6) {
      showEmail = false;
    } else if (block == 7) {
      showDesignation = false;
    } else if (block == 8) {
      showProfilePhoto = false;
      showLogo = false;
    } else if (block == 9) {
      showConsultancy = false;
      showEmail = false;
      showDesignation = false;
    }

    Color bg = Colors.white;
    Color textColor = Colors.black;
    Color primaryText = const Color(0xFF1E3A8A); // indigo
    Color secondaryText = Colors.black87;
    Color phoneColor = const Color(0xFFD32F2F); // red
    Color sloganColor = const Color(0xFF2E7D32); // green
    Color disclaimerColor = Colors.black54;
    Color logoBg = const Color(0xFFFBBF24); // gold
    Color dividerCol = Colors.grey[200]!;
    BoxDecoration? borderDecor;
    LinearGradient? bgGradient;

    switch (baseThemeIndex) {
      case 1: // Dark Obsidian Gold
        bg = const Color(0xFF080B11);
        textColor = Colors.white;
        primaryText = const Color(0xFFEAA515); // premium gold
        secondaryText = Colors.white70;
        phoneColor = const Color(0xFFFFD700);
        sloganColor = const Color(0xFFFFD700);
        disclaimerColor = Colors.white.withValues(alpha: 0.88);
        logoBg = const Color(0xFF121722);
        dividerCol = const Color(0xFF1A2333);
        break;
      case 2: // Royal Blue & Silver
        bg = const Color(0xFF0D1B2A);
        textColor = Colors.white;
        primaryText = const Color(0xFFE0E1DD); // silver
        secondaryText = Colors.white70;
        phoneColor = const Color(0xFF778DA9);
        sloganColor = const Color(0xFF778DA9);
        disclaimerColor = Colors.white.withValues(alpha: 0.88);
        logoBg = const Color(0xFF1B263B);
        dividerCol = const Color(0xFF415A77);
        break;
      case 3: // Forest Green Mint
        bg = const Color(0xFF1A362D);
        textColor = Colors.white;
        primaryText = const Color(0xFF5ED3A5); // mint
        secondaryText = Colors.white70;
        phoneColor = const Color(0xFF5ED3A5);
        sloganColor = const Color(0xFF5ED3A5);
        disclaimerColor = Colors.white.withValues(alpha: 0.88);
        logoBg = const Color(0xFF11251E);
        dividerCol = const Color(0xFF244F42);
        break;
      case 4: // Crimson Luxury
        bg = const Color(0xFF4A0E17);
        textColor = Colors.white;
        primaryText = const Color(0xFFD4AF37); // luxury gold
        secondaryText = Colors.white70;
        phoneColor = const Color(0xFFFFD700);
        sloganColor = const Color(0xFFFFD700);
        disclaimerColor = Colors.white.withValues(alpha: 0.88);
        logoBg = const Color(0xFF2D070C);
        dividerCol = const Color(0xFF6B1A24);
        break;
      case 5: // Minimal Modern Light (Gray/White)
        bg = const Color(0xFFF3F4F6);
        textColor = Colors.black;
        primaryText = const Color(0xFF111827);
        secondaryText = const Color(0xFF4B5563);
        phoneColor = const Color(0xFF111827);
        sloganColor = const Color(0xFF4B5563);
        disclaimerColor = const Color(0xFF1F2937);
        logoBg = const Color(0xFFE5E7EB);
        dividerCol = const Color(0xFFD1D5DB);
        break;
      case 6: // Gradient Dusk (Purple to Blue)
        bgGradient = const LinearGradient(
          colors: [Color(0xFF3F2B96), Color(0xFFA8C0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        textColor = Colors.white;
        primaryText = Colors.white;
        secondaryText = Colors.white70;
        phoneColor = Colors.white;
        sloganColor = Colors.yellowAccent;
        disclaimerColor = Colors.white.withValues(alpha: 0.92);
        logoBg = const Color(0x33FFFFFF);
        dividerCol = Colors.white30;
        break;
      case 7: // Gradient Sunrise
        bgGradient = const LinearGradient(
          colors: [Color(0xFFF12711), Color(0xFFF5AF19)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        textColor = Colors.white;
        primaryText = Colors.white;
        secondaryText = Colors.white70;
        phoneColor = Colors.yellowAccent;
        sloganColor = Colors.white;
        disclaimerColor = Colors.white.withValues(alpha: 0.92);
        logoBg = const Color(0x33FFFFFF);
        dividerCol = Colors.white30;
        break;
      case 8: // Clean Slate
        bg = const Color(0xFF1E293B);
        textColor = Colors.white;
        primaryText = const Color(0xFF38BDF8); // sky blue
        secondaryText = Colors.white70;
        phoneColor = const Color(0xFF38BDF8);
        sloganColor = const Color(0xFF38BDF8);
        disclaimerColor = Colors.white.withValues(alpha: 0.88);
        logoBg = const Color(0xFF0F172A);
        dividerCol = const Color(0xFF334155);
        break;
      case 9: // Golden Border Classic
        bg = Colors.white;
        textColor = Colors.black;
        primaryText = const Color(0xFF1E3A8A);
        secondaryText = Colors.black87;
        phoneColor = const Color(0xFFD32F2F);
        sloganColor = const Color(0xFF2E7D32);
        disclaimerColor = Colors.black87;
        logoBg = const Color(0xFFFBBF24);
        dividerCol = Colors.grey[200]!;
        borderDecor = BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEAA515), width: 1.5),
        );
        break;
      default: // Style 0: Original Classic White
        bg = Colors.white;
        textColor = Colors.black;
        primaryText = const Color(0xFF1E3A8A);
        secondaryText = Colors.black87;
        phoneColor = const Color(0xFFD32F2F);
        sloganColor = const Color(0xFF2E7D32);
        disclaimerColor = Colors.black87;
        logoBg = const Color(0xFFFBBF24);
        dividerCol = Colors.grey[200]!;
    }

    final profileWidget = Container(
      width: 78,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: bgGradient == null ? bg : Colors.transparent,
        border: Border(
          right: photoOnRight ? BorderSide.none : BorderSide(color: dividerCol, width: 1),
          left: photoOnRight ? BorderSide(color: dividerCol, width: 1) : BorderSide.none,
        ),
      ),
      alignment: Alignment.center,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: (profilePhoto != null && profilePhoto.isNotEmpty)
            ? (profilePhoto.startsWith('/') || profilePhoto.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: profilePhoto.startsWith('/')
                        ? '${AppConstants.imageBaseUrl}$profilePhoto'
                        : profilePhoto,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => _buildFallbackLogo(logo),
                    errorWidget: (context, url, error) => _buildFallbackLogo(logo),
                  )
                : Image.file(
                    File(profilePhoto),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => _buildFallbackLogo(logo),
                  ))
            : _buildFallbackLogo(logo),
      ),
    );

    // Build the sub-sections
    final infoSectionWidget = SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Slogan
          Text(
            slogan,
            style: TextStyle(
              color: sloganColor,
              fontSize: 6.8,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 0.5),
          // Name
          Text(
            displayName.toUpperCase(),
            style: TextStyle(
              color: primaryText,
              fontSize: 9.8,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 0.5),
          // Designation
          if (showDesignation)
            Text(
              displayDesignation.toUpperCase(),
              style: TextStyle(
                color: secondaryText,
                fontSize: 5.8,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (showDesignation) const SizedBox(height: 1.0),
          // Phone, Email and Logo Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phone
                    if (showPhone)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(0.8),
                            decoration: const BoxDecoration(
                              color: Colors.blueAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.phone,
                              color: Colors.white,
                              size: 5.8,
                            ),
                          ),
                          const SizedBox(width: 2.5),
                          Expanded(
                            child: Text(
                              displayPhone,
                              style: TextStyle(
                                color: phoneColor,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    if (showPhone) const SizedBox(height: 0.8),
                    // WhatsApp
                    if (showPhone)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(0.8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF25D366),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chat,
                              color: Colors.white,
                              size: 5.8,
                            ),
                          ),
                          const SizedBox(width: 2.5),
                          Expanded(
                            child: Text(
                              displayWhatsapp,
                              style: TextStyle(
                                color: phoneColor,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    if (showPhone && showEmail) const SizedBox(height: 0.8),
                    // Email
                    if (showEmail)
                      Row(
                        children: [
                          Icon(
                            Icons.email,
                            color: textColor.withOpacity(0.7),
                            size: 7.0,
                          ),
                          const SizedBox(width: 2.5),
                          Expanded(
                            child: Text(
                              displayEmail,
                              style: TextStyle(
                                color: textColor.withOpacity(0.9),
                                fontSize: 6.2,
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
              const SizedBox(width: 4),
              // Logo Section
              if (showLogo)
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: logoBg,
                    border: Border.all(color: Colors.white, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 2.5,
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
                                  size: 18,
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
                                  width: 15,
                                  height: 15,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.8,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => const Center(
                                child: Icon(
                                  Icons.business,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ))
                      : const Center(
                          child: Icon(
                            Icons.business,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                ),
            ],
          ),
        ],
      ),
    );

    final consultancySectionWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          consultancyTitle,
          style: TextStyle(
            color: primaryText,
            fontSize: 7.0,
            fontWeight: FontWeight.w900,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 1.0),
        Expanded(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: _buildConsultancyItems(lang, primaryText, textColor),
            ),
          ),
        ),
      ],
    );

    return Container(
      decoration: borderDecor ?? BoxDecoration(
        color: bgGradient == null ? bg : null,
        gradient: bgGradient,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!photoOnRight && showProfilePhoto) profileWidget,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.5, bottom: 3.5, right: 5, left: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left-side inside columns based on layout mirroring
                        if (!photoOnRight) Expanded(flex: 11, child: infoSectionWidget),
                        if (photoOnRight && showConsultancy) Expanded(flex: 8, child: consultancySectionWidget),
                        
                        if (showConsultancy) const SizedBox(width: 6),
                        
                        // Right-side inside columns based on layout mirroring
                        if (!photoOnRight && showConsultancy) Expanded(flex: 8, child: consultancySectionWidget),
                        if (photoOnRight) Expanded(flex: 11, child: infoSectionWidget),
                      ],
                    ),
                  ),
                  const SizedBox(height: 1.5),
                  // Disclaimer Section
                  Text(
                    disclaimer,
                    style: TextStyle(
                      color: disclaimerColor,
                      fontSize: 5.0,
                      fontWeight: FontWeight.w600,
                      height: 1.12,
                    ),
                    textAlign: TextAlign.justify,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          if (photoOnRight && showProfilePhoto) profileWidget,
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
          fit: BoxFit.contain,
          placeholder: (context, url) => Image.asset(
            ImageConstants.logo,
            fit: BoxFit.contain,
          ),
          errorWidget: (context, url, error) => Image.asset(
            ImageConstants.logo,
            fit: BoxFit.contain,
          ),
        );
      } else {
        return Image.file(
          File(logoPath),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            ImageConstants.logo,
            fit: BoxFit.contain,
          ),
        );
      }
    }
    return Image.asset(
      ImageConstants.logo,
      fit: BoxFit.contain,
    );
  }

  List<Widget> _buildConsultancyItems(String lang, Color bulletColor, Color textColor) {
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
      'bn': [
        "প্রিমিয়াম পরিশোধ",
        "ম্যাচুরিটি দাবি",
        "পলিসি পুনরুজ্জীবন",
        "পলিসি ঋণ",
        "ঠিকানা পরিবর্তন",
        "মনোনয়নে পরিবর্তন",
      ],
      'te': [
        "ప్రీమియం చెల్లింపు",
        "మెచ్యూరిటీ క్లెయిమ్",
        "పాలసీ పునరుద్ధరణ",
        "పాలసీ రుణం",
        "చిరునామా మార్పు",
        "నామినేషన్ మార్పు",
      ],
      'ta': [
        "பிரீமியம் செலுத்துதல்",
        "முதிர்வு கோரிக்கை",
        "பாலிசி புதுப்பித்தல்",
        "பாலிசி கடன்",
        "முகவரி மாற்றம்",
        "நியமன மாற்றம்",
      ],
      'kn': [
        "ಪ್ರೀಮಿಯಂ ಪಾವತಿ",
        "ಮೆಚ್ಯುರಿಟಿ ಕ್ಲೈಮ್",
        "ಪಾಲಿಸಿ ಪುನರುಜ್ಜೀವನ",
        "ಪಾಲಿಸಿ ಸಾಲ",
        "ವಿಳಾಸ ಬದಲಾವಣೆ",
        "ನಾಮನಿರ್ದೇಶನ ಬದಲಾವಣೆ",
      ],
      'pa': [
        "ਪ੍ਰੀਮੀਅਮ ਭੁਗਤਾਨ",
        "ਮੈਚੋਰਿਟੀ ਕਲੇਮ",
        "ਪਾਲਿਸੀ ਮੁੜ ਚਾਲੂ ਕਰਨਾ",
        "ਪਾਲਿਸੀ ਲੋਨ",
        "ਪਤੇ ਵਿੱਚ ਤਬਦੀਲੀ",
        "ਨਾਮਜ਼ਦਗੀ ਵਿੱਚ ਤਬਦੀਲੀ",
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
            size: 3.6,
            color: bulletColor,
          ),
          const SizedBox(width: 2.0),
          Expanded(
            child: Text(
              item,
              style: TextStyle(
                color: textColor.withOpacity(0.85),
                fontSize: 5.6,
                fontWeight: FontWeight.w700,
                height: 1.15,
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
