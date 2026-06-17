import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../../auth/domain/models/complete_setup_response.dart';
import '../../dashboard/widgets/branding_banner.dart';
import 'dart:convert';
import 'poster_original_preview_screen.dart';
import '../../../core/widgets/custom_web_view.dart';

class ImageViewerScreen extends StatefulWidget {
  const ImageViewerScreen({super.key});

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isSharing = false;
  bool _shareWithText = false;
  bool _shareOnlyPdf = false;
  String _sharingMessage = "Preparing your poster...";
  int _selectedStyleIndex = 0;
  late final PageController _pageController;
  final TextEditingController _shareTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedStyleIndex);
    
    final args = Get.arguments;
    String? apiDescription;
    if (args is Map) {
      apiDescription = args['description']?.toString();
    }

    if (apiDescription != null && apiDescription.trim().isNotEmpty) {
      _shareTextController.text = apiDescription;
      _shareWithText = true;
    } else {
      _shareTextController.text = '';
      _shareWithText = false;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _shareTextController.dispose();
    super.dispose();
  }

  Future<void> _sharePoster(String label, String? pdfUrl) async {
    if (_isSharing) return;

    final sharePdf = _shareOnlyPdf && pdfUrl != null && pdfUrl.isNotEmpty;

    setState(() {
      _sharingMessage = sharePdf ? "Preparing your PDF..." : "Preparing your poster...";
      _isSharing = true;
    });

    try {
      if (sharePdf) {
        // Download the PDF file to a temp file
        final directory = await getTemporaryDirectory();
        final pdfPath = '${directory.path}/bliss_plan_${DateTime.now().millisecondsSinceEpoch}.pdf';
        
        final dio = Dio();
        await dio.download(pdfUrl, pdfPath);
        
        final XFile xFile = XFile(pdfPath);
        await SharePlus.instance.share(
          ShareParams(
            files: [xFile],
          ),
        );
      } else {
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
        await SharePlus.instance.share(
          ShareParams(
            files: [xFile],
            text: _shareWithText ? _shareTextController.text : null,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) print("Sharing error: $e");
      Get.snackbar("Sharing Failed", "An error occurred while sharing.", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isSharing = false);
    }
  }

  void _showStyleSelectorBottomSheet(
    BuildContext context,
    String imageUrl,
    String userName,
    String userPhone,
    String userEmail,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F111A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    // Drag handle
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Choose Poster Style",
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: GridView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: 100,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedStyleIndex == index;
                          return GestureDetector(
                            onTap: () {
                              _pageController.jumpToPage(index);
                              setState(() {
                                _selectedStyleIndex = index;
                              });
                              setModalState(() {});
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF161924),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryColor : Colors.white10,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: CachedNetworkImage(
                                            imageUrl: imageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => const Center(
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.7),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: Colors.white24, width: 0.5),
                                            ),
                                            child: Text(
                                              "Style ${index + 1}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: AppColors.primaryColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                color: Colors.black,
                                                size: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 35,
                                    width: double.infinity,
                                    color: Colors.white,
                                    child: FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: SizedBox(
                                        width: 375,
                                        height: 80,
                                        child: BrandingBanner(
                                          fallbackName: userName,
                                          fallbackPhone: userPhone,
                                          fallbackEmail: userEmail,
                                          styleIndex: index,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final String imageUrl = args is Map ? (args['imageUrl'] ?? '') : (args ?? '');
    final String? pdfUrl = args is Map ? args['pdfUrl'] : null;
    final String? infoImageUrl = args is Map ? args['infoImageUrl'] : null;
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
        actions: [
          if (pdfUrl != null && pdfUrl.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              onPressed: () {
                final String gDocsUrl = "https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(pdfUrl)}";
                Get.to(() => CustomWebView(
                      url: gDocsUrl,
                      title: "Plan PDF",
                    ));
              },
            ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              Get.to(
                () => PosterOriginalPreviewScreen(
                  imageUrl: imageUrl,
                  text: _shareTextController.text,
                  infoImageUrl: infoImageUrl,
                ),
              );
            },
          ),
        ],
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

              // Swipe indicator row
              GestureDetector(
                onTap: () => _showStyleSelectorBottomSheet(context, imageUrl, userName, userPhone, userEmail),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.swipe_left_alt, color: AppColors.primaryColor, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        "Swipe poster to change style (${_selectedStyleIndex + 1}/100)",
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.swipe_right_alt, color: AppColors.primaryColor, size: 14),
                    ],
                  ),
                ),
              ),

              // Checkbox only
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.black,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_shareTextController.text.trim().isNotEmpty)
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
                                  if (_shareWithText) {
                                    _shareOnlyPdf = false;
                                  }
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
                    if (pdfUrl != null && pdfUrl.isNotEmpty) ...[
                      Row(
                        children: [
                          Theme(
                            data: Theme.of(context).copyWith(
                              unselectedWidgetColor: Colors.white60,
                            ),
                            child: Checkbox(
                              value: _shareOnlyPdf,
                              activeColor: AppColors.primaryColor,
                              onChanged: (val) {
                                setState(() {
                                  _shareOnlyPdf = val ?? false;
                                  if (_shareOnlyPdf) {
                                    _shareWithText = false;
                                  }
                                });
                              },
                            ),
                          ),
                          const Text(
                            "Share only PDF",
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
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
                      onTap: () => _sharePoster("WhatsApp", pdfUrl),
                    ),
                    _buildSocialIcon(
                      icon: Icons.facebook, 
                      label: "Facebook", 
                      color: const Color(0xFF1877F2),
                      onTap: () => _sharePoster("Facebook", pdfUrl),
                    ),
                    _buildSocialIcon(
                      icon: Icons.camera_alt, 
                      label: "Instagram", 
                      color: const Color(0xFFE1306C),
                      onTap: () => _sharePoster("Instagram", pdfUrl),
                    ),
                    _buildSocialIcon(
                      icon: Icons.share, 
                      label: "Share", 
                      color: Colors.white24,
                      onTap: () => _sharePoster("Others", pdfUrl),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (_isSharing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primaryColor),
                    const SizedBox(height: 20),
                    Text(_sharingMessage, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainPoster(String imageUrl, String name, String phone, String email) {
    return PageView.builder(
      controller: _pageController,
      itemCount: 100,
      onPageChanged: (index) {
        setState(() {
          _selectedStyleIndex = index;
        });
      },
      itemBuilder: (context, index) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 8)),
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
                  border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.08))),
                ),
                child: BrandingBanner(
                  fallbackName: name,
                  fallbackPhone: phone,
                  fallbackEmail: email,
                  styleIndex: index,
                ),
              ),
            ],
          ),
        );
      },
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
