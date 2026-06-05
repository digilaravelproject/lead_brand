import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/image_constants.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/domain/models/complete_setup_response.dart';
import '../../dashboard/widgets/branding_banner.dart';
import 'dart:convert';

class ImageViewerScreen extends StatefulWidget {
  const ImageViewerScreen({Key? key}) : super(key: key);

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isSharing = false;
  bool _shareWithText = true;
  final TextEditingController _shareTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final lang = SharedPrefs.getString(AppConstants.language) ?? 'en';
    final defaultTextMap = {
      'en': 'Hello! I am sharing a customized plan with you. Please check out the details in the attached poster. Let me know if you would like to discuss it further or schedule a consultation.',
      'hi': 'नमस्ते! मैं आपके साथ एक कस्टमाइज्ड वित्तीय योजना साझा कर रहा हूँ। कृपया संलग्न पोस्टर में विवरण देखें। यदि आप इस पर आगे चर्चा करना चाहते हैं या परामर्श का समय निर्धारित करना चाहते हैं तो मुझे बताएं।',
      'mr': 'नमस्कार! मी तुमच्यासोबत एक कस्टमाइज्ड आर्थिक योजना शेअर करत आहे. कृपया जोडलेल्या पोस्टरमध्ये तपशील पहा. जर तुम्हाला यावर पुढे चर्चा करायची असेल किंवा सल्लामसलत करायची असेल तर मला कळवा।',
      'gu': 'નમસ્તે! હું તમારી સાથે એક કસ્ટમાઇઝ્ડ નાણાકીય યોજના શેર કરી રહ્યો છું. કૃપા કરીને સાથે આપેલા પોસ્ટરમાં વિગતો તપાસો. જો તમે આ અંગે વધુ ચર્ચા કરવા માંગતા હો અથવા પરામર્શ નક્કી કરવા માંગતા હો તો મને જણાવો.',
    };
    _shareTextController.text = defaultTextMap[lang] ?? defaultTextMap['en']!;
  }

  @override
  void dispose() {
    _shareTextController.dispose();
    super.dispose();
  }

  Future<void> _sharePoster(String label) async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      // 1. Capture the widget as an image
      RenderRepaintBoundary? boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) {
        Get.snackbar("Error", "Could not capture image", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) return;
      Uint8List pngBytes = byteData.buffer.asUint8List();

      // 2. Save to temporary directory
      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/bliss_poster_${DateTime.now().millisecondsSinceEpoch}.png').create();
      await imagePath.writeAsBytes(pngBytes);

      // 3. Share the file
      final XFile xFile = XFile(imagePath.path);
      await Share.shareXFiles([xFile], text: _shareWithText ? _shareTextController.text : null);
      
    } catch (e) {
      if (kDebugMode) print("Sharing error: $e");
      Get.snackbar("Sharing Failed", "An error occurred while sharing the poster.", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = Get.arguments ?? '';
    final userJson = SharedPrefs.getString(AppConstants.userData);
    UserSetupModel? user;
    if (userJson != null && userJson.isNotEmpty) {
      try {
        user = UserSetupModel.fromJson(jsonDecode(userJson));
      } catch (_) {}
    }

    final String userName = user?.name.isNotEmpty == true 
        ? user!.name 
        : "Firoz Mohammad";
    final String userPhone = user?.phoneNumber?.isNotEmpty == true
        ? user!.phoneNumber!
        : "+91 9876543210";
    final String userEmail = user?.email.isNotEmpty == true
        ? user!.email
        : "test@blessapp.com";

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      appBar: AppBar(
        title: const Text('Share Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    child: RepaintBoundary(
                      key: _boundaryKey,
                      child: _buildMainPoster(imageUrl, userName, userPhone, userEmail),
                    ),
                  ),
                ),
              ),

              // Checkbox and editable text field
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.black,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Theme(
                          data: Theme.of(context).copyWith(
                            unselectedWidgetColor: Colors.white60,
                          ),
                          child: Checkbox(
                            value: _shareWithText,
                            activeColor: AppColors.primaryColor,
                            onChanged: (val) {
                              setState(() {
                                _shareWithText = val ?? false;
                              });
                            },
                          ),
                        ),
                        const Text(
                          "Share with custom text",
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    if (_shareWithText)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
                        child: TextField(
                          controller: _shareTextController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: "Enter text to share...",
                            hintStyle: const TextStyle(color: Colors.white30),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white24),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: AppColors.primaryColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Social Sharing UI
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
                color: Colors.black,
                child: Row(
                  children: [
                    _buildSocialIcon(
                      icon: Icons.chat_bubble, 
                      label: "WhatsApp", 
                      color: const Color(0xFF25D366),
                      onTap: () => _sharePoster("WhatsApp"),
                    ),
                    _buildSocialIcon(
                      icon: Icons.facebook, 
                      label: "Facebook", 
                      color: const Color(0xFF1877F2),
                      onTap: () => _sharePoster("Facebook"),
                    ),
                    _buildSocialIcon(
                      icon: Icons.camera_alt, 
                      label: "Instagram", 
                      color: const Color(0xFFE1306C),
                      onTap: () => _sharePoster("Instagram"),
                    ),
                    _buildSocialIcon(
                      icon: Icons.share, 
                      label: "Share", 
                      color: Colors.white24,
                      onTap: () => _sharePoster("Others"),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (_isSharing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryColor),
                    SizedBox(height: 20),
                    Text("Preparing your poster...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainPoster(String imageUrl, String name, String phone, String email) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
            ),
          ),
          Container(
            height: 80, 
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.08))),
            ),
            child: BrandingBanner(
              fallbackName: name,
              fallbackPhone: phone,
              fallbackEmail: email,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon({required IconData icon, required String label, required Color color, VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: Icon(icon, color: Colors.white, size: 22)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
