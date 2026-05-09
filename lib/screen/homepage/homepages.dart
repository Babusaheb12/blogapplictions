import 'package:flutter/material.dart';
import 'package:blogapplictions/screen/ArticleDetail/ArticleDetailScreen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blogapplictions/screen/homepage/Bloc/home_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController _scrollController = ScrollController();

  String _selectedCategory = 'All';

  Set<String> _savedPostIds = {};

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    _fetchSavedPosts();
  }

  void _fetchSavedPosts() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('saved_posts')
          .get();

      setState(() {
        _savedPostIds = snapshot.docs.map((doc) => doc.id).toSet();
      });
    }
  }

  void _toggleSave(Map<String, dynamic> post) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final postId = post['id']?.toString();

    if (postId == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved_posts')
        .doc(postId);

    if (_savedPostIds.contains(postId)) {
      await docRef.delete();

      setState(() {
        _savedPostIds.remove(postId);
      });
    } else {
      await docRef.set(post);

      setState(() {
        _savedPostIds.add(postId);
      });
    }
  }

  void _onScroll() {
    if (_isBottom) {
      final homeBloc = context.read<HomeBloc>();

      final state = homeBloc.state;

      if (state is HomeLoaded && state.nextPageToken != null) {
        homeBloc.add(FetchNextPage(state.nextPageToken!));
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;

    final maxScroll = _scrollController.position.maxScrollExtent;

    final currentScroll = _scrollController.offset;

    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);

    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,

        elevation: 0,

        automaticallyImplyLeading: false,

        title: const Text(
          'InsightBlog',
          style: TextStyle(
            color: Color(0xFF2D62ED),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),

        centerTitle: true,
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          context.read<HomeBloc>().add(FetchPosts());
        },

        child: SingleChildScrollView(
          controller: _scrollController,

          physics: const AlwaysScrollableScrollPhysics(),

          child: Column(
            children: [
              const SizedBox(height: 10),

              BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (state is HomeError) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 50),

                      child: Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  if (state is HomeLoaded) {
                    final posts = state.posts;

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
                        return labels.any(
                              (label) =>
                          label.toString().toLowerCase() ==
                              _selectedCategory.toLowerCase(),
                        );
                      } else {
                        final postId = post['id']?.toString();

                        final fallback =
                        _fallbackCategories[postId];

                        return fallback?.toLowerCase() ==
                            _selectedCategory.toLowerCase();
                      }
                    }).toList();

                    return Column(
                      children: [
                        SizedBox(
                          height: 40,

                          child: ListView(
                            scrollDirection: Axis.horizontal,

                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),

                            children: categories
                                .map(
                                  (category) =>
                                  _buildCategoryChip(category),
                            )
                                .toList(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        if (filteredPosts.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 50),

                            child: Center(
                              child: Text(
                                "No posts found in '$_selectedCategory'",
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),

                            child: ListView.builder(
                              shrinkWrap: true,

                              physics:
                              const NeverScrollableScrollPhysics(),

                              itemCount: filteredPosts.length +
                                  (state.nextPageToken != null ? 1 : 0),

                              itemBuilder: (context, index) {
                                if (index == filteredPosts.length) {
                                  return const Padding(
                                    padding:
                                    EdgeInsets.symmetric(vertical: 20),

                                    child: Center(
                                      child:
                                      CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                final post = filteredPosts[index];

                                if (index % 2 == 0) {
                                  return Padding(
                                    padding:
                                    const EdgeInsets.only(bottom: 20),

                                    child: _buildLargeCard(
                                      context: context,
                                      post: post,
                                    ),
                                  );
                                }

                                return Padding(
                                  padding:
                                  const EdgeInsets.only(bottom: 20),

                                  child: _buildSmallCard(
                                    context: context,
                                    post: post,
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final isSelected = label == _selectedCategory;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },

      child: Container(
        margin: const EdgeInsets.only(right: 8),

        padding: const EdgeInsets.symmetric(horizontal: 20),

        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2D62ED)
              : const Color(0xFFF1F4F9),

          borderRadius: BorderRadius.circular(8),
        ),

        alignment: Alignment.center,

        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLargeCard({
    required BuildContext context,
    required Map<String, dynamic> post,
  }) {
    final title = post['title'] ?? 'No Title';

    final content = post['content'] ?? '';

    final strippedContent = _stripHtml(content);

    final subtitle = strippedContent.length > 100
        ? '${strippedContent.substring(0, 100)}...'
        : strippedContent;

    final author = post['author']?['displayName'] ?? 'Unknown';

    final date = post['published'] ?? '';

    final imageUrl = _extractImageUrl(content);

    final labels = post['labels'] as List<dynamic>?;

    final category = labels != null && labels.isNotEmpty
        ? labels.first.toString()
        : (_fallbackCategories[post['id']?.toString()] ?? 'BLOG');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(post: post),
          ),
        );
      },

      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),

          border: Border.all(color: Colors.grey.shade200),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),

              child: imageUrl != null
                  ? CachedNetworkImage(
                imageUrl: imageUrl,

                height: 180,

                width: double.infinity,

                fit: BoxFit.cover,

                placeholder: (context, url) => Container(
                  height: 180,
                  color: Colors.blueGrey.shade100,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),

                errorWidget: (context, url, error) => Container(
                  height: 180,
                  color: Colors.blueGrey.shade100,
                  child: const Center(
                    child: Icon(Icons.error),
                  ),
                ),
              )
                  : Container(
                height: 180,
                color: Colors.blueGrey.shade100,
                child: const Center(
                  child: Icon(Icons.image, size: 50),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        '$category • 5 min read',
                        style: const TextStyle(
                          color: Color(0xFF2D62ED),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      IconButton(
                        constraints: const BoxConstraints(),

                        padding: EdgeInsets.zero,

                        icon: Icon(
                          _savedPostIds.contains(
                            post['id']?.toString(),
                          )
                              ? Icons.bookmark
                              : Icons.bookmark_border,

                          color: const Color(0xFF2D62ED),

                          size: 20,
                        ),

                        onPressed: () => _toggleSave(post),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.grey,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [
                            Text(
                              author,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              date,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildSmallCard({
    required BuildContext context,
    required Map<String, dynamic> post,
  }) {
    final title = post['title'] ?? 'No Title';

    final content = post['content'] ?? '';

    final strippedContent = _stripHtml(content);

    final subtitle = strippedContent.length > 100
        ? '${strippedContent.substring(0, 100)}...'
        : strippedContent;

    final author = post['author']?['displayName'] ?? 'Unknown';

    final date = post['published'] ?? '';

    final imageUrl = _extractImageUrl(content);

    final labels = post['labels'] as List<dynamic>?;

    final category = labels != null && labels.isNotEmpty
        ? labels.first.toString()
        : (_fallbackCategories[post['id']?.toString()] ?? 'BLOG');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(post: post),
          ),
        );
      },

      child: Container(

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),

          border: Border.all(color: Colors.grey.shade200),
        ),

        child: Row(
          children: [
            ClipRRect(
              borderRadius:
              const BorderRadius.horizontal(left: Radius.circular(16)),

              child: imageUrl != null
                  ? CachedNetworkImage(
                imageUrl: imageUrl,

                height: 150,

                width: 120,

                fit: BoxFit.cover,

                placeholder: (context, url) => Container(
                  height: 150,
                  width: 120,
                  color: Colors.blueGrey.shade100,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),

                errorWidget: (context, url, error) => Container(
                  height: 150,
                  width: 120,
                  color: Colors.blueGrey.shade100,
                  child: const Center(
                    child: Icon(Icons.error),
                  ),
                ),
              )
                  : Container(
                height: 150,
                width: 120,
                color: Colors.blueGrey.shade100,
                child: const Center(
                  child: Icon(Icons.image, size: 30),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                      children: [
                        Text(
                          category,
                          style: const TextStyle(
                            color: Color(0xFF2D62ED),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        IconButton(
                          constraints: const BoxConstraints(),

                          padding: EdgeInsets.zero,

                          icon: Icon(
                            _savedPostIds.contains(
                              post['id']?.toString(),
                            )
                                ? Icons.bookmark
                                : Icons.bookmark_border,

                            color: const Color(0xFF2D62ED),

                            size: 18,
                          ),

                          onPressed: () => _toggleSave(post),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),


                    Text(
                      '$author • $date',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _stripHtml(String htmlString) {
    final RegExp exp = RegExp(
      r"<[^>]*>",
      multiLine: true,
      caseSensitive: false,
    );

    return htmlString.replaceAll(exp, '');
  }

  String? _extractImageUrl(String htmlString) {
    final RegExp exp = RegExp(
      r'<img[^>]+src="([^">]+)"',
      multiLine: true,
      caseSensitive: false,
    );

    final match = exp.firstMatch(htmlString);

    final url = match?.group(1);

    if (url != null && url.startsWith('//')) {
      return 'https:$url';
    }

    return url;
  }
}