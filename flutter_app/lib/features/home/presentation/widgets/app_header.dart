import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../screens/notifications/notification_screen.dart';
import '../../../../screens/home/search_screen.dart';

/// Module 1 – Production-Ready Responsive Custom Home Header for Edukkit
/// Dynamic Content Support for Logged In and Logged Out States.
/// Layout Logged Out: [ Profile Avatar ] [ Edukkit Logo ] [ Edukkit & Tagline ] [ Search ] [ Notification ]
/// Layout Logged In:  [ Profile Avatar ] [ Greeting & User Name (Full Width) ]   [ Search ] [ Notification ]
/// Responsive across 320dp, 360dp, 390dp, 412dp, 430dp, Tablet.
class HomeHeader extends StatelessWidget {
  final bool? isLoggedIn;
  final String? userName;
  final String? userAvatarUrl;
  final int notificationCount;
  final bool isOnline;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSearchTap;

  const HomeHeader({
    super.key,
    this.isLoggedIn,
    this.userName,
    this.userAvatarUrl,
    this.notificationCount = 3,
    this.isOnline = true,
    this.onNotificationTap,
    this.onProfileTap,
    this.onSearchTap,
  });

  /// Time-based greeting helper matching exact device time rules:
  /// 05:00–11:59 → Good Morning 👋
  /// 12:00–16:59 → Good Afternoon 👋
  /// 17:00–20:59 → Good Evening 👋
  /// 21:00–04:59 → Good Night 👋
  static String getTimeBasedGreeting() {
    final now = DateTime.now();
    final hour = now.hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning 👋';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon 👋';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening 👋';
    } else {
      return 'Good Night 👋';
    }
  }

  void _handleProfileTap(BuildContext context) {
    if (onProfileTap != null) {
      onProfileTap!();
    } else {
      Scaffold.of(context).openDrawer();
    }
  }

  void _handleSearchTap(BuildContext context) {
    if (onSearchTap != null) {
      onSearchTap!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SearchScreen()),
      );
    }
  }

  void _handleNotificationTap(BuildContext context) {
    if (onNotificationTap != null) {
      onNotificationTap!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationScreen()),
      );
    }
  }

  AuthProvider? _getAuthProvider(BuildContext context) {
    try {
      return Provider.of<AuthProvider>(context, listen: true);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = _getAuthProvider(context);

    // Determine login status
    final bool isUserLoggedIn = isLoggedIn ??
        (authProvider != null
            ? authProvider.role != UserRole.guest
            : (userName != null && userName!.isNotEmpty && userName != 'Guest'));

    // Determine dynamic name & avatar
    final String rawUserName = (userName ?? authProvider?.userName ?? '').trim();
    final String displayName = (rawUserName.isEmpty || rawUserName == 'Guest') ? 'Muhammed Kaif' : rawUserName;
    final String? effectiveAvatar = userAvatarUrl ?? authProvider?.userPhotoUrl;
    final String greetingText = getTimeBasedGreeting();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final bool isTablet = screenWidth >= 600;
        final bool isSmallMobile = screenWidth < 360;

        // Responsive Sizing Matrix (44dp container standard)
        final double buttonSize = isTablet ? 48.0 : (isSmallMobile ? 40.0 : 44.0);
        final double iconSize = isTablet ? 22.0 : (isSmallMobile ? 18.0 : 20.0);
        final double logoHeight = isTablet ? 38.0 : (isSmallMobile ? 28.0 : 32.0);
        final double brandFontSize = isTablet ? 18.0 : (isSmallMobile ? 14.0 : 16.0);
        final double taglineFontSize = isTablet ? 11.5 : (isSmallMobile ? 9.5 : 10.5);
        final double greetingFontSize = isTablet ? 13.0 : (isSmallMobile ? 10.5 : 12.0);
        final double userNameFontSize = isTablet ? 18.0 : (isSmallMobile ? 14.0 : 16.0);
        final double spacing = isTablet ? 12.0 : (isSmallMobile ? 6.0 : 8.0);
        final double horizontalPadding = isTablet ? 20.0 : (isSmallMobile ? 12.0 : 16.0);

        return Container(
          color: Colors.transparent,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 10.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. LEFT: Circular Profile Avatar (44dp container)
                  ProfileAvatar(
                    size: buttonSize,
                    avatarUrl: effectiveAvatar,
                    isOnline: isOnline,
                    onTap: () => _handleProfileTap(context),
                  ),

                  SizedBox(width: spacing),

                  // 2. CENTER AREA: Logged Out (Logo + Text) vs Logged In (No Logo, Full Width Greeting & User Name)
                  if (!isUserLoggedIn) ...[
                    // LOGGED OUT STATE: Edukkit Logo + Brand Name & Tagline
                    EdukkitLogoWidget(
                      height: logoHeight,
                    ),

                    SizedBox(width: spacing),

                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Edukkit',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: brandFontSize,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF111827),
                                letterSpacing: -0.4,
                                height: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 1),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Learn • Build • Innovate',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: taglineFontSize,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B7280),
                                height: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // LOGGED IN STATE: Completely removes Logo, Edukkit text, and Tagline!
                    // Replaces entire logo/text area with Greeting & User Name taking up all center space!
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              greetingText, // Good Morning 👋 / Good Afternoon 👋 / Good Evening 👋 / Good Night 👋
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: greetingFontSize,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B7280),
                                height: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              displayName, // e.g. Muhammed Kaif
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: userNameFontSize,
                                fontWeight: FontWeight.w800, // Bold
                                color: const Color(0xFF111827),
                                letterSpacing: -0.3,
                                height: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(width: spacing),

                  // 3. RIGHT: Search Button & Notification Button
                  HeaderCircularButton(
                    size: buttonSize,
                    icon: Icons.search_rounded,
                    iconSize: iconSize,
                    onTap: () => _handleSearchTap(context),
                  ),

                  SizedBox(width: spacing),

                  NotificationButton(
                    size: buttonSize,
                    iconSize: iconSize,
                    notificationCount: notificationCount,
                    onTap: () => _handleNotificationTap(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Reusable AppHeader export alias for backward compatibility across screens
typedef AppHeader = HomeHeader;

/// Modular Component: Edukkit Logo Widget (Maintains aspect ratio)
class EdukkitLogoWidget extends StatelessWidget {
  final double height;

  const EdukkitLogoWidget({
    super.key,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Image.asset(
        'assets/logo/edukkit_logo.png',
        fit: BoxFit.contain,
        height: height,
        filterQuality: FilterQuality.high,
        errorBuilder: (ctx, err, stack) => Image.asset(
          'assets/images/logo/edukkit_logo.png',
          fit: BoxFit.contain,
          height: height,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1976FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Edukkit',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Modular Component: Notification Button (44dp circular container with badge counter)
class NotificationButton extends StatefulWidget {
  final double size;
  final double iconSize;
  final int notificationCount;
  final VoidCallback? onTap;

  const NotificationButton({
    super.key,
    required this.size,
    required this.iconSize,
    required this.notificationCount,
    this.onTap,
  });

  @override
  State<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0E000000), // Premium soft shadow
                  blurRadius: 14,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                onTap: widget.onTap,
                child: Center(
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: widget.iconSize,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),
          ),
          if (widget.notificationCount > 0)
            Positioned(
              top: -2,
              right: -2,
              child: NotificationBadge(
                count: widget.notificationCount,
                buttonSize: widget.size,
              ),
            ),
        ],
      ),
    );
  }
}

/// Reusable Floating Circular White Button with 150ms Scale Animation & InkWell Ripple
class HeaderCircularButton extends StatefulWidget {
  final double size;
  final IconData icon;
  final double iconSize;
  final Color iconColor;
  final VoidCallback? onTap;

  const HeaderCircularButton({
    super.key,
    required this.size,
    required this.icon,
    required this.iconSize,
    this.iconColor = const Color(0xFF1A1A1A),
    this.onTap,
  });

  @override
  State<HeaderCircularButton> createState() => _HeaderCircularButtonState();
}

class _HeaderCircularButtonState extends State<HeaderCircularButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x0E000000),
              blurRadius: 14,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.onTap,
            child: Center(
              child: Icon(
                widget.icon,
                size: widget.iconSize,
                color: widget.iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Modular Component: NotificationBadge
class NotificationBadge extends StatelessWidget {
  final int count;
  final double buttonSize;

  const NotificationBadge({
    super.key,
    required this.count,
    required this.buttonSize,
  });

  @override
  Widget build(BuildContext context) {
    final double badgeSize = buttonSize >= 48 ? 18.0 : 16.0;
    final String displayText = count > 9 ? '9+' : '$count';

    return Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33EF4444),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          displayText,
          style: TextStyle(
            color: Colors.white,
            fontSize: badgeSize * 0.52,
            fontWeight: FontWeight.w800,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

/// Modular Component: ProfileAvatar (44dp circular container on left with online dot)
class ProfileAvatar extends StatefulWidget {
  final double size;
  final String? avatarUrl;
  final bool isOnline;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    required this.size,
    this.avatarUrl,
    this.isOnline = true,
    this.onTap,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double onlineDotSize = widget.size >= 48 ? 12.0 : 10.0;

    return AnimatedScale(
      scale: _isPressed ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0E000000), // Premium soft shadow
                  blurRadius: 14,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                onTap: widget.onTap,
                child: ClipOval(
                  child: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                      ? Image.network(
                          widget.avatarUrl!,
                          width: widget.size,
                          height: widget.size,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Icon(
                            Icons.person_rounded,
                            size: widget.size * 0.55,
                            color: const Color(0xFF1A1A1A),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFF1F5F9),
                          child: Icon(
                            Icons.person_rounded,
                            size: widget.size * 0.55,
                            color: const Color(0xFF475569),
                          ),
                        ),
                ),
              ),
            ),
          ),
          if (widget.isOnline)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: onlineDotSize,
                height: onlineDotSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E), // Green Online Dot
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
