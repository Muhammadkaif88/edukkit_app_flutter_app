import 'package:flutter/material.dart';
import '../../services/cloudflare_service.dart';
import 'manage_courses_screen.dart';
import 'manage_kits_screen.dart';
import 'manage_banners_screen.dart';

// ignore_for_file: prefer_const_constructors

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final CloudflareService _api = CloudflareService();
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    final users = await _api.getUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  Future<void> _changeUserRole(String id, String newRole) async {
    final success = await _api.updateUserRole(id, newRole);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Role updated successfully to $newRole")),
      );
      _fetchUsers(); // Refresh list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update role")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF5D3AC8),
          title: const Text(
            "Admin Dashboard",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(icon: Icon(Icons.people_outline, color: Colors.white), text: "Users"),
              Tab(icon: Icon(Icons.dashboard_customize_outlined, color: Colors.white), text: "Management"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUserManagement(),
            _buildAdminCenter(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserManagement() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF5D3AC8)));
    }

    if (_users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text("No users found.", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        final role = user['role']?.toString().toLowerCase() ?? 'student';
        
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: _getRoleColor(role).withValues(alpha: 0.1),
              backgroundImage: user['photo_url'] != null ? NetworkImage(user['photo_url']) : null,
              child: user['photo_url'] == null 
                ? Icon(Icons.person, color: _getRoleColor(role)) 
                : null,
            ),
            title: Text(
              user['name'] ?? 'Unknown User', 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['email'] ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getRoleColor(role).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      role.toUpperCase(), 
                      style: TextStyle(
                        color: _getRoleColor(role), 
                        fontSize: 10, 
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      )
                    ),
                  ),
                ],
              ),
            ),
            trailing: PopupMenuButton<String>(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (newRole) => _changeUserRole(user['id'], newRole),
              itemBuilder: (context) => [
                _buildPopupItem('student', 'Student', Icons.school_outlined, Colors.blue),
                _buildPopupItem('teacher', 'Teacher', Icons.assignment_ind_outlined, Colors.green),
                _buildPopupItem('admin', 'Admin', Icons.security_outlined, Colors.red),
              ],
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.more_vert, size: 20),
              ),
            ),
          ),
        );
      },
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, String label, IconData icon, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'admin':
        return const Color(0xFFE53935);
      case 'teacher':
        return const Color(0xFF43A047);
      default:
        return const Color(0xFF1E88E5);
    }
  }

  Widget _buildAdminCenter() {
    return GridView.count(
      padding: const EdgeInsets.all(20),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildAdminTile(
          context,
          title: "Manage Courses",
          subtitle: "Add or edit content",
          icon: Icons.book_outlined,
          color: const Color(0xFF6C63FF),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageCoursesScreen())),
        ),
        _buildAdminTile(
          context,
          title: "DIY Kits",
          subtitle: "Store inventory",
          icon: Icons.shopping_bag_outlined,
          color: const Color(0xFFFF6B6B),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageKitsScreen())),
        ),
        _buildAdminTile(
          context,
          title: "Banners",
          subtitle: "Home promotions",
          icon: Icons.view_carousel_outlined,
          color: const Color(0xFF4ECDC4),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageBannersScreen())),
        ),
        _buildAdminTile(
          context,
          title: "Orders",
          subtitle: "Sales & delivery",
          icon: Icons.local_shipping_outlined,
          color: const Color(0xFFF9D423),
          onTap: () {},
        ),
        _buildAdminTile(
          context,
          title: "Analytics",
          subtitle: "Platform growth",
          icon: Icons.analytics_outlined,
          color: const Color(0xFFA061D1),
          onTap: () {},
        ),
        _buildAdminTile(
          context,
          title: "Support",
          subtitle: "User inquiries",
          icon: Icons.support_agent_outlined,
          color: const Color(0xFFFF8C42),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildAdminTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
