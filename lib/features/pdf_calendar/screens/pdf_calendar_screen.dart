import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/pdf_calendar_controller.dart';

class PdfCalendarScreen extends StatefulWidget {
  const PdfCalendarScreen({super.key});

  @override
  State<PdfCalendarScreen> createState() => _PdfCalendarScreenState();
}

class _PdfCalendarScreenState extends State<PdfCalendarScreen> {
  late final PdfCalendarController controller;
  late final WebViewController _webViewController;
  late final Worker _pdfUrlWorker;
  late final Worker _isLoadingWorker;
  late final Worker _isPdfLoadingWorker;
  Timer? _loadingTimer;
  bool _showRefreshButton = false;
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<PdfCalendarController>()
        ? Get.find<PdfCalendarController>()
        : Get.put(PdfCalendarController());

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.backgroundColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            controller.isPdfLoading.value = true;
          },
          onPageFinished: (String url) {
            controller.isPdfLoading.value = false;
            if (mounted && !_hasLoadedOnce) {
              setState(() {
                _hasLoadedOnce = true;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            controller.isPdfLoading.value = false;
          },
        ),
      );

    if (controller.pdfUrl.value.isNotEmpty) {
      _loadPdfUrl(controller.pdfUrl.value);
    }

    _pdfUrlWorker = ever(controller.pdfUrl, (String url) {
      if (url.isNotEmpty) {
        _loadPdfUrl(url);
      }
    });

    _isLoadingWorker = ever(controller.isLoading, (bool loading) {
      _checkLoadingState();
    });

    _isPdfLoadingWorker = ever(controller.isPdfLoading, (bool loading) {
      _checkLoadingState();
    });

    _checkLoadingState();
  }

  void _checkLoadingState() {
    final bool loading = controller.isLoading.value || controller.isPdfLoading.value;
    if (loading) {
      _startLoadingTimer();
    } else {
      _cancelLoadingTimer();
      if (mounted && _showRefreshButton) {
        setState(() {
          _showRefreshButton = false;
        });
      }
    }
  }

  void _startLoadingTimer() {
    _loadingTimer?.cancel();
    _loadingTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          _showRefreshButton = true;
        });
      }
    });
  }

  void _cancelLoadingTimer() {
    _loadingTimer?.cancel();
    _loadingTimer = null;
  }

  @override
  void dispose() {
    _isLoadingWorker.dispose();
    _isPdfLoadingWorker.dispose();
    _pdfUrlWorker.dispose();
    _loadingTimer?.cancel();
    Get.delete<PdfCalendarController>();
    super.dispose();
  }

  void _loadPdfUrl(String url) {
    final String gDocsUrl = "https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(url)}";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _webViewController.loadRequest(Uri.parse(gDocsUrl));
      }
    });
  }

  void _showYearSelectionBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: const BoxDecoration(
          color: Color(0xFF121722), // Dark slate matching app design
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Calendar Year',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.2,
              ),
              itemCount: controller.years.length,
              itemBuilder: (context, index) {
                final year = controller.years[index];
                return Obx(() {
                  final isSelected = controller.selectedYear.value == year;
                  return GestureDetector(
                    onTap: () {
                      controller.updateYear(year);
                      controller.generateCalendar(year);
                      Navigator.pop(context); // close bottomsheet
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryColor : const Color(0xFF0F121A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected 
                              ? AppColors.primaryColor 
                              : Colors.white.withOpacity(0.08),
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryColor.withOpacity(0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          year.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
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
          'PDF CALENDAR',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 17,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            child: Obx(() => ActionChip(
              backgroundColor: AppColors.primaryColor.withOpacity(0.12),
              side: const BorderSide(color: AppColors.primaryColor, width: 1.2),
              avatar: const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.primaryColor),
              label: Text(
                controller.selectedYear.value.toString(),
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              onPressed: () => _showYearSelectionBottomSheet(context),
            )),
          ),
        ],
      ),
      body: Obx(() {
        final bool showLoader = controller.isLoading.value || controller.isPdfLoading.value;
        final bool isEmpty = controller.pdfUrl.value.isEmpty;

        return Stack(
          children: [
            // Always keep WebViewWidget in the tree so the platform view is initialized immediately
            WebViewWidget(controller: _webViewController),
            
            // Show solid dark loader overlay if loading (prevents white flashes and platform view initialization race conditions)
            if (showLoader)
              Container(
                color: AppColors.backgroundColor,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: AppColors.primaryColor),
                      if (_showRefreshButton) ...[
                        const SizedBox(height: 24),
                        Text(
                          "Taking too long to load?",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _showRefreshButton = false;
                            });
                            controller.generateCalendar(controller.selectedYear.value);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text(
                            "Refresh",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
            // Show error message if not loading and PDF URL is empty
            if (isEmpty && !controller.isLoading.value)
              Container(
                color: AppColors.backgroundColor,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.picture_as_pdf_outlined,
                        size: 64,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Failed to load calendar",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
