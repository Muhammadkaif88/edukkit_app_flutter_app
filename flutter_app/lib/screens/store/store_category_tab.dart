import 'package:flutter/material.dart';
import 'store_home_tab.dart';

class StoreCategoryTab extends StatefulWidget {
  final void Function(Map<String, dynamic>) onAddToCart;
  const StoreCategoryTab({super.key, required this.onAddToCart});

  @override
  State<StoreCategoryTab> createState() => _StoreCategoryTabState();
}

class _StoreCategoryTabState extends State<StoreCategoryTab> {
  final List<Map<String, dynamic>> _cats = [
    {'name': 'Electronics', 'icon': Icons.developer_board, 'color': 0xFF4A40DF, 'count': 42},
    {'name': 'Sensors', 'icon': Icons.sensors, 'color': 0xFF00695C, 'count': 28},
    {'name': 'Motors', 'icon': Icons.electric_bolt, 'color': 0xFFE65100, 'count': 15},
    {'name': 'Kits', 'icon': Icons.category_outlined, 'color': 0xFF6A1B9A, 'count': 10},
    {'name': 'Displays', 'icon': Icons.monitor, 'color': 0xFF0277BD, 'count': 18},
    {'name': 'Power', 'icon': Icons.battery_charging_full, 'color': 0xFFC62828, 'count': 12},
    {'name': 'Wireless', 'icon': Icons.wifi, 'color': 0xFF2E7D32, 'count': 20},
    {'name': 'Tools', 'icon': Icons.build_outlined, 'color': 0xFF37474F, 'count': 9},
  ];

  String? _selectedCat;

  @override
  Widget build(BuildContext context) {
    final products = _selectedCat == null
        ? kProducts
        : kProducts.where((p) => p['category'] == _selectedCat).toList();

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
        title: const Text('Categories',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: CustomScrollView(
        slivers: [
          // Category grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: _cats.length,
                itemBuilder: (_, i) {
                  final c = _cats[i];
                  final isSelected = _selectedCat == c['name'];
                  return GestureDetector(
                    onTap: () => setState(() =>
                        _selectedCat = isSelected ? null : c['name'] as String),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(c['color'] as int)
                                : Color(c['color'] as int).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected
                                ? Border.all(color: Color(c['color'] as int), width: 2)
                                : null,
                          ),
                          child: Icon(
                            c['icon'] as IconData,
                            color: isSelected
                                ? Colors.white
                                : Color(c['color'] as int),
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(c['name'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Color(c['color'] as int)
                                    : Colors.grey.shade700)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Divider + filter label
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCat == null ? 'All Products' : _selectedCat!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2D2D2D)),
                  ),
                  if (_selectedCat != null)
                    GestureDetector(
                      onTap: () => setState(() => _selectedCat = null),
                      child: const Text('Clear',
                          style: TextStyle(
                              color: Color(0xFF4A40DF),
                              fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          ),

          // Products list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _productTile(products[i]),
                childCount: products.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _productTile(Map<String, dynamic> p) {
    final color = Color(p['color'] as int);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(p['icon'] as IconData, color: color, size: 28),
        ),
        title: Text(p['name'] as String,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Row(
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 13),
            Text(' ${p['rating']}  •  ${p['category']}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('₹${(p['price'] as double).toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF4A40DF))),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => widget.onAddToCart(p),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Color(0xFF4A40DF), shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
