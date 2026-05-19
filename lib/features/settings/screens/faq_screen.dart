import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});
}

class FaqScreen extends StatelessWidget {
  FaqScreen({Key? key}) : super(key: key);

  final List<FaqItem> _faqs = [
    FaqItem(
      question: "What is Lead Brand Hub?",
      answer: "Lead Brand Hub is a premium branding and marketing app designed specifically for life insurance agents to create high-quality personalized PDF calendars, promotional video ads, combo plans, and marketing posters.",
    ),
    FaqItem(
      question: "How do I generate a custom PDF Calendar?",
      answer: "Navigate to the 'Tools' tab from the bottom menu, select 'PDF Calendar', fill in your profile details or contact information, choose a template format, and click 'Generate'. The app will compile your calendar with your brand details automatically.",
    ),
    FaqItem(
      question: "Can I share video ads directly to social media?",
      answer: "Yes! Once you create or select a video ad from the 'Video Ads' or 'Training' tabs, you can download it to your device's gallery or use the native Share button to share it directly to WhatsApp, Facebook, or Instagram.",
    ),
    FaqItem(
      question: "How do I update my brand/profile details?",
      answer: "Go to the 'Settings' tab, tap on your profile header at the top, and edit your details (Name, Phone Number, Email, and logo). These updated details will automatically show up on all generated PDFs, banners, and videos.",
    ),
    FaqItem(
      question: "Do I need an active internet connection?",
      answer: "An active internet connection is required to browse templates, download high-definition media files, and fetch new training videos from the backend database.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F121A),
        elevation: 0,
        title: const Text(
          "FAQS",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F121A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: AppColors.primaryColor,
                collapsedIconColor: Colors.grey,
                title: Text(
                  faq.question,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                    child: Text(
                      faq.answer,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
