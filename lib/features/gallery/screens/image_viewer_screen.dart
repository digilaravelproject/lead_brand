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
import '../../../core/services/storage/shared_prefs.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/domain/models/complete_setup_response.dart';
import 'dart:convert';

class ImageViewerScreen extends StatefulWidget {
  const ImageViewerScreen({Key? key}) : super(key: key);

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  final PageController _designPageController = PageController();
  final GlobalKey _boundaryKey = GlobalKey();
  int _currentDesignIndex = 0;
  bool _isSharing = false;

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
      await Share.shareXFiles([xFile], text: 'Check out this plan from Bliss App!');
      
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
                  child: PageView.builder(
                    controller: _designPageController,
                    itemCount: 100,
                    onPageChanged: (index) {
                      setState(() {
                        _currentDesignIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        child: RepaintBoundary(
                          key: index == _currentDesignIndex ? _boundaryKey : null,
                          child: _buildMainPoster(index, imageUrl, userName, userPhone, userEmail),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Design Switcher Indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _showStyleSelector(imageUrl, userName, userPhone, userEmail),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(35),
                          border: Border.all(color: AppColors.primaryColor.withOpacity(0.3), width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome_motion_rounded, color: AppColors.primaryColor, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              "Design Style ${_currentDesignIndex + 1} of 100",
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Tap to view all 100 styles  •  Swipe to change",
                      style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

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

  void _showStyleSelector(String imageUrl, String name, String phone, String email) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1D24),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Container(width: 45, height: 5, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Styles Catalog (100 Options)", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close, color: Colors.white54)),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.75,
                ),
                itemCount: 100,
                itemBuilder: (context, index) {
                  double footerH = _getFooterHeight(index);
                  return GestureDetector(
                    onTap: () {
                      _designPageController.jumpToPage(index);
                      Get.back();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _currentDesignIndex == index ? AppColors.primaryColor : Colors.white10,
                          width: _currentDesignIndex == index ? 3 : 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                SizedBox(width: double.infinity, height: double.infinity, child: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover)),
                                Positioned(
                                  bottom: 0, left: 0, right: 0,
                                  child: Container(
                                    height: footerH * 0.4,
                                    color: Colors.white,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: SizedBox(
                                        width: Get.width,
                                        height: footerH,
                                        child: _generateUniqueDesign(index, name, phone, email),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            color: _currentDesignIndex == index ? AppColors.primaryColor : Colors.white10,
                            child: Text("Style ${index + 1}", textAlign: TextAlign.center, style: TextStyle(color: _currentDesignIndex == index ? Colors.white : Colors.white60, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  double _getFooterHeight(int index) {
    if (index == 0) return 125;
    if (index >= 75) return 60;
    if (index >= 50) return 80;
    return 105;
  }

  Widget _buildMainPoster(int index, String imageUrl, String name, String phone, String email) {
    double footerHeight = _getFooterHeight(index);

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
            height: footerHeight, 
            width: double.infinity,
            decoration: BoxDecoration(
              color: index % 2 == 0 ? Colors.white : const Color(0xFFF9FAFB),
              border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.08))),
            ),
            child: _generateUniqueDesign(index, name, phone, email),
          ),
        ],
      ),
    );
  }

  Widget _generateUniqueDesign(int index, String name, String phone, String email) {
    if (index == 0) {
      final authController = Get.find<AuthController>();
      return _buildFirstBanner(authController, name, phone, email);
    }

    final List<Color> accentColors = [
      const Color(0xFFE68A00), const Color(0xFF1A73E8), const Color(0xFF2DA94F), const Color(0xFFEA4335),
      const Color(0xFF673AB7), const Color(0xFF00ACC1), const Color(0xFFD81B60), const Color(0xFFF4511E),
      const Color(0xFF3949AB), const Color(0xFF43A047),
    ];

    Color accent = accentColors[index % accentColors.length];
    bool isDarkButton = index % 6 == 0;
    double footerH = _getFooterHeight(index);

    bool showLogo = index < 85; 
    bool showName = footerH > 85;
    bool showEmail = footerH > 60;
    bool isSplit = footerH < 100;

    if (!showName && !showEmail) showName = true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Center(
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showLogo) _buildLogoBox(index, accent, footerH),
              if (showLogo) const SizedBox(width: 15),
              if (showLogo) Container(width: 1.2, color: Colors.grey[200], margin: const EdgeInsets.symmetric(vertical: 8)),
              if (showLogo) const SizedBox(width: 15),
              
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: showLogo ? CrossAxisAlignment.start : CrossAxisAlignment.center, 
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showName) Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: index % 7 == 0 ? accent : Colors.black, height: 1.0),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  if (showName) const SizedBox(height: 3),
                  
                  if (showEmail) Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isSplit) Icon(Icons.email_outlined, color: Colors.grey[400], size: 10),
                      if (!isSplit) const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          email,
                          style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.w600),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (showEmail) const SizedBox(height: 4),
                  
                  _buildPhoneButton(phone, accent, isDarkButton, index, footerH),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoBox(int index, Color accent, double height) {
    bool isCircle = index % 5 == 0;
    double size = height > 80 ? 65 : 50;
    return Container(
      width: size,
      height: size + 5,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(height > 80 ? 12 : 8),
        border: Border.all(color: index % 2 == 0 ? accent.withOpacity(0.4) : Colors.grey[200]!, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            index % 3 == 0 ? Icons.business_rounded : Icons.verified_user_rounded,
            color: index % 4 == 0 ? accent : Colors.green[700], size: height > 80 ? 24 : 18,
          ),
          Text("BLISS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: height > 80 ? 10 : 8, color: Colors.black, height: 1.1)),
        ],
      ),
    );
  }

  Widget _buildPhoneButton(String phone, Color accent, bool dark, int index, double height) {
    bool isOutline = index % 8 == 0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: height > 80 ? 7 : 4),
      decoration: BoxDecoration(
        color: isOutline ? Colors.transparent : (dark ? Colors.black87 : accent),
        borderRadius: BorderRadius.circular(30),
        border: isOutline ? Border.all(color: accent, width: 1.5) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.phone_in_talk_rounded, color: isOutline ? accent : Colors.white, size: height > 80 ? 13 : 11),
          const SizedBox(width: 8),
          Text(phone, style: TextStyle(color: isOutline ? accent : Colors.white, fontWeight: FontWeight.w900, fontSize: height > 80 ? 13 : 11)),
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

  Widget _buildFirstBanner(AuthController controller, String name, String phone, String email) {
    final userJson = SharedPrefs.getString(AppConstants.userData);
    UserSetupModel? user;
    if (userJson != null && userJson.isNotEmpty) {
      try {
        user = UserSetupModel.fromJson(jsonDecode(userJson));
      } catch (_) {}
    }

    final String displayName = user?.name.isNotEmpty == true ? user!.name : name;
    final String displayPhone = user?.phoneNumber?.isNotEmpty == true ? user!.phoneNumber! : phone;
    final String displayEmail = user?.email.isNotEmpty == true ? user!.email : email;
    final String displayDesignation = user?.destination?.isNotEmpty == true ? user!.destination! : "SOFTWARE COMPANY";
    final String? profilePhoto = user?.profilePhoto;
    final String? logo = user?.logo;

    return Container(
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Profile Image (Left-most, spans full height of the banner)
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border(right: BorderSide(color: Colors.grey[200]!, width: 1.5)),
              ),
              clipBehavior: Clip.antiAlias,
              child: (profilePhoto != null && profilePhoto.isNotEmpty)
                  ? (profilePhoto.startsWith('/') || profilePhoto.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: profilePhoto.startsWith('/')
                              ? '${AppConstants.baseUrl}$profilePhoto'
                              : profilePhoto,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: Icon(
                              Icons.person,
                              color: Colors.grey[600],
                              size: 38,
                            ),
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Icon(
                              Icons.person,
                              color: Colors.grey[600],
                              size: 38,
                            ),
                          ),
                        )
                      : Image.file(
                          File(profilePhoto),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.person,
                              color: Colors.grey[600],
                              size: 38,
                            ),
                          ),
                        ))
                  : CachedNetworkImage(
                      imageUrl: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&q=80",
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.grey[600],
                          size: 38,
                        ),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.grey[600],
                          size: 38,
                        ),
                      ),
                    ),
            ),
          ),
         // const SizedBox(width: 8),

          // 2. Right-side content (Info Section, Consultancy Section, and Disclaimer)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 6, right: 8),
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
                              const Text(
                                "Doctors Save Lives, We Save Lifestyle",
                                style: TextStyle(
                                  color: Color(0xFF2E7D32), // Premium Green
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              // Name
                              Text(
                                displayName.toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF1E3A8A), // Dark Indigo/Blue
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                  height: 1.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              // Designation
                              Text(
                                displayDesignation.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
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
                                              padding: const EdgeInsets.all(1.5),
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF25D366),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.phone,
                                                color: Colors.white,
                                                size: 8,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                displayPhone,
                                                style: const TextStyle(
                                                  color: Color(0xFFD32F2F), // Dark Red
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        // Email
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.email,
                                              color: Colors.black87,
                                              size: 10,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                displayEmail,
                                                style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 8,
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
                                  const SizedBox(width: 8),
                                  // Logo Section (Yellow Circle, next to contact info)
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFFBBF24), // Premium Yellow Background
                                      border: Border.all(color: Colors.white, width: 1.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 3,
                                          offset: const Offset(0, 1.5),
                                        ),
                                      ],
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: (logo != null && logo.isNotEmpty)
                                        ? (logo.startsWith('/') || logo.startsWith('http')
                                            ? CachedNetworkImage(
                                                imageUrl: logo.startsWith('/')
                                                    ? '${AppConstants.baseUrl}$logo'
                                                    : logo,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) => const Center(
                                                  child: Icon(
                                                    Icons.business,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ),
                                                errorWidget: (context, url, error) => const Center(
                                                  child: Icon(
                                                    Icons.business,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ),
                                              )
                                            : Image.file(
                                                File(logo),
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => const Center(
                                                  child: Icon(
                                                    Icons.business,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ),
                                              ))
                                        : const Center(
                                            child: Icon(
                                              Icons.business,
                                              color: Colors.white,
                                              size: 24,
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
                              const Text(
                                "Servicing Consultancy",
                                style: TextStyle(
                                  color: Color(0xFF1E3A8A), // Dark Indigo/Blue
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Expanded(
                                child: SingleChildScrollView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: _buildConsultancyItems(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Disclaimer Section (at the bottom of right-side content)
                  const Text(
                    "DISCLAIMER: The above concept has been developed after research by financial experts. Results are based on current bonus & FAB rates announced by respective company. For Premium budget, nearest sum assured has been taken. This is a special concept designed only for training purpose, Terms & Conditions will be apply. Depending on age, actual premium may increase or decrease. This is not a single policy but combination of policy design for cater people special needs and requirements.",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 5,
                      fontWeight: FontWeight.w500,
                      height: 1.1,
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

  List<Widget> _buildConsultancyItems() {
    final List<String> items = [
      "Premium Payment",
      "Maturity Claim",
      "Policy Revival",
      "Policy Loan",
      "Change in Address",
      "Change in Nomination",
      "Policy Branch Transfer",
      "Change in Premium Mode",
    ];

    return items.map((item) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.diamond,
            size: 6,
            color: Colors.blue[800],
          ),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              item,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 7.5,
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
