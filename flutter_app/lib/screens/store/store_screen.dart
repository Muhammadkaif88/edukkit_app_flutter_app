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
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
    );
  }
}
