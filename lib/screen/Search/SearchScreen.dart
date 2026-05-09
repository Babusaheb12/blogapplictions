import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:blogapplictions/Api/Api_url.dart';
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


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Dio _dio = Dio();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _hasSearched = false;
  List<String> _suggestedTags = [];

  @override
  void initState() {
    super.initState();
    _fetchSuggestedTags();
  }

  Future<void> _fetchSuggestedTags() async {
    try {
      final response = await _dio.get(
        ApiUrls.blogs,
        queryParameters: {
          'key': ApiUrls.apiKeys,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> posts = data['items'] ?? [];
        final Set<String> labels = {};
        for (var post in posts) {
          final postLabels = post['labels'] as List<dynamic>?;
          if (postLabels != null && postLabels.isNotEmpty) {
            for (var label in postLabels) {
              labels.add(label.toString());
            }
          } else {
            final postId = post['id']?.toString();
            final fallback = _fallbackCategories[postId];
            if (fallback != null) {
              labels.add(fallback);
            }
          }

        }
        setState(() {
          _suggestedTags = labels.toList();
        });
      }
    } catch (e) {
      // Ignore error for tags
    }
  }


  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _searchResults = [];
    });

    try {
      final response = await _dio.get(
        "${ApiUrls.blogs}/search",
        queryParameters: {
          'key': ApiUrls.apiKeys,
          'q': query,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          _searchResults = data['items'] ?? [];
          _isLoading = false;
          _hasSearched = true;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load results. Status: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  String _stripHtml(String htmlString) {
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: false);
    return htmlString.replaceAll(exp, '');
  }

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'InsightBlog Search',
          style: TextStyle(color: Color(0xFF2D62ED), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Search Bar ---
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchResults = [];
                      _hasSearched = false;
                    });
                  },

                ),
                filled: true,
                fillColor: const Color(0xFFF1F4F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _search,
            ),
            const SizedBox(height: 24),

            // --- Results Section ---
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage.isNotEmpty)
              Expanded(
                child: Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red))),
              )
            else if (!_hasSearched)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Suggested Topics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey)),
                    const SizedBox(height: 12),
                    if (_suggestedTags.isEmpty)
                      const Text('Loading tags...', style: TextStyle(color: Colors.grey))
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _suggestedTags.map((tag) => _buildSearchTag(tag)).toList(),
                      ),
                  ],
                ),
              )

            else if (_searchResults.isEmpty)
              const Expanded(
                child: Center(child: Text("No results found")),
              )

            else
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOP RESULTS (${_searchResults.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueGrey, letterSpacing: 1.2)),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final post = _searchResults[index];
                          return _buildResultCard(post);
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> post) {
    final title = post['title'] ?? 'No Title';
    final content = post['content'] ?? '';
    final strippedContent = _stripHtml(content);
    final desc = strippedContent.length > 100 
        ? strippedContent.substring(0, 100) + '...' 
        : strippedContent;
    final author = post['author']?['displayName'] ?? 'Unknown';
    final date = post['published'] ?? '';
    final imageUrl = _extractImageUrl(content);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ArticleDetailScreen(post: post)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl != null 
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(width: 70, height: 70, color: Colors.blueGrey.shade100, child: const Center(child: CircularProgressIndicator())),
                      errorWidget: (context, url, error) => Container(width: 70, height: 70, color: Colors.blueGrey.shade100, child: const Center(child: Icon(Icons.error))),
                    )
                  : Container(width: 70, height: 70, color: Colors.blueGrey.shade100, child: const Center(child: Icon(Icons.image, size: 30))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('$author · $date', style: const TextStyle(color: Color(0xFF2D62ED), fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSearchTag(String label) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _search(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFFDEE5F9), borderRadius: BorderRadius.circular(8)),
        child: Text(label, style: const TextStyle(color: Color(0xFF2D62ED), fontWeight: FontWeight.bold)),
      ),
    );
  }
}