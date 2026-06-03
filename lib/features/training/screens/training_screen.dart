import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/theme/app_colors.dart';
import 'training_video_player_screen.dart';
import '../controllers/category_controller.dart';
import '../domain/models/category_model.dart';
import '../domain/models/training_model.dart';
import '../controllers/training_controller.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({Key? key}) : super(key: key);

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final CategoryController _categoryController = Get.find<CategoryController>();
  final TrainingController _trainingController = Get.find<TrainingController>();
  String _selectedCategory = "All";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trainingController.fetchVideoTrainings(categoryId: 'all');
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  List<TrainingModel> get _filteredVideos {
    return _trainingController.videos;
  }

  String? _getYoutubeId(String url) {
    if (url.contains("youtube.com") || url.contains("youtu.be")) {
      return YoutubePlayer.convertUrlToId(url);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B11),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 65,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text(
          "TRAINING HUB",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                onChanged: (val) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    if (val.trim().isEmpty) {
                      if (_selectedCategory == 'All') {
                        _trainingController.fetchVideoTrainings(categoryId: 'all');
                      } else {
                        final catObj = _categoryController.categories.firstWhere(
                          (c) => c.categoryName == _selectedCategory,
                          orElse: () => TrainingCategoryModel(id: 0, categoryName: ''),
                        );
                        if (catObj.id != 0) {
                          _trainingController.fetchVideoTrainings(categoryId: catObj.id.toString());
                        }
                      }
                    } else {
                      _trainingController.searchVideoTrainings(val.trim());
                    }
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search training videos...",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF0F121A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primaryColor),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Topics list
            Obx(() {
              final categoriesList = ["All", ..._categoryController.categories.map((c) => c.categoryName)];
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: categoriesList.map((category) {
                    final isSelected = _selectedCategory == category;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                        if (category == 'All') {
                          _trainingController.fetchVideoTrainings(categoryId: 'all');
                        } else {
                          final catObj = _categoryController.categories.firstWhere(
                            (c) => c.categoryName == category,
                            orElse: () => TrainingCategoryModel(id: 0, categoryName: ''),
                          );
                          if (catObj.id != 0) {
                            _trainingController.fetchVideoTrainings(categoryId: catObj.id.toString());
                          }
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryColor : const Color(0xFF0F121A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }),

            const SizedBox(height: 20),

            // Videos Grid/List
            Obx(() {
              if (_trainingController.isVideosLoading.value) {
                return const SizedBox(
                  height: 300,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primaryColor),
                  ),
                );
              }
              final videoList = _filteredVideos;
              if (videoList.isEmpty) {
                return Container(
                  height: 300,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.video_library_outlined, size: 64, color: Colors.white.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text(
                        "No training videos found",
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: videoList.length,
                itemBuilder: (context, index) {
                  final video = videoList[index];
                  final ytId = _getYoutubeId(video.fileUrl);

                  return GestureDetector(
                    onTap: () {
                      Get.to(() => TrainingVideoPlayerScreen(
                            trainingId: video.id,
                            youtubeId: ytId,
                            videoUrl: ytId == null ? video.fileUrl : null,
                            title: video.title,
                          ));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F121A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.03)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Thumbnail with Play overlay
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: ytId != null
                                    ? Image.network(
                                        'https://img.youtube.com/vi/$ytId/hqdefault.jpg',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, err, stack) {
                                          return Container(
                                            color: Colors.grey[900],
                                            child: const Icon(Icons.video_library, color: Colors.white24, size: 40),
                                          );
                                        },
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFF1E293B),
                                              const Color(0xFF0F172A),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(Icons.video_library_rounded, color: Colors.white24, size: 48),
                                        ),
                                      ),
                              ),
                              // Dark overlay
                              Positioned.fill(
                                child: Container(
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ),
                              // Play button icon
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.black,
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
                          // Title and details
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (video.category != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      video.category!.categoryName,
                                      style: const TextStyle(
                                        color: AppColors.primaryColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  video.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
