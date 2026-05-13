import 'package:flutter/material.dart';
import '../../services/cloudflare_service.dart';

class ManageKitsScreen extends StatefulWidget {
  const ManageKitsScreen({super.key});

  @override
  State<ManageKitsScreen> createState() => _ManageKitsScreenState();
}

class _ManageKitsScreenState extends State<ManageKitsScreen> {
  final CloudflareService _api = CloudflareService();
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    final products = await _api.getProducts();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage DIY Kits"),
        backgroundColor: const Color(0xFF5D3AC8),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: product['image_url'] != null
                            ? Image.network(product['image_url'], fit: BoxFit.cover, width: double.infinity)
                            : Container(color: Colors.grey.shade200, child: const Icon(Icons.shopping_bag)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product['title'] ?? 'Product', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text("\$${product['price']}"),
                            Text("Stock: ${product['stock']}", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final titleController = TextEditingController();
          final descController = TextEditingController();
          final priceController = TextEditingController();
          final stockController = TextEditingController();

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Add New DIY Kit"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
                  TextField(controller: descController, decoration: const InputDecoration(labelText: "Description")),
                  TextField(controller: priceController, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
                  TextField(controller: stockController, decoration: const InputDecoration(labelText: "Stock"), keyboardType: TextInputType.number),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () async {
                    final success = await _api.addProduct({
                      'title': titleController.text,
                      'description': descController.text,
                      'price': double.tryParse(priceController.text) ?? 0.0,
                      'stock': int.tryParse(stockController.text) ?? 0,
                      'image_url': 'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=500',
                    });
                    if (success && mounted) {
                      Navigator.pop(context);
                      _fetchProducts();
                    }
                  },
                  child: const Text("Add"),
                ),
              ],
            ),
          );
        },
        backgroundColor: const Color(0xFF5D3AC8),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
