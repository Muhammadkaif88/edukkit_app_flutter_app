import 'package:flutter/material.dart';
import 'dart:async';

// ── Shared Product Catalog ──────────────────────────────────────────
const List<Map<String, dynamic>> kProducts = [
  {'id': 1, 'name': 'Arduino Uno R3', 'price': 450.0, 'category': 'Electronics', 'icon': Icons.developer_board, 'color': 0xFF4A40DF, 'rating': 4.8, 'reviews': 124, 'tag': 'Best Seller'},
  {'id': 2, 'name': 'HC-SR04 Ultrasonic Sensor', 'price': 80.0, 'category': 'Sensors', 'icon': Icons.sensors, 'color': 0xFF00695C, 'rating': 4.5, 'reviews': 89, 'tag': 'Popular'},
  {'id': 3, 'name': 'SG90 Micro Servo Motor', 'price': 120.0, 'category': 'Motors', 'icon': Icons.electric_bolt, 'color': 0xFFE65100, 'rating': 4.7, 'reviews': 67, 'tag': null},
  {'id': 4, 'name': 'L298N Motor Driver', 'price': 150.0, 'category': 'Electronics', 'icon': Icons.memory, 'color': 0xFF6A1B9A, 'rating': 4.6, 'reviews': 45, 'tag': null},
  {'id': 5, 'name': 'ESP32 Wi-Fi Module', 'price': 380.0, 'category': 'Electronics', 'icon': Icons.wifi, 'color': 0xFF0277BD, 'rating': 4.9, 'reviews': 203, 'tag': 'New'},
  {'id': 6, 'name': 'Robotics Starter Kit', 'price': 1299.0, 'category': 'Kits', 'icon': Icons.precision_manufacturing_outlined, 'color': 0xFFC62828, 'rating': 4.8, 'reviews': 156, 'tag': 'Bundle'},
  {'id': 7, 'name': 'DHT11 Temperature Sensor', 'price': 60.0, 'category': 'Sensors', 'icon': Icons.thermostat, 'color': 0xFF2E7D32, 'rating': 4.4, 'reviews': 92, 'tag': null},
  {'id': 8, 'name': 'IoT Smart Home Kit', 'price': 1850.0, 'category': 'Kits', 'icon': Icons.home_outlined, 'color': 0xFF37474F, 'rating': 4.9, 'reviews': 78, 'tag': 'New'},
];

class StoreHomeTab extends StatefulWidget {
  final void Function(Map<String, dynamic>) onAddToCart;
  const StoreHomeTab({super.key, required this.onAddToCart});

  @override
  State<StoreHomeTab> createState() => _StoreHomeTabState();
}

class _StoreHomeTabState extends State<StoreHomeTab> {
  final PageController _bannerCtrl = PageController();
  int _bannerIndex = 0;
  Timer? _bannerTimer;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _banners = [
    {'title': 'Robotics Starter Kit', 'sub': 'Everything to begin your robotics journey', 'discount': '20% OFF', 'color1': 0xFF4A40DF, 'color2': 0xFF3B30C8, 'icon': Icons.precision_manufacturing_outlined},
    {'title': 'IoT Smart Home Kit', 'sub': 'Build your first smart home today', 'discount': '15% OFF', 'color1': 0xFF00695C, 'color2': 0xFF004D40, 'icon': Icons.home_outlined},
    {'title': 'ESP32 Wi-Fi Module', 'sub': 'Connect anything to the internet', 'discount': 'New Arrival', 'color1': 0xFF0277BD, 'color2': 0xFF01579B, 'icon': Icons.wifi},
    {'title': 'Arduino Mega Bundle', 'sub': 'Pro-level components at student prices', 'discount': '25% OFF', 'color1': 0xFFE65100, 'color2': 0xFFBF360C, 'icon': Icons.developer_board},
  ];

  final List<String> _categories = ['All', 'Electronics', 'Sensors', 'Motors', 'Kits'];

  @override
  void initState() {
    super.initState();
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_bannerCtrl.hasClients) {
        _bannerIndex = (_bannerIndex + 1) % _banners.length;
        _bannerCtrl.animateToPage(_bannerIndex,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered => kProducts.where((p) {
        final matchCat = _selectedCategory == 'All' || p['category'] == _selectedCategory;
        final matchSearch = _searchQuery.isEmpty || (p['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
        return matchCat && matchSearch;
      }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // ── App Bar ─────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            backgroundColor: const Color(0xFF1976FF),
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            ),
            title: Row(
              children: [
                const Text('E', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 24)),
                const Text('dukkit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('STORE', style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            actions: [
              IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}),
              const SizedBox(width: 4),
            ],
          ),

          // ── Search ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFF1976FF),
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search products, kits, sensors...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // ── Banner Slider ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                children: [
                  SizedBox(
                    height: 195,
                    child: PageView.builder(
                      controller: _bannerCtrl,
                      onPageChanged: (i) => setState(() => _bannerIndex = i),
                      itemCount: _banners.length,
                      itemBuilder: (_, i) => _buildBanner(_banners[i]),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Dots indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_banners.length, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _bannerIndex == i ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _bannerIndex == i ? const Color(0xFF4A40DF) : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    )),
                  ),
                ],
              ),
            ),
          ),

          // ── Category Pills ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 0, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D2D2D))),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final active = _selectedCategory == _categories[i];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = _categories[i]),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: active ? const Color(0xFF4A40DF) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: active ? const Color(0xFF4A40DF) : Colors.grey.shade300),
                            ),
                            child: Text(
                              _categories[i],
                              style: TextStyle(
                                color: active ? Colors.white : Colors.grey.shade700,
                                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Section Header ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _searchQuery.isEmpty ? 'Latest Products' : 'Search Results',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D2D2D)),
                  ),
                  Text('${_filtered.length} items', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                ],
              ),
            ),
          ),

          // ── Product Grid ─────────────────────────────────────────
          _filtered.isEmpty
              ? SliverToBoxAdapter(child: _buildEmpty())
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _buildProductCard(_filtered[i]),
                      childCount: _filtered.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                  ),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildBanner(Map<String, dynamic> b) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [Color(b['color1'] as int), Color(b['color2'] as int)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(b['discount'] as String,
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 10),
                      Text(b['title'] as String,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(b['sub'] as String,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                          maxLines: 2),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Shop Now',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4A40DF))),
                      ),
                    ],
                  ),
                ),
                Icon(b['icon'] as IconData, color: Colors.white.withValues(alpha: 0.3), size: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final color = Color(product['color'] as int);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image area
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    color: color.withValues(alpha: 0.1),
                  ),
                  child: Icon(product['icon'] as IconData, color: color, size: 56),
                ),
                if (product['tag'] != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(product['tag'] as String,
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)
                      ]),
                      child: const Icon(Icons.favorite_border, size: 14, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Product info
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF2D2D2D)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 13),
                    const SizedBox(width: 2),
                    Text('${product['rating']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    Text(' (${product['reviews']})', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('₹${(product['price'] as double).toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF4A40DF))),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => widget.onAddToCart(product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976FF),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Add to Cart', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() => Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              const Text('No products found', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
        ),
      );
}
