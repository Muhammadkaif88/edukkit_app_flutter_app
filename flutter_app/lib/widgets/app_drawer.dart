import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/teacher/teacher_dashboard_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/help/help_support_screen.dart';
import '../screens/certificates/certificates_screen.dart';
import '../screens/learning/my_learning_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isGuest = authProvider.role == UserRole.guest;
    
    // Check if user is superuser
    final userEmail = authProvider.userEmail?.toLowerCase() ?? '';
    final isSuperUser = userEmail == "iam@edukkit.com" || userEmail == "super@edukkit.com";

    final isAdmin = authProvider.role == UserRole.admin || isSuperUser;
    final isTeacher = authProvider.role == UserRole.teacher;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // ── Purple Header ──────────────────────────────────────────
          _buildHeader(context, authProvider),

          // ── Menu Items ─────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (isGuest) ...[
                  _buildTile(
                    context,
                    icon: Icons.login_rounded,
                    label: 'Login / Sign Up',
                    onTap: () {
                      Navigator.pop(context); // close drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                  ),
                ] else ...[
                  _buildTile(
                    context,
                    icon: Icons.person_outline,
                    label: 'Profile',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfileScreen()),
                      );
                    },
                  ),
                  _buildTile(
                    context,
                    icon: Icons.school_outlined,
                    label: 'My Learning',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyLearningScreen()),
                      );
                    },
                  ),
                  _buildTile(
                    context,
                    icon: Icons.workspace_premium_outlined,
                    label: 'Certificates',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const CertificatesScreen()),
                      );
                    },
                  ),
                  if (isTeacher)
                    _buildTile(
                      context,
                      icon: Icons.admin_panel_settings_outlined,
                      label: 'Teacher Dashboard',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const TeacherDashboardScreen()),
                        );
                      },
                    ),
                  if (isAdmin)
                    _buildTile(
                      context,
                      icon: Icons.security,
                      label: 'Admin Dashboard',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AdminDashboardScreen()),
                        );
                      },
                    ),
                ],
                _buildTile(
                  context,
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
                _buildTile(
                  context,
                  icon: Icons.help_outline_rounded,
                  label: 'Help & Support',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HelpSupportScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          // ── Logout Button (only when logged in) ────────────────────
          if (!isGuest) ...[
            const Divider(height: 1),
            _buildTile(
              context,
              icon: Icons.logout_rounded,
              label: 'Logout',
              iconColor: Colors.redAccent,
              labelColor: Colors.redAccent,
              onTap: () async {
                Navigator.pop(context);
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthProvider authProvider) {
    final isGuest = authProvider.role == UserRole.guest;

    return GestureDetector(
      onTap: !isGuest
          ? () {
              Navigator.pop(context); // close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProfileScreen()),
              );
            }
          : null,
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 24, left: 24, right: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF4A40DF),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Avatar
              CircleAvatar(
                radius: 34,
                backgroundColor: Colors.white,
                backgroundImage: authProvider.userPhotoUrl != null
                    ? NetworkImage(authProvider.userPhotoUrl!)
                    : null,
                child: authProvider.userPhotoUrl == null
                    ? const Icon(Icons.person,
                        color: Color(0xFF4A40DF), size: 40)
                    : null,
              ),
              const SizedBox(height: 16),
              // Name
              Text(
                authProvider.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              // Subtitle
              if (isGuest)
                const Text(
                  'Sign in to access more features',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                )
              else if (authProvider.role == UserRole.admin || authProvider.role == UserRole.teacher)
                Text(
                  '${authProvider.role.name.toUpperCase()} ACCOUNT',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ],
      ), // closes Row
      ), // closes Container
    ); // closes GestureDetector
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? labelColor,
  }) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(
        icon,
        color: iconColor ?? const Color(0xFF2D2D2D),
        size: 26,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: labelColor ?? const Color(0xFF2D2D2D),
        ),
      ),
      onTap: onTap,
    );
  }
}
