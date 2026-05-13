import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class StoreProfileTab extends StatelessWidget {
  const StoreProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A40DF),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
        title: const Text('Store Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          // Profile header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5B52F0), Color(0xFF3B30C8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  backgroundImage: auth.userPhotoUrl != null
                      ? NetworkImage(auth.userPhotoUrl!)
                      : null,
                  child: auth.userPhotoUrl == null
                      ? const Icon(Icons.person, color: Colors.white, size: 40)
                      : null,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(auth.userName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(auth.userName == 'Guest' ? 'Guest Account' : '${auth.userName.toLowerCase()}@edukkit.com',
                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),

          // Stats row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                _stat('4', 'Orders'),
                _dividerV(),
                _stat('₹2,839', 'Spent'),
                _dividerV(),
                _stat('3', 'Wishlist'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Menu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _menuCard(children: [
                  _menuTile(Icons.shopping_bag_outlined, const Color(0xFF4A40DF), 'My Orders', 'Track your orders'),
                  const Divider(height: 1, indent: 56),
                  _menuTile(Icons.location_on_outlined, const Color(0xFF00695C), 'Saved Addresses', 'Manage delivery addresses'),
                  const Divider(height: 1, indent: 56),
                  _menuTile(Icons.favorite_border, const Color(0xFFC62828), 'Wishlist', '3 items saved'),
                  const Divider(height: 1, indent: 56),
                  _menuTile(Icons.local_offer_outlined, const Color(0xFFE65100), 'Coupons', 'View available offers'),
                ]),
                const SizedBox(height: 16),
                _menuCard(children: [
                  _menuTile(Icons.support_agent_outlined, const Color(0xFF0277BD), 'Help & Support', 'Chat or email us'),
                  const Divider(height: 1, indent: 56),
                  _menuTile(Icons.privacy_tip_outlined, const Color(0xFF37474F), 'Privacy Policy', 'Read our policy'),
                ]),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String val, String label) => Expanded(
        child: Column(
          children: [
            Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D2D2D))),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
      );

  Widget _dividerV() => Container(width: 1, height: 36, color: Colors.grey.shade200);

  Widget _menuCard({required List<Widget> children}) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(children: children),
      );

  Widget _menuTile(IconData icon, Color color, String title, String subtitle) =>
      ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
        onTap: () {},
      );
}
