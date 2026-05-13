import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../services/cloudflare_service.dart';
import '../../widgets/app_drawer.dart';
import '../chatbot/chatbot_screen.dart';
import '../courses/course_detail_screen.dart';
import '../store/store_screen.dart';
import 'search_screen.dart';
import '../notifications/notification_screen.dart';
import '../courses/my_courses_tab.dart';
import '../courses/tech_courses_tab.dart';
import '../courses/robotics_courses_screen.dart';
import '../courses/iot_courses_screen.dart';
import '../courses/electronics_courses_screen.dart';
import '../courses/diy_kits_courses_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 10000);
  Timer? _timer;
    Offset? _fabPosition;
  List<Map<String, dynamic>> _bannersData = [];
  bool _isLoadingBanners = true;
// removed _isSearching and _searchController

  final List<Map<String, dynamic>> _banners = [
    {
      "color": const Color(0xFF67C275),
      "title": "Home Automation Kit",
      "subtitle": "Smartify your living space.",
      "buttonText": "View Details",
      "icon": Icons.wifi,
    },
    {
      "color": const Color(0xFFFCAE3D),
      "title": "Solar Emergency Kit",
      "subtitle": "Build your own sustainable light source.",
      "buttonText": "View Kit",
      "icon": Icons.lightbulb_outline,
    },
    {
      "color": const Color(0xFFD63EEB),
      "title": "VR Classes for Schools",
      "subtitle": "Immerse in virtual learning.",
      "buttonText": "Join Free Class",
      "icon": Icons.headset_mic_outlined,
    },
    {
      "color": const Color(0xFF33B5E5),
      "title": "Robotics Online Course",
      "subtitle": "Includes full hands-on kit.",
      "buttonText": "Enroll",
      "icon": Icons.precision_manufacturing,
    },
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHomeData();
    });
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _fetchHomeData() async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final cloudflareService = CloudflareService();
    
    // Fetch courses via provider
    courseProvider.fetchCourses();
    
    // Fetch banners locally
    try {
      final banners = await cloudflareService.getBanners();
      if (mounted) {
        setState(() {
          _bannersData = List<Map<String, dynamic>>.from(banners);
          _isLoadingBanners = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching banners: $e");
      if (mounted) {
        setState(() => _isLoadingBanners = false);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // Use a safer, percentage-based default position to ensure it's visible on all devices
    _fabPosition ??= Offset(screenSize.width - 80, screenSize.height * 0.6);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            // Using Positioned.fill to ensure IndexedStack takes full screen and prevents white-screen issues
            Positioned.fill(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildHomeContent(screenSize),
                  const MyCoursesTab(),
                  const TechCoursesTab(),
                  _buildSchoolContent(),
                ],
              ),
            ),
            _buildChatbotFAB(screenSize),
          ],
          clipBehavior: Clip.none, // Allow FAB to be visible even if it slightly overlaps edges
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StoreScreen()),
            );
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        height: 65,
        indicatorColor: const Color(0xFF5D3AC8).withValues(alpha: 0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF5D3AC8)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school, color: Color(0xFF5D3AC8)),
            label: 'Courses',
          ),
          NavigationDestination(
            icon: Icon(Icons.computer_outlined),
            selectedIcon: Icon(Icons.computer, color: Color(0xFF5D3AC8)),
            label: 'Tech',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: Color(0xFF5D3AC8)),
            label: 'School',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag, color: Color(0xFF5D3AC8)),
            label: 'Store',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(Size screenSize) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildScrollingBanners(),
          const SizedBox(height: 24),
          _buildCategories(),
          const SizedBox(height: 32),
          _buildSectionTitle("Explore Our Courses", ""),
          const SizedBox(height: 16),
          _buildCategorySection(
            context,
            title: "Robotics Course",
            subtitle: "Build sensors & mechanical parts",
            icon: Icons.precision_manufacturing,
            imageUrl: "assets/images/robotics_category.png",
            color: const Color(0xFF6C63FF),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoboticsCoursesScreen())),
          ),
          const SizedBox(height: 16),
          _buildCategorySection(
            context,
            title: "DIY Kits",
            subtitle: "Hands-on engineering projects",
            icon: Icons.build_outlined,
            imageUrl: "assets/images/diy_kits_category.png",
            color: const Color(0xFFFF6B6B),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiyKitsCoursesScreen())),
          ),
          const SizedBox(height: 16),
          _buildCategorySection(
            context,
            title: "AI + IOT Courses",
            subtitle: "Smart logic & cloud integration",
            icon: Icons.wifi,
            imageUrl: "assets/images/iot_category.png",
            color: const Color(0xFF4ECDC4),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IotCoursesScreen())),
          ),
          const SizedBox(height: 16),
          _buildCategorySection(
            context,
            title: "Electronics Courses",
            subtitle: "Master circuits & PCB design",
            icon: Icons.electrical_services_outlined,
            imageUrl: "assets/images/electronics_category.png",
            color: const Color(0xFFF9D423),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ElectronicsCoursesScreen())),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSchoolContent() {
    return Stack(
      children: [
        // The Background Content
        SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "🎓 Edukkit School Tech Courses Structure",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 24),
              
              // Subject Highlights
              const Text(
                "Subject Highlights",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              _buildSubjectRow(["Physics", "Maths", "Chemistry"]),
              const SizedBox(height: 10),
              _buildSubjectRow(["Electronics", "Computer", "Language"]),
              
              const SizedBox(height: 32),
              
              // School Education Sectors
              _buildSchoolSectorCard(
                "1st",
                "Primary School",
                "Foundational tech concepts for young minds.",
                const Color(0xFFE3F4FC),
                const Color(0xFF4A90E2),
              ),
              const SizedBox(height: 16),
              _buildSchoolSectorCard(
                "2nd",
                "High School",
                "Advanced robotics and coding logic.",
                const Color(0xFFFFF7E3),
                const Color(0xFFF5A623),
              ),
              const SizedBox(height: 16),
              _buildSchoolSectorCard(
                "3rd",
                "Higher Secondary",
                "Specialized IoT, AI, and Electronics engineering.",
                const Color(0xFFE3FCEF),
                const Color(0xFF00BFA5),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
        
        // The Blur Overlay
        Positioned.fill(
          child: ClipRRect(
            child: BackdropFilter(
              filter: ColorFilter.mode(
                Colors.white.withValues(alpha: 0.2),
                BlendMode.srcOver,
              ),
              child: Container(
                color: Colors.white.withValues(alpha: 0.4),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5D3AC8).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5D3AC8).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Text(
                      "COMING SOON",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectRow(List<String> subjects) {
    return Row(
      children: subjects.map((subject) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEEEEEE)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              subject,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5D3AC8),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSchoolSectorCard(String rank, String title, String description, Color bgColor, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                rank,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6E6E6E),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black26),
        ],
      ),
    );
  }

  Widget _buildChatbotFAB(Size screenSize) {
    return Positioned(
      left: _fabPosition!.dx,
      top: _fabPosition!.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _fabPosition = Offset(
              (_fabPosition!.dx + details.delta.dx).clamp(0.0, screenSize.width - 60),
              (_fabPosition!.dy + details.delta.dy).clamp(0.0, screenSize.height * 0.8), // Safer clamp for mobile
            );
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Rotating Gradient Border
            RotationTransition(
              turns: _rotationController,
              child: Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Color(0xFF4285F4), // Blue
                      Color(0xFF9B51E0), // Purple
                      Color(0xFFE91E63), // Pink
                      Color(0xFFF2994A), // Orange
                      Color(0xFF4285F4), // Blue (to close loop)
                    ],
                  ),
                ),
              ),
            ),
            // Main Button Content
            Container(
              width: 57,
              height: 57,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8), // Old model white transparent
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.85,
                              child: const ChatbotScreen(),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.auto_awesome, color: Color(0xFF5D3AC8), size: 28),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final authProvider = Provider.of<AuthProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: authProvider.userPhotoUrl != null
                    ? NetworkImage(authProvider.userPhotoUrl!)
                    : null,
                child: authProvider.userPhotoUrl == null
                    ? const Icon(Icons.person, color: Colors.white, size: 30)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Hello,",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    authProvider.userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.search, size: 28, color: Color(0xFF5D3AC8)),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const SearchScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOutQuart;
                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      return SlideTransition(position: animation.drive(tween), child: child);
                    },
                  ),
                );
              },
            ),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none, size: 28, color: Color(0xFF5D3AC8)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationScreen()),
                    );
                  },
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScrollingBanners() {
    if (_isLoadingBanners) {
      return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()));
    }
    
    final bannersToShow = _bannersData.isNotEmpty ? _bannersData : _banners;

    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _pageController,
        itemBuilder: (context, index) {
          final banner = bannersToShow[index % bannersToShow.length];
          return _buildSingleBanner(
            color: banner["color"] is Color 
                ? banner["color"] 
                : Color(int.parse(banner["bg_color"] ?? "0xFF5D3AC8")),
            title: banner["title"],
            subtitle: banner["subtitle"],
            buttonText: banner["buttonText"] ?? banner["button_text"] ?? "Start",
            icon: banner["icon"] ?? Icons.star,
            imageUrl: banner["image_url"],
          );
        },
      ),
    );
  }

  Widget _buildSingleBanner({
    required Color color,
    required String title,
    required String subtitle,
    required String buttonText,
    required IconData icon,
    String? imageUrl,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(buttonText, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white24,
              ),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? ClipOval(child: Image.network(imageUrl, fit: BoxFit.cover))
                  : Icon(icon, color: Colors.white, size: 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {
        "title": "School\nCourse",
        "icon": Icons.school,
        "color": const Color(0xFF4A90E2),
        "onTap": () => setState(() => _selectedIndex = 3),
      },
      {
        "title": "Robotics",
        "icon": Icons.precision_manufacturing,
        "color": const Color(0xFFF5A623),
        "onTap": () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoboticsCoursesScreen())),
      },
      {
        "title": "IoT",
        "icon": Icons.wifi,
        "color": const Color(0xFF9013FE),
        "onTap": () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IotCoursesScreen())),
      },
      {
        "title": "3D Print",
        "icon": Icons.print,
        "color": const Color(0xFF00BFA5),
        "onTap": () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ElectronicsCoursesScreen())), // Placeholder for 3D Print
      },
      {
        "title": "DIY Kits",
        "icon": Icons.build,
        "color": const Color(0xFFD0021B),
        "onTap": () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiyKitsCoursesScreen())),
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories.map((cat) {
        return Expanded(
          child: GestureDetector(
            onTap: cat["onTap"] as VoidCallback,
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (cat["color"] as Color).withValues(alpha: 0.1),
                    border: Border.all(color: (cat["color"] as Color).withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Icon(
                    cat["icon"] as IconData,
                    color: cat["color"] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cat["title"] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    String? imageUrl,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative background circles
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "View Courses",
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                            ),
                          ),
                          if (imageUrl != null && imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset(
                                imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  icon,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          else
                            Icon(
                              icon,
                              size: 48,
                              color: Colors.white,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard({
    required String title,
    required String subtitle,
    required String buttonText,
    required Color buttonColor,
    required Color backgroundColor,
    required String progressText,
    required bool isLocked,
    String? thumbnailUrl,
    VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 140),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6E6E6E),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: onTap ?? () {},
                        icon: isLocked ? const Icon(Icons.lock_outline, size: 16) : const SizedBox.shrink(),
                        label: Text(buttonText, style: const TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isLocked ? 12 : 20,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
                        ? Image.network(thumbnailUrl, fit: BoxFit.cover)
                        : const Icon(Icons.image, size: 80, color: Colors.black12),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2459),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                progressText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            action,
            style: const TextStyle(
              color: Color(0xFF5D3AC8),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
  Color _getCourseColor(String category) {
    switch (category.toLowerCase()) {
      case 'robotics':
        return const Color(0xFFE3F4FC);
      case 'iot':
        return const Color(0xFFE3FCEF);
      case 'electronics':
        return const Color(0xFFEFE8FF);
      default:
        return const Color(0xFFFFF7E3);
    }
  }
}
