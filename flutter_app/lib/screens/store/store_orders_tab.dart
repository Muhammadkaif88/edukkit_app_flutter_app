import 'package:flutter/material.dart';

class StoreOrdersTab extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  const StoreOrdersTab({super.key, required this.orders});

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
        title: const Text('My Orders',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: orders.isEmpty
          ? _empty()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (_, i) => _orderCard(orders[i]),
            ),
    );
  }

  Widget _orderCard(Map<String, dynamic> o) {
    final statusColor = Color(o['statusColor'] as int);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(o['id'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2D2D2D))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(o['status'] as String,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(o['items'] as String,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(o['date'] as String, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
                Text('₹${(o['total'] as double).toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF4A40DF))),
              ],
            ),
            if (o['status'] == 'Shipped') ...[
              const SizedBox(height: 12),
              _trackBar(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _trackBar() {
    final steps = ['Ordered', 'Packed', 'Shipped', 'Delivered'];
    const active = 2; // shipped
    return Row(
      children: List.generate(steps.length, (i) {
        final done = i <= active;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (i > 0)
                    Expanded(
                      child: Container(
                          height: 2,
                          color: done ? const Color(0xFF4A40DF) : Colors.grey.shade300),
                    ),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: done ? const Color(0xFF4A40DF) : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: done
                        ? const Icon(Icons.check, color: Colors.white, size: 12)
                        : null,
                  ),
                  if (i < steps.length - 1)
                    Expanded(
                      child: Container(
                          height: 2,
                          color: i < active ? const Color(0xFF4A40DF) : Colors.grey.shade300),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(steps[i],
                  style: TextStyle(
                      fontSize: 9,
                      color: done ? const Color(0xFF4A40DF) : Colors.grey,
                      fontWeight: done ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        );
      }),
    );
  }

  Widget _empty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('No Orders Yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Your orders will appear here', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
}
