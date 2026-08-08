import 'package:flutter/material.dart';
import '../../services/cloudflare_service.dart';
import '../../features/home/models/hero_banner_model.dart';
import '../../features/home/widgets/hero_banner/hero_banner_card.dart';

class ManageBannersScreen extends StatefulWidget {
  const ManageBannersScreen({super.key});

  @override
  State<ManageBannersScreen> createState() => _ManageBannersScreenState();
}

class _ManageBannersScreenState extends State<ManageBannersScreen> {
  final CloudflareService _api = CloudflareService();
  List<HeroBannerModel> _banners = [];
  bool _isLoading = true;

  static const List<Map<String, String>> _presetAssets = [
    {'label': 'DIY Kits 3D Banner', 'path': 'assets/images/home/banner_bg_diy_kits.png'},
    {'label': 'Advanced Robotics', 'path': 'assets/images/courses/advanced_robotics.png'},
    {'label': 'Home Automation', 'path': 'assets/images/courses/iot_home_automation.png'},
    {'label': 'Electronics Fundamentals', 'path': 'assets/images/courses/electronics_fundamentals.png'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchBanners();
  }

  Future<void> _fetchBanners() async {
    setState(() => _isLoading = true);
    final rawBanners = await _api.getBanners();
    setState(() {
      if (rawBanners.isNotEmpty) {
        _banners = rawBanners
            .map((b) => HeroBannerModel.fromMap(Map<String, dynamic>.from(b)))
            .toList();
      } else {
        // Fallback default banners for initial admin setup
        _banners = List.from(HeroBannerModel.defaultBanners);
      }
      _isLoading = false;
    });
  }

  void _openBannerEditor({HeroBannerModel? existingBanner, int? index}) {
    final isEditing = existingBanner != null && index != null;

    final badgeController = TextEditingController(text: existingBanner?.badge ?? '');
    final titleController = TextEditingController(text: existingBanner?.title ?? '');
    final subtitleController = TextEditingController(text: existingBanner?.subtitle ?? '');
    final buttonTextController = TextEditingController(text: existingBanner?.buttonText ?? '');
    final imageUrlController = TextEditingController(
      text: existingBanner?.imagePath.startsWith('http') == true ? existingBanner!.imagePath : '',
    );
    final targetValueController = TextEditingController(text: existingBanner?.targetValue ?? '');

    String selectedPreset = existingBanner != null && !existingBanner.imagePath.startsWith('http')
        ? existingBanner.imagePath
        : _presetAssets.first['path']!;

    BannerClickAction selectedClickAction = existingBanner?.clickAction ?? BannerClickAction.openCategory;
    bool isActive = existingBanner?.isActive ?? true;
    double autoSlideDuration = (existingBanner?.autoSlideDurationSeconds ?? 5).toDouble();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            // Determine active image path (Network URL or Preset Asset)
            final currentImagePath = imageUrlController.text.trim().isNotEmpty
                ? imageUrlController.text.trim()
                : selectedPreset;

            // Build dynamic model for LIVE REAL-TIME PREVIEW
            final previewModel = HeroBannerModel(
              id: existingBanner?.id ?? 'preview',
              imagePath: currentImagePath,
              badge: badgeController.text.trim().isEmpty ? null : badgeController.text.trim(),
              title: titleController.text.trim().isEmpty ? null : titleController.text.trim(),
              subtitle: subtitleController.text.trim().isEmpty ? null : subtitleController.text.trim(),
              buttonText: buttonTextController.text.trim().isEmpty ? null : buttonTextController.text.trim(),
              clickAction: selectedClickAction,
              targetValue: targetValueController.text.trim().isEmpty ? null : targetValueController.text.trim(),
              isActive: isActive,
              autoSlideDurationSeconds: autoSlideDuration.toInt(),
            );

            return Container(
              height: MediaQuery.of(context).size.height * 0.90,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Top Drag Handle & Modal Title
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isEditing ? Icons.edit_note_rounded : Icons.add_photo_alternate_rounded,
                            color: const Color(0xFF5D3AC8),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isEditing ? "Edit Selected Banner" : "Create New Banner",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const Divider(),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. LIVE REAL-TIME PREVIEW SECTION
                          const Text(
                            "📱 Live Real-Time Banner Preview",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 8),
                          HeroBannerCard(banner: previewModel),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 12),

                          // 2. IMAGE UPLOAD & SELECTION SECTION
                          const Text(
                            "🖼️ Image Upload & Background Asset",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: imageUrlController,
                            onChanged: (_) => setModalState(() {}),
                            decoration: InputDecoration(
                              labelText: "Custom Image URL (Direct Link)",
                              hintText: "https://example.com/banner.png",
                              prefixIcon: const Icon(Icons.link_rounded),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            initialValue: selectedPreset,
                            decoration: InputDecoration(
                              labelText: "Or Select Preset App Asset Image",
                              prefixIcon: const Icon(Icons.collections_rounded),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              isDense: true,
                            ),
                            items: _presetAssets
                                .map((p) => DropdownMenuItem(
                                      value: p['path'],
                                      child: Text(p['label']!, style: const TextStyle(fontSize: 13)),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() {
                                  selectedPreset = val;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 20),

                          // 3. OPTIONAL TEXT SECTIONS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "✍️ Optional Text Sections",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                              ),
                              Text(
                                "(Leave blank to hide)",
                                style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Badge Field
                          TextField(
                            controller: badgeController,
                            onChanged: (_) => setModalState(() {}),
                            decoration: InputDecoration(
                              labelText: "Badge Pill (Optional - e.g. NEW ARRIVAL, 50% OFF)",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Title Field
                          TextField(
                            controller: titleController,
                            onChanged: (_) => setModalState(() {}),
                            decoration: InputDecoration(
                              labelText: "Title (Optional - Main Heading Text)",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Subtitle Field
                          TextField(
                            controller: subtitleController,
                            onChanged: (_) => setModalState(() {}),
                            decoration: InputDecoration(
                              labelText: "Subtitle (Optional - Description Line)",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Button Text Field
                          TextField(
                            controller: buttonTextController,
                            onChanged: (_) => setModalState(() {}),
                            decoration: InputDecoration(
                              labelText: "Button Action Text (Optional - e.g. Explore Now)",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 4. NAVIGATION & ACTION SETTINGS
                          const Text(
                            "🎯 Banner Click Action & Target",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 10),

                          DropdownButtonFormField<BannerClickAction>(
                            initialValue: selectedClickAction,
                            decoration: InputDecoration(
                              labelText: "On Click Action",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              isDense: true,
                            ),
                            items: BannerClickAction.values.map((act) {
                              return DropdownMenuItem(
                                value: act,
                                child: Text(act.name, style: const TextStyle(fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setModalState(() => selectedClickAction = val);
                            },
                          ),
                          const SizedBox(height: 10),

                          TextField(
                            controller: targetValueController,
                            onChanged: (_) => setModalState(() {}),
                            decoration: InputDecoration(
                              labelText: "Target Value (Course ID, Category, URL, etc.)",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Active Status & Duration Settings
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text("Banner Active Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text(isActive ? "Visible on Home Carousel" : "Hidden from users", style: const TextStyle(fontSize: 12)),
                            value: isActive,
                            onChanged: (val) => setModalState(() => isActive = val),
                          ),

                          Row(
                            children: [
                              Text("Auto-slide Duration: ${autoSlideDuration.toInt()} sec", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              Expanded(
                                child: Slider(
                                  value: autoSlideDuration,
                                  min: 2,
                                  max: 10,
                                  divisions: 8,
                                  activeColor: const Color(0xFF5D3AC8),
                                  onChanged: (val) => setModalState(() => autoSlideDuration = val),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Save Action Button
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5D3AC8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      onPressed: () async {
                        final nav = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        final finalImagePath = imageUrlController.text.trim().isNotEmpty
                            ? imageUrlController.text.trim()
                            : selectedPreset;

                        final savedBanner = HeroBannerModel(
                          id: isEditing
                              ? existingBanner.id
                              : 'banner_${DateTime.now().millisecondsSinceEpoch}',
                          imagePath: finalImagePath,
                          badge: badgeController.text.trim().isEmpty ? null : badgeController.text.trim(),
                          title: titleController.text.trim().isEmpty ? null : titleController.text.trim(),
                          subtitle: subtitleController.text.trim().isEmpty ? null : subtitleController.text.trim(),
                          buttonText: buttonTextController.text.trim().isEmpty ? null : buttonTextController.text.trim(),
                          clickAction: selectedClickAction,
                          targetValue: targetValueController.text.trim().isEmpty ? null : targetValueController.text.trim(),
                          isActive: isActive,
                          displayOrder: isEditing ? existingBanner.displayOrder : _banners.length + 1,
                          autoSlideDurationSeconds: autoSlideDuration.toInt(),
                        );

                        if (isEditing) {
                          setState(() {
                            _banners[index] = savedBanner;
                          });
                          await _api.updateBanner(savedBanner.id, savedBanner.toMap());
                        } else {
                          setState(() {
                            _banners.add(savedBanner);
                          });
                          await _api.addBanner(savedBanner.toMap());
                        }

                        nav.pop();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              isEditing ? "Banner updated successfully!" : "New Banner published successfully!",
                            ),
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: Icon(isEditing ? Icons.check_circle_outline : Icons.cloud_upload_rounded),
                      label: Text(
                        isEditing ? "Save Banner Changes" : "Create & Publish Banner",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteBanner(int index) {
    final banner = _banners[index];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Banner?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete '${banner.title ?? 'Selected Banner'}'? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final nav = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              nav.pop();
              final deletedBannerId = banner.id;
              setState(() {
                _banners.removeAt(index);
              });
              await _api.deleteBanner(deletedBannerId);
              messenger.showSnackBar(
                const SnackBar(
                  content: Text("Banner deleted successfully"),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF5D3AC8),
        title: const Text(
          "Admin Banner Management",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: "Refresh Banners",
            onPressed: _fetchBanners,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF5D3AC8)))
          : Column(
              children: [
                // Top Header Summary & Quick Create Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Banners: ${_banners.length}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Select any banner to edit or delete",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5D3AC8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        onPressed: () => _openBannerEditor(),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text("Create Banner", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                ),

                // Main Banner Cards List
                Expanded(
                  child: _banners.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.view_carousel_outlined, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text("No banners found.", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => _openBannerEditor(),
                                child: const Text("Create First Banner"),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _banners.length,
                          itemBuilder: (context, index) {
                            final banner = _banners[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Live Banner Rendering Card Preview
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: HeroBannerCard(banner: banner),
                                  ),

                                  // Control Bar (Edit, Delete, Active Status)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                                    ),
                                    child: Row(
                                      children: [
                                        // Active Pill Tag
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: (banner.isActive ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 4,
                                                backgroundColor: banner.isActive ? Colors.green : Colors.orange,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                banner.isActive ? "ACTIVE" : "INACTIVE",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: banner.isActive ? Colors.green.shade700 : Colors.orange.shade800,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        // Action type tag
                                        Expanded(
                                          child: Text(
                                            "Action: ${banner.clickAction.name}",
                                            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        // EDIT BUTTON
                                        OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: const Color(0xFF5D3AC8),
                                            side: const BorderSide(color: Color(0xFF5D3AC8)),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            minimumSize: Size.zero,
                                          ),
                                          onPressed: () => _openBannerEditor(existingBanner: banner, index: index),
                                          icon: const Icon(Icons.edit_rounded, size: 16),
                                          label: const Text("Edit", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(width: 8),

                                        // DELETE BUTTON
                                        OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red,
                                            side: BorderSide(color: Colors.red.shade300),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            minimumSize: Size.zero,
                                          ),
                                          onPressed: () => _confirmDeleteBanner(index),
                                          icon: const Icon(Icons.delete_outline_rounded, size: 16),
                                          label: const Text("Delete", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openBannerEditor(),
        backgroundColor: const Color(0xFF5D3AC8),
        icon: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white),
        label: const Text("Create New Banner", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
