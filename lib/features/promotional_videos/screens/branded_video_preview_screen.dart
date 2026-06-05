import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage/shared_prefs.dart';

class BrandedVideoPreviewScreen extends StatefulWidget {
  final String videoPath;
  const BrandedVideoPreviewScreen({Key? key, required this.videoPath}) : super(key: key);

  @override
  State<BrandedVideoPreviewScreen> createState() => _BrandedVideoPreviewScreenState();
}

class _BrandedVideoPreviewScreenState extends State<BrandedVideoPreviewScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;
  bool _shareWithText = true;
  final TextEditingController _shareTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Set up default share text based on selected language
    final lang = SharedPrefs.getString(AppConstants.language) ?? 'en';
    final defaultTextMap = {
      'en': 'Hello! I am sharing a customized plan with you. Please check out the details in the attached video. Let me know if you would like to discuss it further or schedule a consultation.',
      'hi': 'नमस्ते! मैं आपके साथ एक कस्टमाइज्ड वित्तीय योजना साझा कर रहा हूँ। कृपया संलग्न वीडियो में विवरण देखें। यदि आप इस पर आगे चर्चा करना चाहते हैं या परामर्श का समय निर्धारित करना चाहते हैं तो मुझे बताएं।',
      'mr': 'नमस्कार! मी तुमच्यासोबत एक कस्टमाइज्ड आर्थिक योजना शेअर करत आहे. कृपया जोडलेल्या व्हिडिओमध्ये तपशील पहा. जर तुम्हाला यावर पुढे चर्चा करायची असेल किंवा सल्लामसलत करायची असेल तर मला कळवा।',
      'gu': 'નમસ્તે! હું તમારી સાથે એક કસ્ટમાઇઝ્ડ નાણાકીય યોજના શેર કરી રહ્યો છું. કૃપા કરીને સાથે આપેલા વીડિયોમાં વિગતો તપાસો. જો તમે આ અંગે વધુ ચર્ચા કરવા માંગતા હો અથવા પરામર્શ નક્કી કરવા માંગતા હો તો મને જણાવો.',
    };
    _shareTextController.text = defaultTextMap[lang] ?? defaultTextMap['en']!;

    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath));
    _videoPlayerController.initialize().then((_) {
      if (mounted) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController,
            autoPlay: true,
            looping: true,
            aspectRatio: _videoPlayerController.value.aspectRatio,
            materialProgressColors: ChewieProgressColors(
              playedColor: AppColors.primaryColor,
              handleColor: AppColors.primaryColor,
              backgroundColor: Colors.white24,
              bufferedColor: Colors.white38,
            ),
          );
        });
      }
    }).catchError((error) {
      debugPrint("Error initializing video preview player: $error");
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _shareTextController.dispose();
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _shareVideo() async {
    final XFile xFile = XFile(widget.videoPath);
    await Share.shareXFiles([xFile], text: _shareWithText ? _shareTextController.text : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Video Preview",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: _hasError
                    ? const Text(
                        "Could not load preview. The video has been saved to your gallery.",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center,
                      )
                    : _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: _videoPlayerController.value.aspectRatio,
                            child: Chewie(controller: _chewieController!),
                          )
                        : const CircularProgressIndicator(
                            color: AppColors.primaryColor,
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
                  onTap: _shareVideo,
                ),
                _buildSocialIcon(
                  icon: Icons.facebook, 
                  label: "Facebook", 
                  color: const Color(0xFF1877F2),
                  onTap: _shareVideo,
                ),
                _buildSocialIcon(
                  icon: Icons.camera_alt, 
                  label: "Instagram", 
                  color: const Color(0xFFE1306C),
                  onTap: _shareVideo,
                ),
                _buildSocialIcon(
                  icon: Icons.share, 
                  label: "Share", 
                  color: Colors.white24,
                  onTap: _shareVideo,
                ),
              ],
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
            Container(
              padding: const EdgeInsets.all(12), 
              decoration: BoxDecoration(color: color, shape: BoxShape.circle), 
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
