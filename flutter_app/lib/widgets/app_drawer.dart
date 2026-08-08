import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/learning/my_learning_screen.dart';
import '../screens/certificates/certificates_screen.dart';
import '../screens/store/store_screen.dart';
import '../screens/store/diy_kits_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/help/help_support_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/teacher/teacher_dashboard_screen.dart';

/// Production-Ready Premium Material 3 Left Side Navigation Drawer for Edukkit
/// Width: 82% of screen width (Max 340dp on Tablets)
/// Shape: Rounded top-right & bottom-right corners (28dp)
class AppDrawer extends StatelessWidget {
  final String activeRoute;

  const AppDrawer({
    super.key,
    this.activeRoute = '/home',
  });

  @override
  Widget build(BuildContext context) {
    AuthProvider? authProvider;
    try {
      authProvider = Provider.of<AuthProvider>(context, listen: true);
    } catch (_) {
      authProvider = null;
    }

    final bool isGuest = authProvider == null || authProvider.role == UserRole.guest;
    final String rawUserName = (authProvider?.userName ?? '').trim();
    final String userName = (rawUserName.isEmpty || rawUserName == 'Guest') ? 'Muhammed Kaif' : rawUserName;
    final String userEmail = authProvider?.userEmail ?? (isGuest ? 'Guest User' : 'kaif@edukkit.com');
    final String? userPhoto = authProvider?.userPhotoUrl;

    final bool isAdmin = authProvider != null && (authProvider.role == UserRole.admin || userEmail.toLowerCase() == 'iam@edukkit.com');
    final bool isTeacher = authProvider != null && authProvider.role == UserRole.teacher;

    // Determine status badge text
    String statusBadgeText;
    if (isGuest) {
      statusBadgeText = 'Guest User';
    } else if (isAdmin) {
      statusBadgeText = 'Admin';
    } else if (isTeacher) {
      statusBadgeText = 'Teacher';
    } else {
      statusBadgeText = 'Pro Student';
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final double drawerWidth = (screenWidth * 0.82).clamp(280.0, 340.0);

    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        elevation: 16,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. DRAWER HEADER (Profile Photo, Name, Status)
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Profile Avatar
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF1F5F9),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x0E000000),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: userPhoto != null && userPhoto.isNotEmpty
                              ? Image.network(
                                  userPhoto,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => const Icon(
                                    Icons.person_rounded,
                                    size: 30,
                                    color: Color(0xFF475569),
                                  ),
                                )
                              : const Icon(
                                  Icons.person_rounded,
                                  size: 30,
                                  color: Color(0xFF475569),
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1976FF).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                statusBadgeText,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1976FF),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. DRAWER MENU ITEMS LIST
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  children: [
                    // 1. Home
                    _DrawerTile(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      isSelected: activeRoute == '/home',
                      onTap: () => Navigator.pop(context),
                    ),

                    // 2. My Courses
                    _DrawerTile(
                      icon: Icons.menu_book_rounded,
                      label: 'My Courses',
                      isSelected: activeRoute == '/courses',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MyLearningScreen()),
                        );
                      },
                    ),

                    // 3. Certificates
                    _DrawerTile(
                      icon: Icons.workspace_premium_rounded,
                      label: 'Certificates',
                      isSelected: activeRoute == '/certificates',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CertificatesScreen()),
                        );
                      },
                    ),

                    // 4. Downloads
                    _DrawerTile(
                      icon: Icons.download_for_offline_rounded,
                      label: 'Downloads',
                      isSelected: activeRoute == '/downloads',
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Offline resources ready")),
                        );
                      },
                    ),

                    // 5. Store
                    _DrawerTile(
                      icon: Icons.storefront_rounded,
                      label: 'Store',
                      isSelected: activeRoute == '/store',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StoreScreen()),
                        );
                      },
                    ),

                    // 6. Robotics Lab
                    _DrawerTile(
                      icon: Icons.precision_manufacturing_rounded,
                      label: 'Robotics Lab',
                      isSelected: activeRoute == '/robotics-lab',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DiyKitsScreen()),
                        );
                      },
                    ),

                    // 7. Wishlist
                    _DrawerTile(
                      icon: Icons.favorite_rounded,
                      label: 'Wishlist',
                      isSelected: activeRoute == '/wishlist',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StoreScreen()),
                        );
                      },
                    ),

                    // 8. My Orders
                    _DrawerTile(
                      icon: Icons.shopping_bag_rounded,
                      label: 'My Orders',
                      isSelected: activeRoute == '/orders',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StoreScreen()),
                        );
                      },
                    ),

                    // Admin & Teacher Dashboards (if applicable)
                    if (isAdmin)
                      _DrawerTile(
                        icon: Icons.admin_panel_settings_rounded,
                        label: 'Admin Dashboard',
                        isSelected: activeRoute == '/admin',
                        iconColor: const Color(0xFFE53935),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                          );
                        },
                      ),

                    if (isTeacher)
                      _DrawerTile(
                        icon: Icons.assignment_ind_rounded,
                        label: 'Teacher Dashboard',
                        isSelected: activeRoute == '/teacher',
                        iconColor: const Color(0xFF43A047),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TeacherDashboardScreen()),
                          );
                        },
                      ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: Color(0xFFF1F5F9), height: 1),
                    ),

                    // 9. Settings
                    _DrawerTile(
                      icon: Icons.settings_rounded,
                      label: 'Settings',
                      isSelected: activeRoute == '/settings',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsScreen()),
                        );
                      },
                    ),

                    // 10. Help & Support
                    _DrawerTile(
                      icon: Icons.help_outline_rounded,
                      label: 'Help & Support',
                      isSelected: activeRoute == '/support',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
                        );
                      },
                    ),

                    // 11. About Edukkit
                    _DrawerTile(
                      icon: Icons.info_outline_rounded,
                      label: 'About Edukkit',
                      isSelected: activeRoute == '/about',
                      onTap: () {
                        Navigator.pop(context);
                        showAboutDialog(
                          context: context,
                          applicationName: 'Edukkit',
                          applicationVersion: '1.0.0',
                          applicationLegalese: '© 2026 Edukkit Inc. All rights reserved.',
                        );
                      },
                    ),
                  ],
                ),
              ),

              // 3. BOTTOM SECTION (Login/Sign Up if guest, Logout if logged in)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
                  ),
                ),
                child: _DrawerTile(
                  icon: isGuest ? Icons.login_rounded : Icons.logout_rounded,
                  label: isGuest ? 'Login / Sign Up' : 'Logout',
                  isDestructive: !isGuest,
                  iconColor: isGuest ? const Color(0xFF1976FF) : const Color(0xFFEF4444),
                  onTap: () async {
                    Navigator.pop(context);
                    if (isGuest) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    } else {
                      await authProvider?.logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final bool isSelected;
  final bool isDestructive;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.label,
    this.iconColor,
    this.isSelected = false,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color itemColor = isDestructive
        ? const Color(0xFFEF4444)
        : (isSelected ? const Color(0xFF1976FF) : (iconColor ?? const Color(0xFF334155)));

    final Color bgColor = isSelected
        ? const Color(0xFF1976FF).withValues(alpha: 0.10)
        : Colors.transparent;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 22, color: itemColor),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: itemColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
