import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // For navigation
import 'package:intl/intl.dart';     // For date formatting

import '../models/news_item.dart';
import '../services/api_service.dart';
// Removed CustomAppBar import as we are using standard AppBar here
// import '../widgets/custom_app_bar.dart';

class NewsArchiveScreen extends StatefulWidget {
  const NewsArchiveScreen({super.key});

  @override
  State<NewsArchiveScreen> createState() => _NewsArchiveScreenState();
}

class _NewsArchiveScreenState extends State<NewsArchiveScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<NewsItem>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = _apiService.fetchNews(); // Fetch all news
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    print("NewsArchiveScreen Build - Can pop: ${GoRouter.of(context).canPop()}"); // Add debug print

    return Scaffold(
      appBar: AppBar(
          // --- ADDED EXPLICIT BACK BUTTON ---
          leading: BackButton(
             onPressed: () {
                  if (context.canPop()) {
                     context.pop();
                  } else {
                    context.go('/community-hub'); // Fallback to hub or home
                  }
             },
          ),
          // ---------------------------------
          title: const Text('News Archive'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100), // Max width
          child: FutureBuilder<List<NewsItem>>(
            future: _newsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // Improved Error Display
                return Center(
                  child: Padding(
                     padding: const EdgeInsets.all(20.0),
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         const Icon(Icons.warning_amber_rounded, size: 40, color: Colors.orange),
                         const SizedBox(height: 10),
                         Text('Error loading news: ${snapshot.error}', textAlign: TextAlign.center),
                       ],
                    ),
                  )
                );
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final newsList = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: newsList.length,
                  itemBuilder: (context, index) {
                    final newsItem = newsList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0), // Slightly reduce bottom margin
                      elevation: 1, // Subtle elevation
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        // Added padding inside ListTile
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                        title: Text(
                           newsItem.title,
                           style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                           maxLines: 2, // Allow slightly more lines for title if needed
                           overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5.0), // Adjusted top padding
                          child: Text(
                            // Show formatted date and maybe first line of content
                            '${DateFormat('MMM d, yyyy').format(newsItem.publishedAt)} - ${newsItem.content?.split('\n').first ?? ''}'.trim(), // Trim potential whitespace
                            maxLines: 1, // Keep subtitle concise
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor), // Use hintColor for date
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.primary), // Use primary color for arrow
                        onTap: () {
                          // Navigate to detail screen using GoRouter
                          context.go('/news/${newsItem.id}');
                        },
                      ),
                    );
                  },
                );
              } else {
                // Improved Empty State Display
                 return Center(
                   child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         const Icon(Icons.article_outlined, size: 50, color: Colors.grey),
                         const SizedBox(height: 10),
                         Text('No news items found.', style: textTheme.bodyLarge),
                      ],
                   )
                );
              }
            },
          ),
        ),
      ),
    );
  }
}