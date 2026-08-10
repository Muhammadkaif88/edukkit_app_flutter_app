import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Item Data Model for Edukkit Bottom Navigation Bar
class EdukkitNavItem {
  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;

  const EdukkitNavItem({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
  });
}

/// Floating, Modern Edukkit Bottom Navigation Bar
/// Floating rounded white card container matching the reference design layout:
/// - Floating slightly above the bottom with 16px left/right margins
/// - Large rounded corners (26px)
/// - Soft floating shadow
/// - Encloses BOTH active icon and label text inside a soft rounded pill (#EEF2FF)
/// - 5 equal items across all phone widths with iOS/Android safe area handling
class EdukkitBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const EdukkitBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<EdukkitNavItem> items = [
    EdukkitNavItem(
      label: 'Home',
      activeIcon: Icons.home_rounded,
      inactiveIcon: Icons.home_outlined,
    ),
    EdukkitNavItem(
      label: 'My Learning',
      activeIcon: Icons.play_circle_fill_rounded,
      inactiveIcon: Icons.play_circle_outline_rounded,
    ),
    EdukkitNavItem(
      label: 'Courses',
      activeIcon: Icons.auto_stories_rounded,
      inactiveIcon: Icons.auto_stories_outlined,
    ),
    EdukkitNavItem(
      label: 'School',
      activeIcon: Icons.school_rounded,
      inactiveIcon: Icons.school_outlined,
    ),
    EdukkitNavItem(
      label: 'Store',
      activeIcon: Icons.shopping_bag_rounded,
      inactiveIcon: Icons.shopping_bag_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final effectiveBottomInset = bottomInset > 0 ? bottomInset : 0.0;

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(18, 0, 18, 14 + effectiveBottomInset),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: const Color(0xFFF1F5F9), // Subtle slate border
            width: 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000), // Soft floating shadow
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: Color(0x0C4F46E5), // Subtle indigo ambient glow
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;

              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTap(index),
                    splashColor: const Color(0x154F46E5),
                    highlightColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFEEF2FF) // Soft indigo pill (Reference match)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon
                          Icon(
                            isSelected ? item.activeIcon : item.inactiveIcon,
                            size: 19,
                            color: isSelected
                                ? const Color(0xFF4F46E5) // Edukkit Indigo Accent
                                : const Color(0xFF64748B), // Slate 500 Muted
                          ),
                          const SizedBox(height: 3),

                          // Text Label Underneath (Inside active pill when selected)
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.0,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              letterSpacing: -0.2,
                              color: isSelected
                                  ? const Color(0xFF4F46E5)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
