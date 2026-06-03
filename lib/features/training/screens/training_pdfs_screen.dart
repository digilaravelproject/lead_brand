import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/category_controller.dart';
import '../domain/models/category_model.dart';
import '../domain/models/training_model.dart';
import '../controllers/training_controller.dart';
import 'training_pdf_details_screen.dart';

class TrainingPdfsScreen extends StatefulWidget {
  const TrainingPdfsScreen({Key? key}) : super(key: key);

  @override
  State<TrainingPdfsScreen> createState() => _TrainingPdfsScreenState();
}

class _TrainingPdfsScreenState extends State<TrainingPdfsScreen> {
  final CategoryController _categoryController = Get.find<CategoryController>();
  final TrainingController _trainingController = Get.find<TrainingController>();
  String _selectedCategory = "All";
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trainingController.fetchPdfTrainings(categoryId: 'all');
    });
  }

  List<TrainingModel> get _filteredPdfs {
    return _trainingController.pdfs;
  }

  void _viewPdf(TrainingModel pdf) {
    Get.to(() => TrainingPdfDetailsScreen(
          trainingId: pdf.id,
          title: pdf.title,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'TRAINING DOCUMENTS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: TextField(
                onChanged: (val) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    if (val.trim().isEmpty) {
                      if (_selectedCategory == 'All') {
                        _trainingController.fetchPdfTrainings(categoryId: 'all');
                      } else {
                        final catObj = _categoryController.categories.firstWhere(
                          (c) => c.categoryName == _selectedCategory,
                          orElse: () => TrainingCategoryModel(id: 0, categoryName: ''),
                        );
                        if (catObj.id != 0) {
                          _trainingController.fetchPdfTrainings(categoryId: catObj.id.toString());
                        }
                      }
                    } else {
                      _trainingController.searchPdfTrainings(val.trim());
                    }
                  });
                },
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search training PDFs...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.white30, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Categories Selector
          Obx(() {
            final categoriesList = ["All", ..._categoryController.categories.map((c) => c.categoryName)];
            return SizedBox(
              height: 38,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: categoriesList.length,
                itemBuilder: (context, index) {
                  final category = categoriesList[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                        if (category == 'All') {
                          _trainingController.fetchPdfTrainings(categoryId: 'all');
                        } else {
                          final catObj = _categoryController.categories.firstWhere(
                            (c) => c.categoryName == category,
                            orElse: () => TrainingCategoryModel(id: 0, categoryName: ''),
                          );
                          if (catObj.id != 0) {
                            _trainingController.fetchPdfTrainings(categoryId: catObj.id.toString());
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryColor : AppColors.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.white.withOpacity(0.04),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),

          const SizedBox(height: 16),

          // Document List
          Expanded(
            child: Obx(() {
              if (_trainingController.isPdfsLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryColor),
                );
              }
              final pdfList = _filteredPdfs;
              if (pdfList.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: pdfList.length,
                itemBuilder: (context, index) {
                  final pdf = pdfList[index];
                  return _buildPdfCard(pdf);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfCard(TrainingModel pdf) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => _viewPdf(pdf),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PDF Icon Badge
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 28),
                ),
                const SizedBox(width: 16),
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag
                      if (pdf.category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            pdf.category!.categoryName.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Title
                      Text(
                        pdf.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Description
                      Text(
                        pdf.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Size & Pages metadata
                      Row(
                        children: [
                          Icon(Icons.insert_drive_file_outlined, size: 12, color: Colors.white.withOpacity(0.35)),
                          const SizedBox(width: 4),
                          Text(
                            "PDF Document",
                            style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Arrow Icon
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.find_in_page_outlined, size: 48, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'No matching PDFs found',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
