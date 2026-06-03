import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/legal_controller.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  late final WebViewController _webController;
  final LegalController controller = Get.find<LegalController>();
  bool _isWebViewLoading = true;

  @override
  void initState() {
    super.initState();
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF080B11))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isWebViewLoading = false;
              });
            }
          },
        ),
      );

    // Listen to page changes to load HTML string
    ever(controller.aboutUsPage, (page) {
      if (page != null && page.description.isNotEmpty) {
        _webController.loadHtmlString(wrapHtmlContent(page.description));
      }
    });

    // If already loaded
    if (controller.aboutUsPage.value != null && controller.aboutUsPage.value!.description.isNotEmpty) {
      _webController.loadHtmlString(wrapHtmlContent(controller.aboutUsPage.value!.description));
    }
  }

  String wrapHtmlContent(String bodyHtml) {
    return """
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
      <style>
        body {
          background-color: #080B11;
          color: #E2E8F0;
          font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
          padding: 20px;
          margin: 0;
          line-height: 1.6;
          font-size: 15px;
        }
        h1, h2, h3, h4, h5, h6 {
          color: #FFFFFF;
          margin-top: 24px;
          margin-bottom: 12px;
          font-weight: 700;
         }
        h2 {
          font-size: 20px;
          border-bottom: 1px solid #1E293B;
          padding-bottom: 8px;
        }
        p {
          margin-top: 0;
          margin-bottom: 16px;
        }
        ul, ol {
          margin-top: 0;
          padding-left: 24px;
        }
        li {
          margin-bottom: 8px;
        }
      </style>
    </head>
    <body>
      $bodyHtml
    </body>
    </html>
    """;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F121A),
        elevation: 0,
        title: Obx(() => Text(
          controller.aboutUsPage.value?.pageName.replaceAll('_', ' ').capitalizeFirst ?? "About Us",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isAboutUsLoading.value && controller.aboutUsPage.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        if (controller.aboutUsPage.value == null) {
          return const Center(
            child: Text(
              'No Content Available',
              style: TextStyle(color: AppColors.textColorSecondary, fontSize: 16),
            ),
          );
        }

        return Stack(
          children: [
            WebViewWidget(controller: _webController),
            if (_isWebViewLoading)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              ),
          ],
        );
      }),
    );
  }
}
