import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_web_view.dart';
import '../controllers/training_controller.dart';

class TrainingPdfDetailsScreen extends StatefulWidget {
  final int trainingId;
  final String title;

  const TrainingPdfDetailsScreen({
    Key? key,
    required this.trainingId,
    required this.title,
  }) : super(key: key);

  @override
  State<TrainingPdfDetailsScreen> createState() => _TrainingPdfDetailsScreenState();
}

class _TrainingPdfDetailsScreenState extends State<TrainingPdfDetailsScreen> {
  final TrainingController _trainingController = Get.find<TrainingController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trainingController.fetchTrainingDetails(widget.trainingId);
    });
  }

  void _openPdf(String fileUrl, String title) {
    final String gDocsUrl = "https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(fileUrl)}";
    Get.to(() => CustomWebView(
          url: gDocsUrl,
          title: title,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'DOCUMENT DETAILS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (_trainingController.isDetailsLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        final pdf = _trainingController.selectedTraining.value;
        if (pdf == null) {
          return Center(
            child: Text(
              'Failed to load document details',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Large PDF Icon Center card
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.06),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.red.withOpacity(0.12), width: 2),
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Colors.redAccent,
                          size: 72,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Category Tag
                    if (pdf.category != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          pdf.category!.categoryName.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Title
                    Text(
                      pdf.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Divider
                    Container(
                      height: 1.5,
                      width: double.infinity,
                      color: Colors.white.withOpacity(0.06),
                    ),
                    const SizedBox(height: 20),

                    // Section header
                    const Text(
                      'DESCRIPTION',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description text
                    Text(
                      pdf.description.isNotEmpty
                          ? pdf.description
                          : 'No description available for this training document.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14.5,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Action Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () => _openPdf(pdf.fileUrl, pdf.title),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book_rounded, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'VIEW DOCUMENT',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
