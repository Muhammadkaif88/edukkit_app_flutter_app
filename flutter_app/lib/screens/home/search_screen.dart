import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/search_provider.dart';
import '../../models/search_result_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SafeArea(
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F4),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      onChanged: (value) => searchProvider.updateQuery(value),
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: "Search Edukkit...",
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.black54),
                                onPressed: () {
                                  _searchController.clear();
                                  searchProvider.updateQuery("");
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.tune_rounded, color: Color(0xFF0F172A), size: 22),
                  onPressed: () => _showFilterMenu(context),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _searchController.text.isEmpty
                ? _buildInitialState(searchProvider)
                : searchProvider.isLoading
                    ? _buildShimmerLoading()
                    : searchProvider.searchResults.isEmpty
                        ? _buildEmptyState()
                        : _buildSearchResults(searchProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState(SearchProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Searches",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => provider.clearHistory(),
                  child: const Text("Clear All", style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
              ],
            ),
            Wrap(
              spacing: 10,
              children: provider.recentSearches.map((item) {
                return InputChip(
                  label: Text(item),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade300)),
                  onPressed: () {
                    _searchController.text = item;
                    provider.updateQuery(item);
                  },
                  onDeleted: () => provider.removeSearchHistoryItem(item),
                  deleteIcon: const Icon(Icons.close, size: 14),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
          const Text(
            "Trending Searches",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.trendingSearches.length,
            itemBuilder: (context, index) {
              final item = provider.trendingSearches[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.trending_up, color: Color(0xFF5D3AC8), size: 20),
                ),
                title: Text(item, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.north_west, color: Colors.grey, size: 18), // YouTube style "fill" icon
                onTap: () {
                  _searchController.text = item;
                  provider.updateQuery(item);
                },
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            "Recently Viewed",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // Placeholder for recently viewed items
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Center(child: Icon(Icons.image, color: Colors.grey)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "No results found",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            "Try searching for something else",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: provider.searchResults.length,
      itemBuilder: (context, index) {
        final result = provider.searchResults[index];
        return _buildResultCard(result);
      },
    );
  }

  Widget _buildResultCard(SearchResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleNavigation(result),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: result.imageUrl.isNotEmpty
                        ? Image.network(result.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image))
                        : const Icon(Icons.image, color: Colors.grey, size: 30),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5D3AC8).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              result.category,
                              style: const TextStyle(color: Color(0xFF5D3AC8), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (result.rating > 0)
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 14),
                                const SizedBox(width: 4),
                                Text(result.rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        result.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.subtitle,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (result.price != null)
                            Text(
                              "₹${result.price}",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFDB44E)),
                            )
                          else if (result.type == SearchResultType.course)
                            const Text(
                              "Free Enroll",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF5D3AC8)),
                            ),
                          
                          ElevatedButton(
                            onPressed: () => _handleNavigation(result),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5D3AC8),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              minimumSize: const Size(0, 32),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Text(result.type == SearchResultType.course ? "Continue" : "View", style: const TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavigation(SearchResult result) {
    // Basic navigation logic - actual screens might need to be created or linked
    switch (result.type) {
      case SearchResultType.course:
        // Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailScreen(courseId: result.id)));
        break;
      case SearchResultType.product:
        // Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: result.id)));
        break;
      case SearchResultType.video:
        // Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPlayerScreen(videoId: result.id)));
        break;
      case SearchResultType.teacher:
        // Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherProfileScreen(teacherId: result.id)));
        break;
      case SearchResultType.category:
        // Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryScreen(category: result.title)));
        break;
    }
    
    // For now, let's just show a snackbar since we don't have all these screens
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Opening ${result.title} (${result.type.name})")),
    );
  }

  void _showFilterMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Filter Results", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text("Category", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: ["All", "Courses", "Products", "Videos", "Teachers"].map((cat) {
                  return ChoiceChip(
                    label: Text(cat),
                    selected: cat == "All",
                    onSelected: (val) {},
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text("Price Range", style: TextStyle(fontWeight: FontWeight.bold)),
              RangeSlider(
                values: const RangeValues(0, 5000),
                min: 0,
                max: 10000,
                onChanged: (val) {},
                activeColor: const Color(0xFF5D3AC8),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D3AC8),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Apply Filters", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
