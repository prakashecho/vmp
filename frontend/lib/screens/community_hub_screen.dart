import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

import '../widgets/main_drawer.dart';
import '../models/news_item.dart'; // Import the News model
import '../services/api_service.dart'; // Import the ApiService

class CommunityHubScreen extends StatefulWidget { // Change to StatefulWidget
  const CommunityHubScreen({super.key});

  @override
  State<CommunityHubScreen> createState() => _CommunityHubScreenState();
}

class _CommunityHubScreenState extends State<CommunityHubScreen> {
  // Instantiate the ApiService
  final ApiService _apiService = ApiService();
  // Future to hold the result of the API call
  late Future<List<NewsItem>> _newsFuture;

  @override
  void initState() {
    super.initState();
    // Start fetching news when the widget is initialized
    _newsFuture = _apiService.fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme; // Get theme data

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vemulapally Community Hub'),
      ),
      drawer: const MainDrawer(),
      body: Center( // Center content
        child: Container( // Constrain width
          constraints: const BoxConstraints(maxWidth: 1100),
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: <Widget>[

              // --- News Section ---
              _buildSectionHeader(context, 'Latest News'), // Use helper
              // Use FutureBuilder to handle the async API call
              FutureBuilder<List<NewsItem>>(
                future: _newsFuture, // The future we want to monitor
                builder: (context, snapshot) {
                  // Check connection state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show a loading indicator while waiting
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    // Show an error message if something went wrong
                    print("Error in FutureBuilder: ${snapshot.error}"); // Log error
                    return Center(child: Text('Error loading news: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    // If data is available and not empty, build the list
                    final newsList = snapshot.data!;
                    return Column(
                      // Build a list of news cards from the fetched data
                      children: newsList.map((newsItem) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        // Use the existing helper, passing real data
                        child: _buildNewsEventCard(
                            context,
                            textTheme,
                            Theme.of(context).colorScheme, // Pass color scheme
                            newsItem.title,
                            newsItem.content ?? 'No content preview available.', // Use content as snippet
                            DateFormat('MMM d, yyyy').format(newsItem.publishedAt) // Format date
                        ),
                      )).toList(), // Limit items shown on hub if needed .take(3)
                    );
                  } else {
                    // If no data or empty list, show a message
                    return const Center(child: Text('No news items found.'));
                  }
                },
              ),
              // Removed the static "View All" button for now, could be added back
              const Divider(height: 40, thickness: 1),

              // --- Events Section (Still Placeholder) ---
              _buildSectionHeader(context, 'Upcoming Events'),
              // Placeholder Cards - Replace with FutureBuilder for events later
              _buildNewsEventCard(context, textTheme, Theme.of(context).colorScheme,'Vemulapally Farmers Market', 'Fresh local produce, crafts, and more! Every Friday morning.', 'Next: 2025-04-05', icon: Icons.storefront_outlined),
              _buildNewsEventCard(context, textTheme, Theme.of(context).colorScheme,'Council Meeting', 'Open session to discuss community matters. Agenda available online.', '2025-04-10 19:00', icon: Icons.groups_outlined),
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

  // --- Helper Widgets (Keep these as they were or slightly adjust) ---

  // Helper for Section Headers
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0, top: 10.0), // Added top padding
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper for News/Event Cards (Used by FutureBuilder now for News)
  Widget _buildNewsEventCard(BuildContext context, TextTheme textTheme, ColorScheme colorScheme, String title, String snippet, String date, {IconData? icon}) {
     return Card(
       elevation: 1,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
       clipBehavior: Clip.antiAlias,
       child: InkWell( // Make card clickable
         onTap: () { /* Navigate to detail view later */ },
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
                const Icon(Icons.arrow_forward, size: 16, color: Colors.grey), // Arrow indicator
             ],
           ),
         ),
       ),
     );
  }

   // Helper for Directory/ThingsToDo Cards (Remains the same)
  Widget _buildDirectoryToDoCard(BuildContext context, IconData icon, String title, String subtitle, String category) {
     return Card( /* ... as before ... */ );
   }

  // Helper for "View All" Buttons (Remains the same)
  Widget _buildViewAllButton(BuildContext context, String text, String route) {
     return Align( /* ... as before ... */ );
   }
} // End of _CommunityHubScreenState