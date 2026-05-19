import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/route_helper.dart';

class ToolItem {
  final String title;
  final String description;
  final IconData icon;
  final String route;
  final Color color;

  ToolItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    required this.color,
  });
}

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({Key? key}) : super(key: key);

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  final List<ToolItem> _tools = [
    ToolItem(
      title: "Combo\nPlans",
      description: "Explore customized insurance combo plans",
      icon: Icons.auto_awesome_motion_rounded,
      route: RouteHelper.getComboPlanRoute(),
      color: Colors.blue,
    ),
    ToolItem(
      title: "Combo\nPosters",
      description: "Browse designs and templates",
      icon: Icons.dashboard_customize_rounded,
      route: RouteHelper.getGalleryRoute(),
      color: Colors.lightBlue,
    ),
    ToolItem(
      title: "Concept\nBrochures",
      description: "Interactive insurance concepts",
      icon: Icons.menu_book_rounded,
      route: RouteHelper.getGalleryRoute(),
      color: Colors.orange,
    ),
    ToolItem(
      title: "LIC\nPlans",
      description: "All LIC insurance products and details",
      icon: Icons.description_rounded,
      route: RouteHelper.getLicPlansRoute(),
      color: Colors.green,
    ),
    ToolItem(
      title: "Agent\nRecruitment",
      description: "Agent recruitment materials",
      icon: Icons.person_add_rounded,
      route: RouteHelper.getGalleryRoute(),
      color: Colors.purple,
    ),
    ToolItem(
      title: "Promotional\nVideos",
      description: "Watch and share promotional videos",
      icon: Icons.play_circle_fill_rounded,
      route: '/promotional-videos',
      color: Colors.red,
    ),
    ToolItem(
      title: "Create\nVideo Ads",
      description: "Create premium short promotional videos",
      icon: Icons.video_call_rounded,
      route: RouteHelper.getVideoAdsRoute(),
      color: Colors.indigo,
    ),
    ToolItem(
      title: "Create\nPDF Calendar",
      description: "Generate custom PDF business calendars",
      icon: Icons.calendar_today_rounded,
      route: RouteHelper.getPdfCalendarRoute(),
      color: Colors.teal,
    ),
  ];

  String _searchQuery = "";
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTools = _tools.where((tool) {
      return tool.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tool.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

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
      body: Column(
        children: [

          // Tools Grid
          Expanded(
            child: filteredTools.isEmpty
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
                          onTap: () => Get.toNamed(tool.route),
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
    );
  }
}
