import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/training_controller.dart';

class TrainingVideoPlayerScreen extends StatefulWidget {
  final int trainingId;
  final String? youtubeId;
  final String? videoUrl;
  final String title;

  const TrainingVideoPlayerScreen({
    Key? key,
    required this.trainingId,
    this.youtubeId,
    this.videoUrl,
    required this.title,
  }) : super(key: key);

  @override
  State<TrainingVideoPlayerScreen> createState() => _TrainingVideoPlayerScreenState();
}

class _TrainingVideoPlayerScreenState extends State<TrainingVideoPlayerScreen> {
  final TrainingController _trainingController = Get.find<TrainingController>();
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trainingController.fetchTrainingDetails(widget.trainingId);
    });

    if (widget.youtubeId != null && widget.youtubeId!.isNotEmpty) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: widget.youtubeId!,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          loop: false,
          enableCaption: true,
        ),
      );
    } else if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
      _videoPlayerController!.initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            autoPlay: true,
            looping: false,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          return _buildScaffold(player);
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
      return _buildScaffold(playerWidget);
    }
  }

  Widget _buildScaffold(Widget playerWidget) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              playerWidget,
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "TRAINING VIDEO",
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      if (_trainingController.isDetailsLoading.value) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        );
                      }

                      final details = _trainingController.selectedTraining.value;
                      final desc = details?.description ?? "No description available for this training video.";

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (details?.category != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                details!.category!.categoryName.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          Text(
                            desc,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
