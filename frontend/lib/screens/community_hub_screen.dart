import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // <-- IMPORT GoRouter
import 'package:intl/intl.dart';

import '../widgets/main_drawer.dart';
import '../models/news_item.dart';
import '../services/api_service.dart';

class CommunityHubScreen extends StatefulWidget {
  const CommunityHubScreen({super.key});

  @override
  State<CommunityHubScreen> createState() => _CommunityHubScreenState();
}

class _CommunityHubScreenState extends State<CommunityHubScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<NewsItem>> _newsFuture;
  // Add futures for other sections later
  // late Future<List<EventItem>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = _apiService.fetchNews();
    // _eventsFuture = _apiService.fetchEvents(); // Fetch events later
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme; // Get color scheme

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vemulapally Community Hub'),
        // --- ADDED HOME BUTTON TO ACTIONS ---
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined), // Home icon
            tooltip: 'Go Home', // Accessibility
            onPressed: () {
              // Navigate to the root route '/' using GoRouter
              context.go('/');
            },
          ),
          const SizedBox(width: 10), // Add some spacing if needed before the edge
        ],
        // ---------------------------------
      ),
      drawer: const MainDrawer(),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: ListView( // Use ListView instead of SingleChildScrollView + Column
            padding: const EdgeInsets.all(24.0),
            children: <Widget>[

              // --- News Section ---
              _buildSectionHeader(context, 'Latest News'),
              FutureBuilder<List<NewsItem>>(
                future: _newsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    print("Error loading news: ${snapshot.error}");
                    return Center(child: Text('Error loading news: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final newsList = snapshot.data!;
                    return Column(
                      children: [
                        // Display limited number of news items
                        ...newsList.take(3).map((newsItem) => Padding( // Show up to 3 items
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildNewsEventCard( // Pass ID here
                            context,
                            textTheme,
                            colorScheme,
                            newsItem.title,
                            newsItem.content ?? 'No content preview available.',
                            DateFormat('MMM d, yyyy').format(newsItem.publishedAt),
                            newsId: newsItem.id, // <-- PASS NEWS ID
                            // icon: Icons.article_outlined, // Optional icon for news
                          ),
                        )).toList(),
                        const SizedBox(height: 10),
                         // Show View All button only if there are news items
                         _buildViewAllButton(context, 'View All News', '/news-archive'), // Updated call
                      ]
                    );
                  } else {
                    return const Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text('No news items found.'),
                    ));
                  }
                },
              ),
              const Divider(height: 40, thickness: 1),

              // --- Events Section (Still Placeholder - FutureBuilder needed later) ---
              _buildSectionHeader(context, 'Upcoming Events'),
              // Replace these with FutureBuilder logic for events
              _buildNewsEventCard(context, textTheme, colorScheme,'Vemulapally Farmers Market', 'Fresh local produce, crafts, and more! Every Friday morning.', 'Next: 2025-04-05', icon: Icons.storefront_outlined),
              _buildNewsEventCard(context, textTheme, colorScheme,'Council Meeting', 'Open session to discuss community matters. Agenda available online.', '2025-04-10 19:00', icon: Icons.groups_outlined),
              _buildViewAllButton(context, 'View Full Events Calendar', '/events-calendar'), // Link to potential calendar view
              const Divider(height: 40, thickness: 1),


              // --- Things To Do Section (Still Placeholder) ---
              _buildSectionHeader(context, 'Things To Do'),
              _buildDirectoryToDoCard(context, Icons.park_outlined, 'Green Valley Park', 'Enjoy walking trails, picnic areas, and the playground.', 'Nature'),
              _buildDirectoryToDoCard(context, Icons.museum_outlined, 'Village Heritage Museum', 'Discover the rich history of Vemulapally.', 'Culture'),
              const SizedBox(height: 20),
              const Divider(height: 40, thickness: 1),

              // --- Directory Section (Still Placeholder) ---
              _buildSectionHeader(context, 'Local Directory'),
              _buildDirectoryToDoCard(context, Icons.store_outlined, 'Vemulapally General Store', 'Groceries, hardware, and everyday essentials.', 'Shop'),
              _buildDirectoryToDoCard(context, Icons.restaurant_menu_outlined, 'The Village Cafe', 'Coffee, snacks, and light meals.', 'Food & Drink'),
              _buildDirectoryToDoCard(context, Icons.school_outlined, 'Vemulapally Primary School', 'Educating the future of our village.', 'Education'),
              _buildViewAllButton(context, 'View Full Directory', '/directory-full'),

            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0, top: 10.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Updated News/Event Card Helper
  // Added optional newsId parameter
  Widget _buildNewsEventCard(BuildContext context, TextTheme textTheme, ColorScheme colorScheme, String title, String snippet, String date, {IconData? icon, String? newsId}) {
     return Card(
       elevation: 1,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
       clipBehavior: Clip.antiAlias,
       child: InkWell( // Make card clickable
         onTap: () {
           // ** NAVIGATE IF NEWS ID IS PROVIDED **
           if (newsId != null) {
             context.go('/news/$newsId'); // Navigate to detail page
           } else {
             // Handle tap for events or other types later
             print('Tapped on non-news item or item without ID');
             // Example: context.go('/event/$eventId');
           }
         },
         child: Padding(
           padding: const EdgeInsets.all(16.0),
           child: Row( // Use Row if icon is present
            crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               if (icon != null) // Conditionally show icon
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0, top: 2),
                    child: Icon(icon, color: colorScheme.primary, size: 20),
                  ),
               Expanded( // Make text column take remaining space
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                     const SizedBox(height: 4),
                     Text(date, style: textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor)),
                     const SizedBox(height: 8),
                     Text(snippet, style: textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                   ],
                 ),
               ),
                const SizedBox(width: 10), // Space before arrow
                // Conditionally show arrow only if it's navigable (e.g., has newsId)
                if (newsId != null)
                    const Icon(Icons.arrow_forward, size: 16, color: Colors.grey)
                else const SizedBox(width: 16), // Maintain space even if no arrow
             ],
           ),
         ),
       ),
     );
  }

  // Directory/ToDo Card Helper (No changes needed here yet)
  Widget _buildDirectoryToDoCard(BuildContext context, IconData icon, String title, String subtitle, String category) {
     return Card(
       elevation: 1,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
       child: ListTile(
         leading: CircleAvatar(
           backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
           child: Icon(icon, color: Theme.of(context).colorScheme.primary),
         ),
         title: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
         subtitle: Padding(
           padding: const EdgeInsets.only(top: 4.0),
           child: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
         ),
         trailing: Text(category, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
         onTap: () { /* Navigate to detail page later */ },
       ),
     );
   }

  // "View All" Button Helper (Updated to handle specific route)
  Widget _buildViewAllButton(BuildContext context, String text, String route) {
     return Align(
       alignment: Alignment.centerRight,
       child: Padding(
         padding: const EdgeInsets.only(top: 10.0),
         child: TextButton(
           onPressed: () {
              // Use GoRouter to navigate
              context.go(route);
           },
           child: Text(text),
         ),
       ),
     );
   }
} // End of _CommunityHubScreenState