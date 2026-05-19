import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_web_view.dart';

class TrainingPdf {
  final String title;
  final String category;
  final String pdfUrl;
  final String size;
  final int pages;
  final String description;

  TrainingPdf({
    required this.title,
    required this.category,
    required this.pdfUrl,
    required this.size,
    required this.pages,
    required this.description,
  });
}

class TrainingPdfsScreen extends StatefulWidget {
  const TrainingPdfsScreen({Key? key}) : super(key: key);

  @override
  State<TrainingPdfsScreen> createState() => _TrainingPdfsScreenState();
}

class _TrainingPdfsScreenState extends State<TrainingPdfsScreen> {
  final List<TrainingPdf> _allPdfs = [
    TrainingPdf(
      title: "Lead Generation Playbook",
      category: "Lead Gen",
      pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
      size: "1.4 MB",
      pages: 12,
      description: "Proven strategies and scripts for generating high-quality life insurance leads daily.",
    ),
    TrainingPdf(
      title: "Handling Objections Guide",
      category: "Sales",
      pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
      size: "980 KB",
      pages: 8,
      description: "How to confidently overcome common client objections regarding premium prices and policy terms.",
    ),
    TrainingPdf(
      title: "Personal Branding Toolkit",
      category: "Branding",
      pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
      size: "2.1 MB",
      pages: 18,
      description: "Step-by-step instructions to position yourself as the trustable insurance advisor in your community.",
    ),
    TrainingPdf(
      title: "Combo Plans Pitching Deck",
      category: "Product Pitch",
      pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
      size: "3.2 MB",
      pages: 25,
      description: "Beautiful visual presentations and customer benefit calculations for combo insurance plans.",
    ),
    TrainingPdf(
      title: "LIC Policy Comparison Sheet",
      category: "Product Pitch",
      pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
      size: "820 KB",
      pages: 6,
      description: "Quick reference guide comparing returns, maturity benefits, and risk coverage of top plans.",
    ),
    TrainingPdf(
      title: "Cold Calling Scripts & Templates",
      category: "Lead Gen",
      pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
      size: "1.1 MB",
      pages: 10,
      description: "High-converting script templates to turn cold calls into booked appointments.",
    ),
  ];

  final List<String> _categories = ["All", "Lead Gen", "Sales", "Branding", "Product Pitch"];
  String _selectedCategory = "All";
  String _searchQuery = "";

  List<TrainingPdf> get _filteredPdfs {
    return _allPdfs.where((pdf) {
      final matchesCategory = _selectedCategory == "All" || pdf.category == _selectedCategory;
      final matchesSearch = pdf.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pdf.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _viewPdf(TrainingPdf pdf) {
    // Standard web URL for viewing PDF in Mobile WebView via Google Docs Viewer
    final String gDocsUrl = "https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(pdf.pdfUrl)}";
    Get.to(() => CustomWebView(
          url: gDocsUrl,
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
                  setState(() {
                    _searchQuery = val;
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
          SizedBox(
            height: 38,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
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
          ),

          const SizedBox(height: 16),

          // Document List
          Expanded(
            child: _filteredPdfs.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredPdfs.length,
                    itemBuilder: (context, index) {
                      final pdf = _filteredPdfs[index];
                      return _buildPdfCard(pdf);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfCard(TrainingPdf pdf) {
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          pdf.category.toUpperCase(),
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
                            "${pdf.pages} Pages",
                            style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 14),
                          Icon(Icons.save_alt_rounded, size: 12, color: Colors.white.withOpacity(0.35)),
                          const SizedBox(width: 4),
                          Text(
                            pdf.size,
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
