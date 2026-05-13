import 'package:flutter/material.dart';
import '../../services/cloudflare_service.dart';

class ManageCoursesScreen extends StatefulWidget {
  const ManageCoursesScreen({super.key});

  @override
  State<ManageCoursesScreen> createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends State<ManageCoursesScreen> {
  final CloudflareService _api = CloudflareService();
  List<dynamic> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    setState(() => _isLoading = true);
    final courses = await _api.getCourses();
    setState(() {
      _courses = courses;
      _isLoading = false;
    });
  }

  void _showAddCourseDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final instructorController = TextEditingController();
    final priceController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Course"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
              TextField(controller: descController, decoration: const InputDecoration(labelText: "Description")),
              TextField(controller: instructorController, decoration: const InputDecoration(labelText: "Instructor")),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: "Category")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final success = await _api.addCourse({
                'title': titleController.text,
                'description': descController.text,
                'instructor': instructorController.text,
                'price': double.tryParse(priceController.text) ?? 0.0,
                'category': categoryController.text,
                'thumbnail_url': 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=500', // Default placeholder
              });
              
              if (success) {
                if (mounted) {
                  Navigator.pop(context);
                  _fetchCourses();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Course added!")));
                }
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Courses"),
        backgroundColor: const Color(0xFF5D3AC8),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _showAddCourseDialog),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: course['thumbnail_url'] != null 
                      ? Image.network(course['thumbnail_url'], width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.book),
                    title: Text(course['title'] ?? 'Untitled'),
                    subtitle: Text("${course['instructor']} • \$${course['price']}"),
                    trailing: const Icon(Icons.edit_outlined),
                  ),
                );
              },
            ),
    );
  }
}
