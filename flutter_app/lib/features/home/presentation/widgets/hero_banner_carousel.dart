import 'package:flutter/material.dart';
import '../../widgets/hero_banner/hero_banner_section.dart';
import '../../models/hero_banner_model.dart';
import 'admin_banner_simulator.dart';

/// HeroBannerCarousel Component Architecture Shell
/// Features live Admin Simulator integration for testing dynamic payloads.
class HeroBannerCarousel extends StatefulWidget {
  final List<HeroBannerModel>? banners;
  final double height;
  final bool showAdminTestControl;

  const HeroBannerCarousel({
    super.key,
    this.banners,
    this.height = 190.0,
    this.showAdminTestControl = false,
  });

  @override
  State<HeroBannerCarousel> createState() => _HeroBannerCarouselState();
}

class _HeroBannerCarouselState extends State<HeroBannerCarousel> {
  List<HeroBannerModel>? _liveBanners;

  @override
  void initState() {
    super.initState();
    _liveBanners = widget.banners;
  }

  void _openAdminSimulator(BuildContext context) {
    AdminBannerSimulatorSheet.show(
      context,
      currentBanners: _liveBanners ?? HeroBannerModel.defaultBanners,
      onApplyBanners: (updatedBanners) {
        setState(() {
          _liveBanners = updatedBanners;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        HeroBannerSection(
          key: ValueKey(_liveBanners?.map((b) => b.id).join('_') ?? 'default'),
          banners: _liveBanners,
          height: widget.height,
        ),
        if (widget.showAdminTestControl) ...[
          const SizedBox(height: 6),
          InkWell(
            onTap: () => _openAdminSimulator(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1976FF).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF1976FF).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.admin_panel_settings_rounded, size: 14, color: Color(0xFF1976FF)),
                  SizedBox(width: 4),
                  Text(
                    '⚙️ Admin Test Panel (1-Click Test Cases)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1976FF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
