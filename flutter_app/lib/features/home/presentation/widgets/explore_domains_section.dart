import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/domain_model.dart';
import '../../../../widgets/edukkit_category_icon.dart';
import '../../../../screens/courses/robotics_courses_screen.dart';
import '../../../../screens/courses/iot_courses_screen.dart';
import '../../../../screens/courses/electronics_courses_screen.dart';
import '../../../../screens/courses/diy_kits_courses_screen.dart';

/// Module 3 (LOCKED) – Production-Ready Explore Domains Section for Edukkit
/// Squircle Rounded Category Container Layout matching exact design screenshot.
/// Admin-ready architecture loading strictly from DomainModel.
class ExploreDomainsSection extends StatelessWidget {
  final List<DomainModel>? domains;
  final Function(DomainModel domain)? onDomainTap;

  const ExploreDomainsSection({
    super.key,
    this.domains,
    this.onDomainTap,
  });

  void _handleDomainTap(BuildContext context, DomainModel domain) {
    if (onDomainTap != null) {
      onDomainTap!(domain);
      return;
    }

    Widget? targetScreen;
    switch (domain.targetRoute) {
      case '/courses/robotics':
        targetScreen = const RoboticsCoursesScreen();
        break;
      case '/courses/iot':
        targetScreen = const IotCoursesScreen();
        break;
      case '/courses/electronics':
        targetScreen = const ElectronicsCoursesScreen();
        break;
      case '/courses/diy-kits':
        targetScreen = const DiyKitsCoursesScreen();
        break;
      default:
        targetScreen = null;
        break;
    }

    if (targetScreen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetScreen!),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${domain.title} courses coming soon!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Load active domains sorted by display order
    final domainsList = (domains ?? DomainModel.defaultDomains)
        .where((d) => d.isActive)
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final bool isTablet = screenWidth >= 600;
        final bool isSmallMobile = screenWidth < 360;

        // Responsive Sizing
        final double iconSize = isTablet ? 32.0 : (isSmallMobile ? 26.0 : 28.0);
        final double sectionTitleSize = isTablet ? 22.0 : (isSmallMobile ? 17.0 : 18.0);
        final double subtitleSize = isTablet ? 14.0 : (isSmallMobile ? 12.0 : 13.0);
        final double horizontalPadding = isTablet ? 24.0 : (isSmallMobile ? 12.0 : 16.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. SECTION HEADER
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore Domains 🚀',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: sectionTitleSize,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Choose your learning path',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: subtitleSize,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 2. CATEGORIES ROW (Static & Responsive across all phone screen sizes)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: domainsList.map((domain) {
                  return Expanded(
                    child: CircularDomainItem(
                      domain: domain,
                      circleSize: isTablet ? 60.0 : 52.0,
                      iconSize: iconSize,
                      fontSize: isTablet ? 12.0 : 10.5,
                      onTap: () => _handleDomainTap(context, domain),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Modular Category Item matching exact squircle shape (BorderRadius 22dp)
class CircularDomainItem extends StatefulWidget {
  final DomainModel domain;
  final double circleSize;
  final double iconSize;
  final double fontSize;
  final VoidCallback onTap;

  const CircularDomainItem({
    super.key,
    required this.domain,
    required this.circleSize,
    required this.iconSize,
    required this.fontSize,
    required this.onTap,
  });

  @override
  State<CircularDomainItem> createState() => _CircularDomainItemState();
}

class _CircularDomainItemState extends State<CircularDomainItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final domain = widget.domain;
    final borderRadius = BorderRadius.circular(22);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. SQUIRCLE CONTAINER
        AnimatedScale(
          scale: _isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Container(
            width: widget.circleSize,
            height: widget.circleSize,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: domain.color.withValues(alpha: 0.10), // Soft background tint
              border: Border.all(
                color: domain.color.withValues(alpha: 0.25), // 1.2dp border
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: domain.color.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: borderRadius,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                borderRadius: borderRadius,
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                onTap: widget.onTap,
                child: Center(
                  child: domain.image != null && domain.image!.isNotEmpty
                      ? EdukkitCategoryIcon(
                          iconAsset: domain.image!,
                          size: widget.circleSize,
                          iconRatio: 0.88,
                          shadowColor: domain.color.withValues(alpha: 0.15),
                        )
                      : Icon(
                          domain.icon ?? Icons.category_rounded,
                          size: widget.iconSize,
                          color: domain.color,
                        ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 2. TEXT (Single line, maxLines = 1, TextOverflow.ellipsis, Centered)
        Text(
          domain.title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
