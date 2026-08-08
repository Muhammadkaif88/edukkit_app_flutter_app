import 'package:flutter/material.dart';
import 'store_home_tab.dart';
import 'store_category_tab.dart';
import 'store_orders_tab.dart';
import 'store_cart_tab.dart';
import 'store_profile_tab.dart';
import 'store_checkout_screen.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  int _currentIndex = 0;
  final List<Map<String, dynamic>> _cartItems = [];
  final List<Map<String, dynamic>> _orders = [
    {'id': '#EDK-2401', 'items': 'Arduino Uno R3, ESP32 Wi-Fi Module', 'date': '02 May 2024', 'total': 830.0, 'status': 'Delivered', 'statusColor': 0xFF2E7D32},
    {'id': '#EDK-2389', 'items': 'Robotics Starter Kit', 'date': '18 Apr 2024', 'total': 1299.0, 'status': 'Shipped', 'statusColor': 0xFF0277BD},
    {'id': '#EDK-2371', 'items': 'SG90 Servo × 3, L298N Driver', 'date': '05 Apr 2024', 'total': 510.0, 'status': 'Processing', 'statusColor': 0xFFE65100},
    {'id': '#EDK-2340', 'items': 'DHT11 Sensor × 2, HC-SR04', 'date': '22 Mar 2024', 'total': 200.0, 'status': 'Delivered', 'statusColor': 0xFF2E7D32},
  ];

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      final idx = _cartItems.indexWhere((i) => i['id'] == product['id']);
      if (idx >= 0) {
        _cartItems[idx]['qty'] = (_cartItems[idx]['qty'] as int) + 1;
      } else {
        _cartItems.add({...product, 'qty': 1});
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['name']} added to cart!'),
        backgroundColor: const Color(0xFF1976FF),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  int get _cartCount =>
      _cartItems.fold(0, (sum, i) => sum + (i['qty'] as int));

  void _onCheckout() {
    final subtotal = _cartItems.fold(0.0, (s, i) => s + (i['price'] as double) * (i['qty'] as int));
    final delivery = 49.0;
    final total = subtotal + delivery;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoreCheckoutScreen(
          items: List.from(_cartItems),
          subtotal: subtotal,
          delivery: delivery,
          total: total,
          onOrderSuccess: () {
            setState(() {
              // Add new order to list
              final orderId = '#EDK-${2402 + _orders.length}';
              final itemsSummary = _cartItems.map((i) => '${i['name']} × ${i['qty']}').join(', ');
              
              _orders.insert(0, {
                'id': orderId,
                'items': itemsSummary,
                'date': '08 May 2024',
                'total': total,
                'status': 'Processing',
                'statusColor': 0xFFE65100,
              });

              _cartItems.clear();
              _currentIndex = 2; // Switch to Orders tab
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      StoreHomeTab(onAddToCart: _addToCart),
      StoreCategoryTab(onAddToCart: _addToCart),
      StoreOrdersTab(orders: _orders),
      StoreCartTab(
        cartItems: _cartItems,
        onRemove: (id) => setState(
            () => _cartItems.removeWhere((i) => i['id'] == id)),
        onQtyChange: (id, delta) => setState(() {
          final idx = _cartItems.indexWhere((i) => i['id'] == id);
          if (idx >= 0) {
            final newQty = (_cartItems[idx]['qty'] as int) + delta;
            if (newQty <= 0) {
              _cartItems.removeAt(idx);
            } else {
              _cartItems[idx]['qty'] = newQty;
            }
          }
        }),
        onCheckout: () => _onCheckout(),
      ),
      const StoreProfileTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    final items = [
      {'icon': Icons.home_outlined, 'active': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.grid_view_outlined, 'active': Icons.grid_view_rounded, 'label': 'Category'},
      {'icon': Icons.receipt_long_outlined, 'active': Icons.receipt_long, 'label': 'Orders'},
      {'icon': Icons.shopping_cart_outlined, 'active': Icons.shopping_cart_rounded, 'label': 'Cart'},
      {'icon': Icons.person_outline, 'active': Icons.person, 'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
          color: const Color(0xFF1976FF).withValues(alpha: 0.08),
          blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isActive = _currentIndex == i;
              final isCart = i == 3;
              return GestureDetector(
                onTap: () => setState(() => _currentIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF1976FF).withValues(alpha: 0.12)
                        : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            isActive
                                ? items[i]['active'] as IconData
                                : items[i]['icon'] as IconData,
                            color: isActive
                                ? const Color(0xFF1976FF)
                                : Colors.grey,
                            size: 24,
                          ),
                          if (isCart && _cartCount > 0)
                            Positioned(
                              top: -6,
                              right: -8,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    _cartCount > 9 ? '9+' : '$_cartCount',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isActive
                                ? const Color(0xFF1976FF)
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
