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
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/image_constants.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/domain/models/complete_setup_response.dart';
import '../../video_ads/controllers/video_ads_controller.dart';
import '../../dashboard/widgets/branding_banner.dart';
import '../controllers/promotional_videos_controller.dart';
import 'branded_video_preview_screen.dart';
import 'dart:convert';

class VideoViewerScreen extends StatefulWidget {
  const VideoViewerScreen({Key? key}) : super(key: key);

  @override
  State<VideoViewerScreen> createState() => _VideoViewerScreenState();
}

class _VideoViewerScreenState extends State<VideoViewerScreen> {
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isProcessing = false;
  int _selectedStyleIndex = 0;
  late final PageController _pageController;
  final PromotionalVideo video = Get.arguments;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedStyleIndex);
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
    _pageController.dispose();
    super.dispose();
  }

  void _showStyleSelectorBottomSheet(
    BuildContext context,
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
                      "Choose Video Style",
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
                          childAspectRatio: 0.85,
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
                                        const Positioned.fill(
                                          child: Center(
                                            child: Icon(
                                              Icons.play_circle_fill_rounded,
                                              color: Colors.white30,
                                              size: 45,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.7),
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
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity == null) return;
                      if (details.primaryVelocity! < 0) {
                        // Swipe left
                        final nextIndex = (_selectedStyleIndex + 1) % 100;
                        _pageController.jumpToPage(nextIndex);
                        setState(() {
                          _selectedStyleIndex = nextIndex;
                        });
                      } else if (details.primaryVelocity! > 0) {
                        // Swipe right
                        final prevIndex = (_selectedStyleIndex - 1 + 100) % 100;
                        _pageController.jumpToPage(prevIndex);
                        setState(() {
                          _selectedStyleIndex = prevIndex;
                        });
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.black,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Video Player
                          playerWidget,
                          
                          // FLAT SQUARE Branding Frame
                          Container(
                            height: 80,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: RepaintBoundary(
                              key: _boundaryKey,
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: 100,
                                onPageChanged: (index) {
                                  setState(() {
                                    _selectedStyleIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  return BrandingBanner(
                                    fallbackName: userName,
                                    fallbackPhone: userPhone,
                                    fallbackEmail: userEmail,
                                    styleIndex: index,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Swipe indicator row
          GestureDetector(
            onTap: () => _showStyleSelectorBottomSheet(context, userName, userPhone, userEmail),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.swipe_left_alt, color: AppColors.primaryColor, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    "Swipe video to change style (${_selectedStyleIndex + 1}/100)",
                    style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.swipe_right_alt, color: AppColors.primaryColor, size: 14),
                ],
              ),
            ),
          ),

          // Controls
          Container(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 25), 
            color: Colors.black,
            child: Column(
              children: [
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

  Future<void> _processAndDownloadVideo() async {
    if (_isProcessing) return;
    
    final double bannerWidth = MediaQuery.of(context).size.width;
    final double bannerHeight = 80;
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
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2230),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 70,
                      width: 70,
                      child: CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                        strokeWidth: 4.5,
                        backgroundColor: AppColors.primaryColor.withOpacity(0.15),
                      ),
                    ),
                    const Icon(
                      Icons.video_settings_rounded,
                      color: AppColors.primaryColor,
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  "Processing Video...",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<String>(
                  valueListenable: statusText,
                  builder: (context, val, child) {
                    return Text(
                      val,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ],
            ),
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
        } catch (e) {
          debugPrint("Gal save error: $e");
        }
        if (mounted) Navigator.of(context).pop(); // Close dialog safely
        Get.to(() => BrandedVideoPreviewScreen(videoPath: outputPath));
        Get.snackbar(
          "Success!", 
          "Branded video saved to gallery successfully. Opening preview...",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successColor,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          margin: const EdgeInsets.all(15),
        );
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
