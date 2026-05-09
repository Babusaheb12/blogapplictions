import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blogapplictions/screen/ArticleDetail/ArticleDetailScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';

const Map<String, String> _fallbackCategories = {
  '2845757219068236428': 'Entertainment',
  '826211814301180005': 'Gaming',
  '1084535476346224117': 'Allo',
  '5693685077021534049': 'Culture',
  '2058296041178778041': 'Tech',
  '3476515391513647680': 'Travel',
  '3517875807507233031': 'Culture',
  '8653205988480689613': 'News',
  '4443867391140046863': 'AI',
  '2121500783627850394': 'Smart Home',
};

class SavedArticlesScreen extends StatefulWidget {
  const SavedArticlesScreen({super.key});

  @override
  State<SavedArticlesScreen> createState() => _SavedArticlesScreenState();
}

class _SavedArticlesScreenState extends State<SavedArticlesScreen> {
  String _selectedCategory = 'All';

  // Helper to strip HTML tags
  String _stripHtml(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: false);

    return htmlString.replaceAll(exp, '');
  }

  // Helper to extract image URL
  String? _extractImageUrl(String content) {
    RegExp exp = RegExp(r'<img[^>]+src="([^">]+)"');
    Match? match = exp.firstMatch(content);
    return match?.group(1);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to see saved articles')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Color(0xFF003399)),
        title: const Text(
          'InsightBlog',
          style: TextStyle(color: Color(0xFF2D62ED), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications_none_outlined, color: Color(0xFF003399)),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('saved_posts')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];
          final posts = docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

          if (posts.isEmpty) {
            return const Center(child: Text('No saved articles found.'));
          }

          // Extract unique labels
          final Set<String> uniqueLabels = {'All'};
          for (var post in posts) {
            final labels = post['labels'] as List<dynamic>?;
            if (labels != null && labels.isNotEmpty) {
              for (var label in labels) {
                uniqueLabels.add(label.toString());
              }
            } else {
              final postId = post['id']?.toString();
              final fallback = _fallbackCategories[postId];
              if (fallback != null) {
                uniqueLabels.add(fallback);
              }
            }
          }
          final categories = uniqueLabels.toList();

          final filteredPosts = _selectedCategory == 'All' 
              ? posts 
              : posts.where((post) {
                  final labels = post['labels'] as List<dynamic>?;
                  if (labels != null && labels.isNotEmpty) {
                    return labels.any((label) => label.toString().toLowerCase() == _selectedCategory.toLowerCase());
                  } else {
                    final postId = post['id']?.toString();
                    final fallback = _fallbackCategories[postId];
                    return fallback?.toLowerCase() == _selectedCategory.toLowerCase();
                  }
                }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header Section ---
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  'Saved Articles',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Curated content you've marked for later reading.",
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                ),
              ),
              const SizedBox(height: 24),

              // --- Category Filters ---
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category == _selectedCategory;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF2D62ED) : const Color(0xFFF1F4F9),
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected ? null : Border.all(color: const Color(0xFFD1D5DB)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.blueGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // --- Articles List ---
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredPosts.length,
                  itemBuilder: (context, index) {
                    final post = filteredPosts[index];
                    return _buildArticleCard(context: context, post: post);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildArticleCard({required BuildContext context, required Map<String, dynamic> post}) {
    final title = post['title'] ?? 'No Title';
    final content = post['content'] ?? '';
    final strippedContent = _stripHtml(content);
    final subtitle = strippedContent.length > 100 
        ? strippedContent.substring(0, 100) + '...' 
        : strippedContent;
    final author = post['author']?['displayName'] ?? 'Unknown';
    final initials = author.isNotEmpty ? author.substring(0, 1).toUpperCase() : 'U';
    final imageUrl = _extractImageUrl(content);

    final labels = post['labels'] as List<dynamic>?;
    final category = labels != null && labels.isNotEmpty 
        ? labels.first.toString() 
        : (_fallbackCategories[post['id']?.toString()] ?? 'BLOG');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ArticleDetailScreen(post: post)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: imageUrl != null 
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(height: 180, color: Colors.blueGrey.shade100, child: const Center(child: CircularProgressIndicator())),
                      errorWidget: (context, url, error) => Container(height: 180, color: Colors.blueGrey.shade100, child: const Center(child: Icon(Icons.error))),
                    )
                  : Container(height: 180, color: Colors.blueGrey.shade100, child: const Center(child: Icon(Icons.image, size: 50))),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(category, style: const TextStyle(color: Color(0xFF2D62ED), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.bookmark, color: Color(0xFF2D62ED), size: 22),
                        onPressed: () async {
                          // Unsave from here
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .collection('saved_posts')
                                .doc(post['id']?.toString())
                                .delete();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                  const SizedBox(height: 8),
                  Text(subtitle, style: const TextStyle(color: Colors.blueGrey, height: 1.4)),
                  const Divider(height: 32),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.grey.shade200,
                        child: Text(initials, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                      ),
                      const SizedBox(width: 10),
                      Text(author, style: const TextStyle(fontWeight: FontWeight.w500)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('•', style: TextStyle(color: Colors.grey)),
                      ),
                      const Text('5 min read', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}