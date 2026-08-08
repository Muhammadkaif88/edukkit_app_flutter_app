import 'package:flutter/material.dart';

class StoreCartTab extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final void Function(int id) onRemove;
  final void Function(int id, int delta) onQtyChange;
  final VoidCallback onCheckout;

  const StoreCartTab({
    super.key,
    required this.cartItems,
    required this.onRemove,
    required this.onQtyChange,
    required this.onCheckout,
  });

  double get _subtotal =>
      cartItems.fold(0, (s, i) => s + (i['price'] as double) * (i['qty'] as int));
  double get _delivery => cartItems.isEmpty ? 0 : 49.0;
  double get _total => _subtotal + _delivery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976FF),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
        title: Text('Cart (${cartItems.length})',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                for (final item in List.from(cartItems)) {
                  onRemove(item['id'] as int);
                }
              },
              child: const Text('Clear', style: TextStyle(color: Colors.white70)),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _empty()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (_, i) => _cartItem(cartItems[i]),
                  ),
                ),
                _buildSummary(context),
              ],
            ),
    );
  }

  Widget _cartItem(Map<String, dynamic> item) {
    final color = Color(item['color'] as int);
    return Dismissible(
      key: Key('cart-${item['id']}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(item['id'] as int),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item['icon'] as IconData, color: color, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('₹${(item['price'] as double).toStringAsFixed(0)}',
                        style: const TextStyle(color: Color(0xFF4A40DF), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              _qtyControl(item),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qtyControl(Map<String, dynamic> item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _qtyBtn(Icons.remove, () => onQtyChange(item['id'] as int, -1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('${item['qty']}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        _qtyBtn(Icons.add, () => onQtyChange(item['id'] as int, 1)),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFEEEBFF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF4A40DF)),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, -4))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', '₹${_subtotal.toStringAsFixed(0)}', false),
          const SizedBox(height: 6),
          _summaryRow('Delivery', '₹${_delivery.toStringAsFixed(0)}', false),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          _summaryRow('Total', '₹${_total.toStringAsFixed(0)}', true),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Proceed to Checkout',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, bool bold) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  fontSize: bold ? 16 : 14,
                  color: bold ? const Color(0xFF2D2D2D) : Colors.grey.shade600)),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: bold ? 18 : 14,
                  color: bold ? const Color(0xFF4A40DF) : const Color(0xFF2D2D2D))),
        ],
      );

  Widget _empty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('Your Cart is Empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Add products to your cart', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
}
