import 'package:flutter/material.dart';
import '../features/home/presentation/screens/home_screen.dart';
import 'learning/my_learning_screen.dart';
import 'courses/tech_courses_tab.dart';
import 'school/school_screen.dart';
import 'store/store_screen.dart';
import '../shared/widgets/widgets.dart';

/// Root Navigation Shell for Edukkit
/// Manages tab switching across 5 main destinations:
/// 0: Home (HomeScreen)
/// 1: Courses (MyLearningScreen)
/// 2: Tech (TechCoursesTab)
/// 3: School (SchoolScreen)
/// 4: Store (StoreScreen)
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomeScreen(),
    MyLearningScreen(),
    TechCoursesTab(),
    SchoolScreen(),
    StoreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: EdukkitBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
