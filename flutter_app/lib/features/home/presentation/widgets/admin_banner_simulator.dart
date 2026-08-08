import 'package:flutter/material.dart';
import '../../models/hero_banner_model.dart';
import '../../models/hero_banner_test_payloads.dart';

/// Interactive Admin Banner Simulator Sheet for Live Testing.
/// Allows live testing of all 9 Admin Panel test cases right inside the app.
class AdminBannerSimulatorSheet extends StatefulWidget {
  final List<HeroBannerModel> currentBanners;
  final Function(List<HeroBannerModel> updatedBanners) onApplyBanners;

  const AdminBannerSimulatorSheet({
    super.key,
    required this.currentBanners,
    required this.onApplyBanners,
  });

  static void show(
    BuildContext context, {
    required List<HeroBannerModel> currentBanners,
    required Function(List<HeroBannerModel> updatedBanners) onApplyBanners,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AdminBannerSimulatorSheet(
        currentBanners: currentBanners,
        onApplyBanners: onApplyBanners,
      ),
    );
  }

  @override
  State<AdminBannerSimulatorSheet> createState() => _AdminBannerSimulatorSheetState();
}

class _AdminBannerSimulatorSheetState extends State<AdminBannerSimulatorSheet> {
  final _titleController = TextEditingController(text: 'Build. Create. Innovate.');
  final _subtitleController = TextEditingController(text: 'Hands-on DIY Robotics & Electronics Kits');
  final _badgeController = TextEditingController(text: 'NEW ARRIVAL');
  final _buttonTextController = TextEditingController(text: 'Explore Kits Now');
  final _targetValueController = TextEditingController(text: 'DIY Kits');

  final String _selectedImagePath = 'assets/images/home/banner_bg_diy_kits.png';
  BannerClickAction _selectedClickAction = BannerClickAction.openCategory;
  double _autoSlideDuration = 5.0;

  void _applyPreset(HeroBannerModel model) {
    widget.onApplyBanners([model]);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied Admin Banner Payload: ${model.id}'),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _applyAllTestBanners() {
    widget.onApplyBanners(HeroBannerTestPayloads.allTestBanners);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Loaded Carousel with all 6 Admin Test Payloads!'),
        backgroundColor: Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _applyCustomBanner() {
    final customBanner = HeroBannerModel(
      id: 'custom_admin_${DateTime.now().millisecondsSinceEpoch}',
      imagePath: _selectedImagePath,
      title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
      subtitle: _subtitleController.text.trim().isEmpty ? null : _subtitleController.text.trim(),
      badge: _badgeController.text.trim().isEmpty ? null : _badgeController.text.trim(),
      buttonText: _buttonTextController.text.trim().isEmpty ? null : _buttonTextController.text.trim(),
      clickAction: _selectedClickAction,
      targetValue: _targetValueController.text.trim().isEmpty ? null : _targetValueController.text.trim(),
      autoSlideDurationSeconds: _autoSlideDuration.toInt(),
      isActive: true,
      displayOrder: 1,
    );

    widget.onApplyBanners([customBanner]);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Applied Custom Admin Banner!'),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Drag Handle & Title
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF1976FF)),
                  SizedBox(width: 8),
                  Text(
                    'Admin Panel Banner Simulator',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1-Click Quick Preset Tests
                  const Text(
                    '⚡ 1-Click Quick Test Cases (Checklist)',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF10B981)),
                        label: const Text('Test 1: Image Only'),
                        onPressed: () => _applyPreset(HeroBannerTestPayloads.test1ImageOnly),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF10B981)),
                        label: const Text('Test 2: Image + Title'),
                        onPressed: () => _applyPreset(HeroBannerTestPayloads.test2ImageTitle),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF10B981)),
                        label: const Text('Test 3: Image + Title + Subtitle'),
                        onPressed: () => _applyPreset(HeroBannerTestPayloads.test3ImageTitleSubtitle),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF10B981)),
                        label: const Text('Test 4: Image + Button'),
                        onPressed: () => _applyPreset(HeroBannerTestPayloads.test4ImageButton),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF10B981)),
                        label: const Text('Test 5: Image + Badge'),
                        onPressed: () => _applyPreset(HeroBannerTestPayloads.test5ImageBadge),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF10B981)),
                        label: const Text('Test 6: Full Marketing Banner'),
                        onPressed: () => _applyPreset(HeroBannerTestPayloads.test6FullBanner),
                      ),
                      ActionChip(
                        backgroundColor: const Color(0xFF1976FF).withValues(alpha: 0.1),
                        avatar: const Icon(Icons.view_carousel_rounded, size: 16, color: Color(0xFF1976FF)),
                        label: const Text('Test 8: Carousel (All 6 Banners)'),
                        onPressed: _applyAllTestBanners,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Custom Payload Form
                  const Text(
                    '✍️ Create Custom Admin Payload',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _badgeController,
                    decoration: const InputDecoration(
                      labelText: 'Badge (Optional - Leave empty to hide)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title (Optional - Leave empty to hide)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _subtitleController,
                    decoration: const InputDecoration(
                      labelText: 'Subtitle (Optional - Leave empty to hide)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _buttonTextController,
                    decoration: const InputDecoration(
                      labelText: 'Button Text (Optional - Leave empty to hide)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Click Action Dropdown
                  DropdownButtonFormField<BannerClickAction>(
                    initialValue: _selectedClickAction,
                    decoration: const InputDecoration(
                      labelText: 'Banner Click Action',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: BannerClickAction.values.map((act) {
                      return DropdownMenuItem(
                        value: act,
                        child: Text(act.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedClickAction = val);
                    },
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _targetValueController,
                    decoration: const InputDecoration(
                      labelText: 'Target Value (Course ID, Category, URL etc.)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text('Auto-Slide Duration: ${_autoSlideDuration.toInt()} sec'),
                  Slider(
                    value: _autoSlideDuration,
                    min: 2,
                    max: 10,
                    divisions: 8,
                    label: '${_autoSlideDuration.toInt()} sec',
                    onChanged: (val) => setState(() => _autoSlideDuration = val),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _applyCustomBanner,
              icon: const Icon(Icons.rocket_launch_rounded),
              label: const Text('Apply Custom Admin Payload Live', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
