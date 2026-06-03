import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
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
  final GlobalKey _boundaryKey = GlobalKey();
  int _currentDesignIndex = 0;
  bool _isProcessing = false;
  final PromotionalVideo video = Get.arguments;

  @override
  void initState() {
    super.initState();
    if (video.videoUrl != null && video.videoUrl!.isNotEmpty) {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(video.videoUrl!));
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
    } else if (video.youtubeId != null && video.youtubeId!.isNotEmpty) {
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
                          return RepaintBoundary(
                            key: index == _currentDesignIndex ? _boundaryKey : null,
                            child: _generateUniqueDesign(index, userName, userPhone, userEmail),
                          );
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
                      _processAndDownloadVideo();
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
    if (index == 0) return 125;
    if (index >= 75) return 60;
    if (index >= 50) return 80;
    return 105;
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

  Future<void> _processAndDownloadVideo() async {
    if (_isProcessing) return;
    
    final double bannerWidth = MediaQuery.of(context).size.width;
    final double bannerHeight = _getFooterHeight(_currentDesignIndex);
    final double ratio = bannerHeight / bannerWidth;

    final bool isLocal = video.localPath != null && video.localPath!.isNotEmpty;
    final bool isYoutube = video.youtubeId != null && video.youtubeId!.isNotEmpty;
    final bool isNetwork = video.videoUrl != null && video.videoUrl!.isNotEmpty;

    if (!isLocal && !isYoutube && !isNetwork) {
      Get.snackbar(
        "Error", 
        "No valid video source found.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // 1. Request Photo/Gallery Permission first
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          setState(() => _isProcessing = false);
          Get.snackbar(
            "Permission Denied",
            "Storage/Photo access is required to save the video to gallery.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.errorColor,
            colorText: Colors.white,
            margin: const EdgeInsets.all(15),
          );
          return;
        }
      }
    } catch (e) {
      debugPrint("Error checking/requesting gallery permission: $e");
    }

    final ValueNotifier<String> statusText = ValueNotifier<String>("Initializing...");

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
              const Text("Processing Video...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              ValueListenableBuilder<String>(
                valueListenable: statusText,
                builder: (context, val, child) {
                  return Text(
                    val,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      String? localVideoPath = video.localPath;
      if (isNetwork) {
        statusText.value = "Downloading video file... This may take a moment.";
        localVideoPath = await _downloadNetworkVideo(video.videoUrl!);
        if (localVideoPath == null) {
          if (mounted) Navigator.of(context).pop();
          Get.snackbar("Download Failed", "Could not download the video file.", backgroundColor: AppColors.errorColor, colorText: Colors.white);
          return;
        }
      } else if (isYoutube) {
        statusText.value = "Downloading video from YouTube... This may take a moment.";
        localVideoPath = await _downloadYoutubeVideo(video.youtubeId!);
        if (localVideoPath == null) {
          if (mounted) Navigator.of(context).pop();
          Get.snackbar("Download Failed", "Could not download the YouTube video stream.", backgroundColor: AppColors.errorColor, colorText: Colors.white);
          return;
        }
      }

      statusText.value = "Capturing branding banner template...";
      final bannerImagePath = await _captureBanner();
      if (bannerImagePath == null) {
        if (mounted) Navigator.of(context).pop();
        Get.snackbar("Processing Failed", "Could not capture the design style template.", backgroundColor: AppColors.errorColor, colorText: Colors.white);
        return;
      }

      statusText.value = "Applying branding banner to video (using FFmpeg)...";
      final appDocDir = await getApplicationDocumentsDirectory();
      final outputPath = "${appDocDir.path}/branded_video_${DateTime.now().millisecondsSinceEpoch}.mp4";

      final ffmpegCommand = '-y -i "$localVideoPath" -i "$bannerImagePath" -filter_complex "[1:v][0:v]scale2ref=w=iw:h=2*trunc(iw*$ratio/2)[scaled_overlay][main_video];[main_video]pad=iw:ih+2*trunc(iw*$ratio/2):0:0:color=white[padded_video];[padded_video][scaled_overlay]overlay=0:H-h" -c:a copy "$outputPath"';

      final session = await FFmpegKit.execute(ffmpegCommand);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        statusText.value = "Saving video to native Gallery...";
        try {
          await Gal.putVideo(outputPath);
          if (mounted) Navigator.of(context).pop(); // Close dialog safely
          Get.snackbar(
            "Success!", 
            "Branded video saved to gallery successfully.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.successColor,
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            margin: const EdgeInsets.all(15),
          );
        } catch (e) {
          if (mounted) Navigator.of(context).pop(); // Close dialog safely
          debugPrint("Gal save error, falling back to share: $e");
          await Share.shareXFiles([XFile(outputPath)], text: "Save or share your branded video!");
        }
      } else {
        if (mounted) Navigator.of(context).pop(); // Close dialog safely
        final logs = await session.getLogs();
        debugPrint("FFmpeg failed with code $returnCode. Logs: $logs");
        Get.snackbar(
          "Error", 
          "Failed to merge branding frame into the video.", 
          backgroundColor: AppColors.errorColor, 
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // Close dialog safely
      debugPrint("Error during FFmpeg processing: $e");
      Get.snackbar("Error", "An unexpected error occurred: $e", backgroundColor: AppColors.errorColor, colorText: Colors.white);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<String?> _downloadNetworkVideo(String url) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/temp_download_${DateTime.now().millisecondsSinceEpoch}.mp4');
      
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 15);
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final fileSink = file.openWrite();
        await response.pipe(fileSink);
        await fileSink.close();
        return file.path;
      }
      return null;
    } catch (e) {
      debugPrint("Error downloading network video: $e");
      return null;
    }
  }

  Future<String?> _downloadYoutubeVideo(String videoId) async {
    final yt = YoutubeExplode();
    try {
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      if (manifest.muxed.isEmpty) return null;
      final streamInfo = manifest.muxed.withHighestBitrate();

      final stream = yt.videos.streamsClient.get(streamInfo);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/yt_download_$videoId.mp4');
      
      if (await file.exists()) {
        await file.delete();
      }

      final fileStream = file.openWrite();
      await stream.pipe(fileStream);
      await fileStream.flush();
      await fileStream.close();
      
      return file.path;
    } catch (e) {
      debugPrint("YouTube download error: $e");
      return null;
    } finally {
      yt.close();
    }
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

  Widget _buildFirstBanner(AuthController controller, String name, String phone, String email) {
    return Container(
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Profile Image (Left-most, spans full height of the banner)
          Container(
            width: 100,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(right: BorderSide(color: Colors.grey[200]!, width: 1.5)),
            ),
            clipBehavior: Clip.antiAlias,
            child: controller.imagePath.value.isNotEmpty
                ? Image.file(
                    File(controller.imagePath.value),
                    fit: BoxFit.cover,
                  )
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
          const SizedBox(width: 8),

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
                                name.toUpperCase(),
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
                                controller.destinationController.text.toUpperCase().isNotEmpty
                                    ? controller.destinationController.text.toUpperCase()
                                    : "SOFTWARE COMPANY",
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
                                                phone,
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
                                                email,
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
                                    child: controller.logoPath.value.isNotEmpty
                                        ? Image.file(
                                            File(controller.logoPath.value),
                                            fit: BoxFit.cover,
                                          )
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
                        const SizedBox(width: 8),

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

  Future<String?> _captureBanner() async {
    try {
      RenderRepaintBoundary? boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        if (kDebugMode) print("Error: RenderRepaintBoundary boundary is null");
        return null;
      }
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;
      Uint8List pngBytes = byteData.buffer.asUint8List();
      
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/video_banner_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);
      return file.path;
    } catch (e) {
      if (kDebugMode) print("Error capturing banner: $e");
      return null;
    }
  }
}
