import 'package:flutter/material.dart';

class StoreCheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double delivery;
  final double total;
  final VoidCallback onOrderSuccess;

  const StoreCheckoutScreen({
    super.key,
    required this.items,
    required this.subtotal,
    required this.delivery,
    required this.total,
    required this.onOrderSuccess,
  });

  @override
  State<StoreCheckoutScreen> createState() => _StoreCheckoutScreenState();
}

class _StoreCheckoutScreenState extends State<StoreCheckoutScreen> {
  int _currentStep = 0;
  final _addressCtrl = TextEditingController(text: '123 Tech Lane, Kochi, Kerala');
  final _phoneCtrl = TextEditingController(text: '+91 9876543210');
  String _paymentMethod = 'UPI';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A40DF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Checkout',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildStepper(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _currentStep == 0 ? _buildShipping() : _buildPayment(),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      color: const Color(0xFF4A40DF),
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepCircle(0, 'Shipping', Icons.local_shipping_outlined),
          _stepLine(0),
          _stepCircle(1, 'Payment', Icons.payment_outlined),
        ],
      ),
    );
  }

  Widget _stepCircle(int step, String label, IconData icon) {
    final active = _currentStep == step;
    final done = _currentStep > step;
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: active || done ? Colors.white : Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            done ? Icons.check : icon,
            color: active || done ? const Color(0xFF4A40DF) : Colors.white70,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
                color: active || done ? Colors.white : Colors.white70,
                fontSize: 11,
                fontWeight: active ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _stepLine(int afterStep) {
    final done = _currentStep > afterStep;
    return Container(
      width: 60,
      height: 2,
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 20),
      color: done ? Colors.white : Colors.white.withValues(alpha: 0.2),
    );
  }

  Widget _buildShipping() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Shipping Address',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
        const SizedBox(height: 16),
        _buildTextField('Full Address', _addressCtrl, Icons.location_on_outlined, maxLines: 3),
        const SizedBox(height: 16),
        _buildTextField('Phone Number', _phoneCtrl, Icons.phone_outlined),
        const SizedBox(height: 24),
        const Text('Order Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: widget.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text('${item['qty']}x ', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A40DF))),
                  Expanded(child: Text(item['name'] as String, style: const TextStyle(fontSize: 13))),
                  Text('₹${((item['price'] as double) * (item['qty'] as int)).toStringAsFixed(0)}'),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPayment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Payment Method',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
        const SizedBox(height: 16),
        _payTile('UPI (Google Pay, PhonePe)', Icons.account_balance_wallet_outlined),
        _payTile('Credit / Debit Card', Icons.credit_card_outlined),
        _payTile('Net Banking', Icons.account_balance_outlined),
        _payTile('Cash on Delivery', Icons.payments_outlined),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFEEEBFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF4A40DF).withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              _summaryRow('Subtotal', widget.subtotal),
              const SizedBox(height: 8),
              _summaryRow('Delivery', widget.delivery),
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('₹${widget.total.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF4A40DF))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _payTile(String title, IconData icon) {
    final active = _paymentMethod == title;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: active ? const Color(0xFF4A40DF) : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? const Color(0xFF4A40DF) : Colors.grey, size: 24),
            const SizedBox(width: 16),
            Text(title, style: TextStyle(fontWeight: active ? FontWeight.bold : FontWeight.normal)),
            const Spacer(),
            if (active) const Icon(Icons.check_circle, color: Color(0xFF4A40DF)),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, double val) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      Text('₹${val.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
    ],
  );

  Widget _buildTextField(String label, TextEditingController ctrl, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4A40DF), size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              if (_currentStep == 0) {
                setState(() => _currentStep = 1);
              } else {
                _processOrder();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A40DF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(_currentStep == 0 ? 'Continue to Payment' : 'Place Order Now',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ),
    );
  }

  void _processOrder() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF4A40DF)),
                SizedBox(height: 20),
                Text('Processing your order...', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context); // close loader
      _showSuccess();
    });
  }

  void _showSuccess() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text('Order Placed Successfully!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Your kits will be shipped within 24 hours. You can track your order in the Orders tab.',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, height: 1.5)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // close sheet
                  Navigator.pop(context); // close checkout
                  widget.onOrderSuccess();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A40DF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Back to Store', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
