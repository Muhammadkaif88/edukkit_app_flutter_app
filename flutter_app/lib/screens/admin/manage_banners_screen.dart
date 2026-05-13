import 'package:flutter/material.dart';
import '../../services/cloudflare_service.dart';

class ManageBannersScreen extends StatefulWidget {
  const ManageBannersScreen({super.key});

  @override
  State<ManageBannersScreen> createState() => _ManageBannersScreenState();
}

class _ManageBannersScreenState extends State<ManageBannersScreen> {
  final CloudflareService _api = CloudflareService();
  List<dynamic> _banners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBanners();
  }

  Future<void> _fetchBanners() async {
    setState(() => _isLoading = true);
    final banners = await _api.getBanners();
    setState(() {
      _banners = banners;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Banners"),
        backgroundColor: const Color(0xFF5D3AC8),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _banners.length,
              itemBuilder: (context, index) {
                final banner = _banners[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: banner['image_url'] != null
                        ? Image.network(banner['image_url'], width: 60, height: 40, fit: BoxFit.cover)
                        : const Icon(Icons.image),
                    title: Text(banner['title'] ?? 'Banner'),
                    subtitle: Text(banner['subtitle'] ?? ''),
                    trailing: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final titleController = TextEditingController();
          final subtitleController = TextEditingController();
          final actionUrlController = TextEditingController();

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Add New Banner"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
                  TextField(controller: subtitleController, decoration: const InputDecoration(labelText: "Subtitle")),
                  TextField(controller: actionUrlController, decoration: const InputDecoration(labelText: "Action URL")),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () async {
                    final success = await _api.addBanner({
                      'title': titleController.text,
                      'subtitle': subtitleController.text,
                      'action_url': actionUrlController.text,
                      'button_text': 'Check it out',
                      'image_url': 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=800',
                      'bg_color': '0xFF5D3AC8',
                    });
                    if (success && mounted) {
                      Navigator.pop(context);
                      _fetchBanners();
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
