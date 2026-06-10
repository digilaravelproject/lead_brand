import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/route_helper.dart';
import '../controllers/tools_controller.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  late final ToolsController controller;
  String _searchQuery = "";
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(ToolsController());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: "Search tools...",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 16),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              )
            : const Text(
                "BUSINESS TOOLS",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 1.5,
                ),
              ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0F121A),
                border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
              ),
              child: IconButton(
                icon: Icon(
                  _isSearching ? Icons.close_rounded : Icons.search_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                onPressed: () {
                  setState(() {
                    if (_isSearching) {
                      _isSearching = false;
                      _searchQuery = "";
                      _searchController.clear();
                    } else {
                      _isSearching = true;
                    }
                  });
                },
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final filteredTools = controller.tools.where((tool) {
          return tool.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              tool.description.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        return Stack(
          children: [
            Column(
              children: [
                // Tools Grid
                Expanded(
                  child: controller.isLoading.value
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                        )
                      : filteredTools.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.build_outlined, size: 64, color: Colors.white.withOpacity(0.2)),
                                  const SizedBox(height: 16),
                                  Text(
                                    "No tools matched your search",
                                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 0.85,
                              ),
                              itemCount: filteredTools.length,
                              itemBuilder: (context, index) {
                                final tool = filteredTools[index];
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () async {
                                      if (tool.id == 6 || tool.id == 7 || tool.id == 8) {
                                        Get.toNamed(tool.route);
                                      } else {
                                        controller.isDetailLoading.value = true;
                                        final detail = await controller.fetchToolDetail(tool.id);
                                        controller.isDetailLoading.value = false;

                                        if (detail != null) {
                                          final List<dynamic> subtools = detail['subtools'] ?? [];
                                          if (subtools.isNotEmpty) {
                                            Get.toNamed(tool.route, arguments: {
                                              'title': tool.title.replaceAll('\n', ' '),
                                              'subtools': subtools,
                                            });
                                          } else {
                                            final List<dynamic> media = detail['media'] ?? [];
                                            final List<String> imageUrls = media.map((m) => m['full_url'].toString()).toList();
                                            Get.toNamed(RouteHelper.getGalleryRoute(), arguments: {
                                              'title': tool.title.replaceAll('\n', ' '),
                                              'images': imageUrls,
                                              'media': media,
                                            });
                                          }
                                        } else {
                                          // Fallback to pre-fetched data
                                          if (tool.subtools != null && tool.subtools!.isNotEmpty) {
                                            Get.toNamed(tool.route, arguments: {
                                              'title': tool.title.replaceAll('\n', ' '),
                                              'subtools': tool.subtools,
                                            });
                                          } else {
                                            final List<dynamic> media = tool.media ?? [];
                                            final List<String> imageUrls = media.map((m) => m['full_url'].toString()).toList();
                                            Get.toNamed(RouteHelper.getGalleryRoute(), arguments: {
                                              'title': tool.title.replaceAll('\n', ' '),
                                              'images': imageUrls,
                                              'media': media,
                                            });
                                          }
                                        }
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF0F121A),
                                            tool.color.withOpacity(0.04),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: tool.color.withOpacity(0.18),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: tool.color.withOpacity(0.03),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(14),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    tool.color.withOpacity(0.18),
                                                    tool.color.withOpacity(0.04),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                border: Border.all(
                                                  color: tool.color.withOpacity(0.25),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Icon(tool.icon, size: 28, color: tool.color),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4, right: 2),
                                              child: Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: 10,
                                                color: Colors.white.withOpacity(0.25),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          tool.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.5,
                                            letterSpacing: 0.25,
                                            height: 1.25,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          tool.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.45),
                                            fontSize: 11,
                                            height: 1.25,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
            if (controller.isDetailLoading.value)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
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
