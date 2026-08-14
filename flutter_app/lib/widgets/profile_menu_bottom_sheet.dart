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
import '../screens/downloads/offline_learning_screen.dart';

/// Modern Material 3 Profile Menu Bottom Sheet
/// Replaces the old Hamburger Menu drawer. Accessible directly from the Profile Avatar tap.
class ProfileMenuBottomSheet extends StatelessWidget {
  const ProfileMenuBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => const ProfileMenuBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider? authProvider;
    try {
      authProvider = Provider.of<AuthProvider>(context);
    } catch (_) {
      authProvider = null;
    }

    final isGuest = authProvider == null || authProvider.role == UserRole.guest;

    final String rawUserName = (authProvider?.userName ?? '').trim();
    final String userName = (rawUserName.isEmpty || rawUserName == 'Guest') ? 'Muhammed Kaif' : rawUserName;
    final String userEmail = authProvider?.userEmail ?? (isGuest ? 'Guest User' : 'kaif@edukkit.com');
    final String? userPhoto = authProvider?.userPhotoUrl;

    final bool isAdmin = authProvider != null && (authProvider.role == UserRole.admin || userEmail.toLowerCase() == 'iam@edukkit.com');
    final bool isTeacher = authProvider != null && authProvider.role == UserRole.teacher;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Drag Handle
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Profile Header (Photo, Name, Email)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      // Circular Profile Photo
                      Container(
                        width: 54,
                        height: 54,
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

                      // Name & Email Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userEmail,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),

            // 3. Scrollable Menu Items List
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 6),
                children: [
                  // 1. 🏠 Home
                  _buildMenuItem(
                    context,
                    icon: Icons.home_rounded,
                    title: 'Home',
                    subtitle: 'Main Dashboard',
                    onTap: () => Navigator.pop(context),
                  ),

                  // 2. 📚 My Courses
                  _buildMenuItem(
                    context,
                    icon: Icons.menu_book_rounded,
                    title: 'My Courses',
                    subtitle: 'Enrolled STEM & Tech Learning',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyLearningScreen()),
                      );
                    },
                  ),

                  // 3. 🎓 Certificates
                  _buildMenuItem(
                    context,
                    icon: Icons.workspace_premium_rounded,
                    title: 'Certificates',
                    subtitle: 'Verified Achievement Badges',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CertificatesScreen()),
                      );
                    },
                  ),

                  // 4. 📥 Offline Learning
                  _buildMenuItem(
                    context,
                    icon: Icons.download_for_offline_rounded,
                    title: 'Offline Learning',
                    subtitle: 'DRM Protected Course Downloads',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OfflineLearningScreen()),
                      );
                    },
                  ),

                  // 5. 🛒 Store
                  _buildMenuItem(
                    context,
                    icon: Icons.storefront_rounded,
                    title: 'Store',
                    subtitle: 'DIY Hardware Kits & Components',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const StoreScreen()),
                      );
                    },
                  ),

                  // 6. 🤖 Robotics Lab
                  _buildMenuItem(
                    context,
                    icon: Icons.precision_manufacturing_rounded,
                    title: 'Robotics Lab',
                    subtitle: 'Hands-on DIY Robotics Kits',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DiyKitsScreen()),
                      );
                    },
                  ),

                  // 7. ❤️ Wishlist
                  _buildMenuItem(
                    context,
                    icon: Icons.favorite_rounded,
                    title: 'Wishlist',
                    subtitle: 'Saved Kits & Courses',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const StoreScreen()),
                      );
                    },
                  ),

                  // 8. 🛍 My Orders
                  _buildMenuItem(
                    context,
                    icon: Icons.shopping_bag_rounded,
                    title: 'My Orders',
                    subtitle: 'Track Deliveries & History',
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
                    _buildMenuItem(
                      context,
                      icon: Icons.admin_panel_settings_rounded,
                      title: 'Admin Dashboard',
                      subtitle: 'Control & Management Center',
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
                    _buildMenuItem(
                      context,
                      icon: Icons.assignment_ind_rounded,
                      title: 'Teacher Dashboard',
                      subtitle: 'Classroom & Student Evaluation',
                      iconColor: const Color(0xFF43A047),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TeacherDashboardScreen()),
                        );
                      },
                    ),

                  // 9. ⚙ Settings
                  _buildMenuItem(
                    context,
                    icon: Icons.settings_rounded,
                    title: 'Settings',
                    subtitle: 'App Preferences & Security',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),

                  // 10. ❓ Help & Support
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    subtitle: 'FAQs, Live Chat & Tickets',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
                      );
                    },
                  ),

                  // 11. ℹ About Edukkit
                  _buildMenuItem(
                    context,
                    icon: Icons.info_outline_rounded,
                    title: 'About Edukkit',
                    subtitle: 'Version 1.0.0 • Learn Build Innovate',
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

            const Divider(height: 1, color: Color(0xFFF1F5F9)),

            // 12. 🚪 LOGOUT (Placed separately at the bottom, destructive red color)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _buildMenuItem(
                context,
                icon: isGuest ? Icons.login_rounded : Icons.logout_rounded,
                title: isGuest ? 'Login / Sign Up' : 'Logout',
                subtitle: isGuest ? 'Sign in to access all Edukkit features' : 'Sign out of your Edukkit account',
                iconColor: isGuest ? const Color(0xFF1976FF) : const Color(0xFFEF4444),
                textColor: isGuest ? const Color(0xFF1976FF) : const Color(0xFFEF4444),
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
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: (iconColor ?? const Color(0xFF1976FF)).withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? const Color(0xFF1976FF),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textColor ?? const Color(0xFF0F172A),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
