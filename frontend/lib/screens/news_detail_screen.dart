import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter for context.pop()
import 'package:intl/intl.dart'; // For date formatting
import '../models/news_item.dart';
import '../services/api_service.dart';

class NewsDetailScreen extends StatefulWidget {
  final String newsId; // ID passed from the router

  const NewsDetailScreen({required this.newsId, super.key});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<NewsItem> _newsDetailFuture;

  @override
  void initState() {
    super.initState();
    // Fetch the specific news item using the passed ID
    _newsDetailFuture = _apiService.fetchNewsById(widget.newsId);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    print("NewsDetailScreen Build - Can pop: ${GoRouter.of(context).canPop()}"); // Add this debug print

    return Scaffold(
      appBar: AppBar(
        // --- ADDED EXPLICIT BACK BUTTON ---
        // Although AppBar should add one automatically when possible,
        // this makes it explicit. It uses Navigator.pop or context.pop.
        leading: BackButton(
           onPressed: () {
                // Use context.pop() from GoRouter for better integration
                if (context.canPop()) {
                   context.pop();
                } else {
                  // Fallback if cannot pop (e.g., deep linked directly)
                  context.go('/news-archive'); // Or '/' for home
                }
           },
        ),
        // ---------------------------------
        title: const Text('News Details'),
        // You could dynamically set the title once data loads if desired:
        // title: FutureBuilder<NewsItem>( ... builder: (.., snapshot) => Text(snapshot.data?.title ?? 'News Details')),
      ),
      body: Center( // Center content
        child: Container( // Constrain width
          constraints: const BoxConstraints(maxWidth: 900), // Detail pages often narrower
          child: FutureBuilder<NewsItem>(
            future: _newsDetailFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                 // Handle specific "not found" error if desired
                 if (snapshot.error.toString().contains('404')) {
                     // You could return a more user-friendly "Not Found" widget here
                     return Center(
                       child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             const Icon(Icons.error_outline, size: 40, color: Colors.orange),
                             const SizedBox(height: 10),
                             const Text('News item not found.'),
                             const SizedBox(height: 20),
                             TextButton(
                                onPressed: () => context.go('/news-archive'), // Go back to list
                                child: const Text('Back to News List'),
                             )
                          ],
                       )
                     );
                 }
                 // Generic error display
                 return Center(child: Text('Error loading details: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final newsItem = snapshot.data!;
                // Display the full news item details
                return SingleChildScrollView( // Allow content scrolling
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      SelectableText( // Make title selectable too
                        newsItem.title,
                        style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 12),
                      // Published Date
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 14, color: Theme.of(context).hintColor),
                          const SizedBox(width: 6),
                          Text(
                            'Published: ${DateFormat('MMMM d, yyyy').format(newsItem.publishedAt)}',
                            style: textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
                          ),
                        ],
                      ),
                      const Divider(height: 30, thickness: 1),
                      // Content
                      SelectableText( // Allow text selection on web
                        newsItem.content ?? 'No content available.', // Handle null content
                        style: textTheme.bodyLarge?.copyWith(height: 1.6), // Adjust text style
                        textAlign: TextAlign.justify, // Justify longer text maybe
                      ),
                       const SizedBox(height: 30), // Add spacing at the bottom
                    ],
                  ),
                );
              } else {
                // Should not happen if error/waiting handled, but good practice
                return const Center(child: Text('Could not load news details.'));
              }
            },
          ),
        ),
      ),
    );
  }
}