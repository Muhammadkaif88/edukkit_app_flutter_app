import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // App Settings state
  bool _darkMode = false;
  String _selectedLanguage = 'English';
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  double _fontSize = 1.0; // 0.8 small, 1.0 medium, 1.2 large

  final List<String> _languages = [
    'English',
    'Malayalam',
    'Hindi',
    'Tamil',
    'Arabic',
  ];

  String get _fontSizeLabel {
    if (_fontSize <= 0.8) return 'Small';
    if (_fontSize >= 1.2) return 'Large';
    return 'Medium';
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isGuest = auth.role == UserRole.guest;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A40DF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // ── App Settings ────────────────────────────────────────────
          _buildSectionHeader(Icons.tune_rounded, 'App Settings'),
          const SizedBox(height: 8),
          _buildCard(children: [
            // Dark Mode
            _buildSwitchTile(
              icon: Icons.dark_mode_outlined,
              iconBg: const Color(0xFF3D3D9F),
              title: 'Dark Mode',
              subtitle: _darkMode ? 'Dark theme enabled' : 'Light theme enabled',
              value: _darkMode,
              onChanged: (v) {
                setState(() => _darkMode = v);
                _showComingSoon('Dark mode');
              },
            ),
            _buildDivider(),
            // Language
            _buildNavigateTile(
              icon: Icons.language_outlined,
              iconBg: const Color(0xFF2E7D32),
              title: 'Language',
              subtitle: _selectedLanguage,
              onTap: () => _showLanguagePicker(),
            ),
            _buildDivider(),
            // Notifications
            _buildSwitchTile(
              icon: Icons.notifications_outlined,
              iconBg: const Color(0xFFE65100),
              title: 'Notifications',
              subtitle: _notificationsEnabled ? 'All notifications on' : 'All notifications off',
              value: _notificationsEnabled,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
            ),
            if (_notificationsEnabled) ...[
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.mail_outline,
                iconBg: const Color(0xFF0277BD),
                title: 'Email Notifications',
                subtitle: 'Course updates & offers',
                value: _emailNotifications,
                onChanged: (v) => setState(() => _emailNotifications = v),
                indent: true,
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.phone_android_outlined,
                iconBg: const Color(0xFF6A1B9A),
                title: 'Push Notifications',
                subtitle: 'Live alerts on device',
                value: _pushNotifications,
                onChanged: (v) => setState(() => _pushNotifications = v),
                indent: true,
              ),
            ],
            _buildDivider(),
            // Font Size
            _buildFontSizeTile(),
          ]),

          const SizedBox(height: 24),

          // ── Privacy & Security ──────────────────────────────────────
          _buildSectionHeader(Icons.security_outlined, 'Privacy & Security'),
          const SizedBox(height: 8),
          _buildCard(children: [
            // Change password (only for email users)
            if (!isGuest)
              _buildNavigateTile(
                icon: Icons.lock_outline,
                iconBg: const Color(0xFFC62828),
                title: 'Change Password',
                subtitle: 'Update your account password',
                onTap: () => _showChangePasswordSheet(context),
              ),
            if (!isGuest) _buildDivider(),
            // Google linked account
            _buildNavigateTile(
              icon: Icons.g_mobiledata,
              iconBg: const Color(0xFF1565C0),
              title: 'Google Account',
              subtitle: isGuest ? 'Not linked' : 'Linked to your account',
              trailing: isGuest
                  ? _buildBadge('Link', const Color(0xFF4A40DF))
                  : _buildBadge('Linked', const Color(0xFF2E7D32)),
              onTap: () => _showComingSoon('Google account linking'),
            ),
            _buildDivider(),
            // Logout
            _buildNavigateTile(
              icon: Icons.logout_rounded,
              iconBg: const Color(0xFFB71C1C),
              title: isGuest ? 'Login / Sign Up' : 'Logout',
              subtitle: isGuest
                  ? 'Sign in to access all features'
                  : 'Sign out from this device',
              titleColor: Colors.redAccent,
              onTap: () => isGuest
                  ? Navigator.pop(context)
                  : _showLogoutDialog(context, auth),
              showArrow: false,
            ),
          ]),

          const SizedBox(height: 24),

          // ── App Info ────────────────────────────────────────────────
          _buildSectionHeader(Icons.info_outline_rounded, 'App Info'),
          const SizedBox(height: 8),
          _buildCard(children: [
            _buildNavigateTile(
              icon: Icons.verified_outlined,
              iconBg: const Color(0xFF00695C),
              title: 'Version',
              subtitle: 'v1.0.0 (Build 1)',
              showArrow: false,
            ),
            _buildDivider(),
            _buildNavigateTile(
              icon: Icons.info_outline,
              iconBg: const Color(0xFF4527A0),
              title: 'About Edukkit',
              subtitle: 'Learn about our mission',
              onTap: () => _showAboutSheet(context),
            ),
            _buildDivider(),
            _buildNavigateTile(
              icon: Icons.article_outlined,
              iconBg: const Color(0xFF37474F),
              title: 'Terms & Conditions',
              subtitle: 'Read our usage terms',
              onTap: () => _showComingSoon('Terms & Conditions'),
            ),
            _buildDivider(),
            _buildNavigateTile(
              icon: Icons.privacy_tip_outlined,
              iconBg: const Color(0xFF1B5E20),
              title: 'Privacy Policy',
              subtitle: 'How we handle your data',
              onTap: () => _showComingSoon('Privacy Policy'),
            ),
          ]),

          const SizedBox(height: 32),

          // Footer
          Center(
            child: Text(
              'Edukkit © 2024 · Made with ❤️ in Kerala',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Section Header ─────────────────────────────────────────────────
  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4A40DF), size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A40DF),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ── Card Container ─────────────────────────────────────────────────
  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // ── Switch Tile ────────────────────────────────────────────────────
  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool indent = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: indent ? 32 : 16,
        right: 12,
        top: 12,
        bottom: 12,
      ),
      child: Row(
        children: [
          _buildIconBox(icon, iconBg, small: indent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: indent ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF4A40DF),
          ),
        ],
      ),
    );
  }

  // ── Navigate Tile ──────────────────────────────────────────────────
  Widget _buildNavigateTile({
    required IconData icon,
    required Color iconBg,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color? titleColor,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _buildIconBox(icon, iconBg),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? const Color(0xFF2D2D2D),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                (showArrow
                    ? Icon(Icons.chevron_right,
                        color: Colors.grey.shade400, size: 22)
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  // ── Font Size Tile ─────────────────────────────────────────────────
  Widget _buildFontSizeTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildIconBox(Icons.text_fields_rounded, const Color(0xFF4527A0)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Font Size',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    Text(
                      _fontSizeLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 54),
              const Text('A', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF4A40DF),
                    thumbColor: const Color(0xFF4A40DF),
                    inactiveTrackColor: const Color(0xFFD0CEFF),
                    overlayColor: const Color(0x334A40DF),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: _fontSize,
                    min: 0.8,
                    max: 1.2,
                    divisions: 2,
                    onChanged: (v) => setState(() => _fontSize = v),
                  ),
                ),
              ),
              const Text('A',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Icon Box ───────────────────────────────────────────────────────
  Widget _buildIconBox(IconData icon, Color bg, {bool small = false}) {
    final size = small ? 34.0 : 40.0;
    final iconSize = small ? 18.0 : 22.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white, size: iconSize),
    );
  }

  Widget _buildDivider() =>
      const Divider(height: 1, indent: 70, endIndent: 16);

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ── Language Picker ────────────────────────────────────────────────
  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Choose Language',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._languages.map(
                (lang) => ListTile(
                  leading: Icon(
                    _selectedLanguage == lang
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: const Color(0xFF4A40DF),
                  ),
                  title: Text(lang),
                  onTap: () {
                    setState(() => _selectedLanguage = lang);
                    Navigator.pop(ctx);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Change Password Sheet ──────────────────────────────────────────
  void _showChangePasswordSheet(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 20),
              const Text(
                'Change Password',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                controller: currentCtrl,
                label: 'Current Password',
                obscure: obscureCurrent,
                onToggle: () =>
                    setSheetState(() => obscureCurrent = !obscureCurrent),
              ),
              const SizedBox(height: 14),
              _buildPasswordField(
                controller: newCtrl,
                label: 'New Password',
                obscure: obscureNew,
                onToggle: () =>
                    setSheetState(() => obscureNew = !obscureNew),
              ),
              const SizedBox(height: 14),
              _buildPasswordField(
                controller: confirmCtrl,
                label: 'Confirm New Password',
                obscure: obscureNew,
                onToggle: () =>
                    setSheetState(() => obscureNew = !obscureNew),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showComingSoon('Change Password');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A40DF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Update Password',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF6F7FB),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF4A40DF), width: 1.5),
        ),
      ),
    );
  }

  // ── Logout Confirm Dialog ──────────────────────────────────────────
  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content:
            const Text('Are you sure you want to sign out from Edukkit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // close dialog
              await auth.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Logout',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── About Sheet ────────────────────────────────────────────────────
  void _showAboutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A40DF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.school,
                    color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'Edukkit',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Empowering the next generation of innovators through hands-on robotics, IoT, and STEM education.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey.shade600, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildInfoChip(Icons.location_on_outlined, 'Kerala, India'),
                  const SizedBox(width: 12),
                  _buildInfoChip(Icons.verified_outlined, 'v1.0.0'),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEBFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF4A40DF), size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF4A40DF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: const Color(0xFF4A40DF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
