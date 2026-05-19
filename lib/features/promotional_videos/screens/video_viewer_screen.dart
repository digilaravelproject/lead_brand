import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../video_ads/controllers/video_ads_controller.dart';
import '../controllers/promotional_videos_controller.dart';

class VideoViewerScreen extends StatefulWidget {
  const VideoViewerScreen({Key? key}) : super(key: key);

  @override
  State<VideoViewerScreen> createState() => _VideoViewerScreenState();
}

class _VideoViewerScreenState extends State<VideoViewerScreen> {
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  
  final PageController _stylePageController = PageController();
  int _currentDesignIndex = 0;
  final PromotionalVideo video = Get.arguments;

  @override
  void initState() {
    super.initState();
    if (video.youtubeId != null && video.youtubeId!.isNotEmpty) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: video.youtubeId!,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          loop: true,
        ),
      );
    } else if (video.localPath != null && video.localPath!.isNotEmpty) {
      _videoPlayerController = VideoPlayerController.file(File(video.localPath!));
      _videoPlayerController!.initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            autoPlay: true,
            looping: true,
            aspectRatio: _videoPlayerController!.value.aspectRatio,
            materialProgressColors: ChewieProgressColors(
              playedColor: AppColors.primaryColor,
              handleColor: AppColors.primaryColor,
              backgroundColor: Colors.white24,
              bufferedColor: Colors.white38,
            ),
          );
        });
      });
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _stylePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final String userName = authController.nameController.text.isNotEmpty 
        ? authController.nameController.text 
        : "Firoz Mohammad";
    final String userPhone = authController.phoneController.text.isNotEmpty
        ? authController.phoneController.text
        : "+91 9876543210";
    final String userEmail = authController.emailController.text.isNotEmpty
        ? authController.emailController.text
        : "test@blessapp.com";

    if (_youtubeController != null) {
      return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppColors.primaryColor,
          progressColors: const ProgressBarColors(
            playedColor: AppColors.primaryColor,
            handleColor: AppColors.primaryColor,
          ),
        ),
        builder: (context, player) {
          return _buildMainScaffold(context, userName, userPhone, userEmail, player);
        },
      );
    } else {
      Widget playerWidget;
      if (_chewieController != null) {
        playerWidget = AspectRatio(
          aspectRatio: _videoPlayerController!.value.aspectRatio,
          child: Chewie(controller: _chewieController!),
        );
      } else {
        playerWidget = const SizedBox(
          height: 250,
          child: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
        );
      }
      return _buildMainScaffold(context, userName, userPhone, userEmail, playerWidget);
    }
  }

  Widget _buildMainScaffold(BuildContext context, String userName, String userPhone, String userEmail, Widget playerWidget) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(video.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.black,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Video Player
                        playerWidget,
                        
                        // FLAT SQUARE Branding Frame
                        AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      height: _getFooterHeight(_currentDesignIndex),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        // No border radius here makes it integrate perfectly with the video bottom
                      ),
                      child: PageView.builder(
                        controller: _stylePageController,
                        itemCount: 100,
                        onPageChanged: (index) {
                          setState(() => _currentDesignIndex = index);
                        },
                        itemBuilder: (context, index) {
                          return _generateUniqueDesign(index, userName, userPhone, userEmail);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
          
          // Style Indicator & Controls
          Container(
            padding: const EdgeInsets.fromLTRB(15, 5, 15, 25), 
            color: Colors.black,
            child: Column(
              children: [
                const Text(
                  "Swipe frame to change style  •  Tap below for catalog",
                  style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _showStyleSelector(userName, userPhone, userEmail),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(color: AppColors.primaryColor, width: 1.2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome_motion_rounded, color: AppColors.primaryColor, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          "Style ${_currentDesignIndex + 1} of 100",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionIcon(Icons.folder_open_rounded, "Open", () {
                      Get.snackbar("Gallery", "Opening your video gallery...", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white, colorText: Colors.black);
                    }),
                    _buildActionIcon(Icons.download_rounded, "Download", () {
                      _simulateDownload();
                    }),
                    _buildActionIcon(Icons.video_library_rounded, "My Videos", () {
                      Get.toNamed('/promotional-videos');
                    }),
                    _buildActionIcon(Icons.check_circle_outline_rounded, "Create", () {
                      final adsController = Get.find<VideoAdsController>();
                      adsController.pickVideo();
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStyleSelector(String name, String phone, String email) {
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Frame Catalog", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close, color: Colors.white54)),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.82,
                ),
                itemCount: 100,
                itemBuilder: (context, index) {
                  double footerH = _getFooterHeight(index);
                  return GestureDetector(
                    onTap: () {
                      _stylePageController.jumpToPage(index);
                      Get.back();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                                SizedBox(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: video.thumbnailUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: video.thumbnailUrl,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: Colors.grey[900],
                                          child: const Icon(Icons.video_library, color: Colors.white24, size: 30),
                                        ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: footerH * 0.7, 
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
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            color: _currentDesignIndex == index ? AppColors.primaryColor : Colors.white10,
                            child: Text("Style ${index + 1}", textAlign: TextAlign.center, style: TextStyle(color: _currentDesignIndex == index ? Colors.white : Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
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
    if (index >= 75) return 60;
    if (index >= 50) return 80;
    return 105;
  }

  Widget _generateUniqueDesign(int index, String name, String phone, String email) {
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

  void _simulateDownload() {
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primaryColor),
              const SizedBox(height: 20),
              const Text("Merging Branding Frame...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              const Text("Applying Style ${7} to your video", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    Future.delayed(const Duration(seconds: 3), () {
      Get.back(); // Close dialog
      Get.snackbar(
        "Success!", 
        "Branded video saved to gallery successfully.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        margin: const EdgeInsets.all(15),
      );
    });
  }

  Widget _buildActionIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white30, width: 1.5),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
