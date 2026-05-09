import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> post;

  const ArticleDetailScreen({super.key, required this.post});

  String? _extractImageUrl(String htmlString) {
    final RegExp exp = RegExp(r'<img[^>]+src="([^">]+)"', multiLine: true, caseSensitive: false);
    final match = exp.firstMatch(htmlString);
    final url = match?.group(1);
    if (url != null && url.startsWith('//')) {
      return 'https:$url';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _extractImageUrl(post['content'] ?? '');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // --- Hero Image & Header ---
              SliverAppBar(
                expandedHeight: 300,
                backgroundColor: Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.8),
                    child: const BackButton(color: Colors.black),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.8),
                      child: IconButton(
                        icon: const Icon(Icons.share, color: Colors.black),
                        onPressed: () {
                          final url = post['url'] ?? '';
                          Share.share('Read this post: ${post['title'] ?? 'No Title'}${url.isNotEmpty ? '\n\n$url' : ''}');
                        },
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.blueGrey.shade100, child: const Center(child: CircularProgressIndicator())),
                              errorWidget: (context, url, error) => Container(color: Colors.blueGrey.shade100, child: const Center(child: Icon(Icons.error))),
                            )
                          : Container(color: Colors.blueGrey.shade100, child: const Center(child: Icon(Icons.image, size: 50))),
                      // Gradient overlay for readability
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xFFF8F9FE)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Article Content ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Floating Title Card
                      _buildTitleCard(),
                      const SizedBox(height: 20),

                      // Render HTML Content
                      Html(
                        data: post['content'] ?? '',
                        style: {
                          "body": Style(
                            fontSize: FontSize(16),
                            lineHeight: LineHeight(1.6),
                            color: const Color(0xFF2D3436),
                          ),
                        },
                      ),
                      
                      const SizedBox(height: 100), // Space for bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- Bottom Action Bar ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleCard() {
    final author = post['author']?['displayName'] ?? 'Unknown';
    final date = post['published'] ?? '';
    final authorImage = post['author']?['image']?['url'];
    final authorImageUrl = authorImage != null && authorImage.startsWith('//') ? 'https:$authorImage' : authorImage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFF2D62ED), borderRadius: BorderRadius.circular(6)),
            child: const Text("BLOG", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Text(
            post['title'] ?? 'No Title',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2),
          ),
          const Divider(height: 32),
          Row(
            children: [
              CircleAvatar(
                backgroundImage: authorImageUrl != null ? NetworkImage(authorImageUrl) : null,
                child: authorImageUrl == null ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(author, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.thumb_up_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.mode_comment_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {
              final url = post['url'] ?? '';
              Share.share('Read this post: ${post['title'] ?? 'No Title'}${url.isNotEmpty ? '\n\n$url' : ''}');
            },
            icon: const Icon(Icons.share, size: 18),
            label: const Text("Share"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003399),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}