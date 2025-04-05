import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
// ** Imports as provided by user **
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// This import might still cause issues depending on environment, but leaving as requested
import 'package:carousel_slider/carousel_controller.dart' as carousel_slider;

// Import widgets and theme/colors
import '../widgets/main_drawer.dart';
import '../widgets/custom_app_bar.dart';
import '../models/news_item.dart'; // Import the NewsItem model
import '../models/job_item.dart'; // Import the JobItem model
import '../services/api_service.dart'; // Import the ApiService
import 'package:intl/intl.dart'; // Import for date formatting


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ApiService instance
  final ApiService _apiService = ApiService(); // Instantiate ApiService

  // Futures for async data
  late Future<List<NewsItem>> _newsFuture; // Future for News
  late Future<List<JobItem>> _jobsFuture; // Future for Jobs

  // --- Carousel controller section - Leaving as provided by user ---
  // This declaration is likely still problematic due to type mismatch,
  // but kept as requested.
  final carouselController = CarouselController();
  int _currentCarouselIndex = 0;
  // --- End Carousel controller section ---


  // Banner Images Placeholder
  final List<String> bannerImagePaths = [
    'assets/images/banner_illustration.png',
    'assets/images/quicklink_card1.png', // Consider replacing with banner images
    'assets/images/cf092734-def4-4a5b-b1b9-2318dea4f3bc.png', // Consider replacing
    'assets/images/quicklink_card4.png', // Consider replacing
  ];

  // --- REMOVED Static Placeholder Data for News/Events ---

  @override
  void initState() {
    super.initState();
    // Initialize API calls in initState
    _newsFuture = _apiService.fetchNews(); // Fetch news data
    _jobsFuture = _apiService.fetchOpenJobs(); // Fetch job data
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isWideScreen = screenWidth > 800;

    return Scaffold(
      // ** Using background color from user's code **
      backgroundColor: const Color(0xFFD4C4AF),
      appBar: const CustomAppBar(),
      drawer: const MainDrawer(),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1100),
             padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBannerCarousel(context),
                const SizedBox(height: 40),
                _buildHighlightsSection(context, textTheme, colorScheme),
                const SizedBox(height: 50),
                // Pass the _newsFuture down
                _buildNewsAndEventsSection(context, textTheme, colorScheme, isWideScreen, _newsFuture),
                const SizedBox(height: 50), // Add extra space before jobs section
                // Add the new Jobs section
                _buildJobsSection(context, textTheme, colorScheme, isWideScreen, _jobsFuture),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Banner Carousel Widget (Keeping user's provided code state) ---
  Widget _buildBannerCarousel(BuildContext context) {
    if (bannerImagePaths.isEmpty) {
      return Container(
         height: 350,
         decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
         child: const Center(child: Text('Banner Image Unavailable')),
      );
    }
    return Column(
      children: [
        CarouselSlider.builder(
          // Controller line commented out as in user's provided code
          // carouselController: carouselController,
          options: CarouselOptions(
            height: 350,
            autoPlay: bannerImagePaths.length > 1,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
          ),
          itemCount: bannerImagePaths.length,
          itemBuilder: (context, index, realIndex) {
            final imagePath = bannerImagePaths[index];
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print("Error loading banner image: $imagePath, $error");
                    return const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 50));
                  },
                ),
              ),
            );
          },
        ),
        // Indicators
        if (bannerImagePaths.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: AnimatedSmoothIndicator(
              activeIndex: _currentCarouselIndex,
              count: bannerImagePaths.length,
              effect: WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Theme.of(context).colorScheme.secondary,
                dotColor: Colors.grey.shade300,
              ),
            ),
          ),
      ],
    );
  }

  // --- Highlights Section Widget (Keeping user's provided code state) ---
  Widget _buildHighlightsSection(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Text('HIGHLIGHTS', style: textTheme.headlineSmall),
             IconButton(
               icon: Icon(Icons.search, color: Theme.of(context).hintColor),
               onPressed: () { /* Implement Search */ },
               tooltip: 'Search',
             ),
           ],
         ),
         Container(
             height: 2, width: 100, color: colorScheme.secondary, margin: const EdgeInsets.only(top: 4, bottom: 20)),
         Row(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   SelectableText(
                     'Lorem ipsum dolor sit amet, consectetur adipiscing elit ed do eiusmod easliciuntan to eread ouieh magna vai. Eir, onei ia taeere n istrai.',
                     style: textTheme.bodyMedium,
                   ),
                   const SizedBox(height: 15),
                   ElevatedButton(
                     onPressed: () {},
                     child: const Text('Read Here'),
                   ),
                 ],
               ),
             ),
             const SizedBox(width: 30),
             Expanded(
               child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   SelectableText(
                     'Lorem ipsum dolor sit ama neert adpiscing elit sited d esmia euingnin',
                      style: textTheme.bodyMedium,
                   ),
                   const SizedBox(height: 15),
                   TextButton(
                     onPressed: () {},
                     child: const Text('To ois here'),
                     style: TextButton.styleFrom(foregroundColor: colorScheme.primary)
                   ),
                 ],
               ),
             ),
           ],
         ),
       ],
     );
  }

 // --- News & Events Section Widget (FIXED FutureBuilder integration) ---
  Widget _buildNewsAndEventsSection(BuildContext context, TextTheme textTheme, ColorScheme colorScheme, bool isWide, Future<List<NewsItem>> newsFuture) { // Accept future
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('NEWS & EVENTS', style: textTheme.headlineSmall),
        Container(
             height: 2, width: 100, color: colorScheme.secondary, margin: const EdgeInsets.only(top: 4, bottom: 20)),

        isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // News Column uses FutureBuilder directly
                Expanded(child: _buildNewsColumnWithFuture(context, textTheme, colorScheme, newsFuture)), // Pass future
                const SizedBox(width: 30),
                // Events column uses placeholder data for now
                Expanded(child: _buildPlaceholderEventsColumn(context, textTheme, colorScheme)),
              ],
            )
          : Column(
              children: [
                 // News Column uses FutureBuilder directly
                 _buildNewsColumnWithFuture(context, textTheme, colorScheme, newsFuture), // Pass future
                 const SizedBox(height: 30),
                 // Events column uses placeholder data for now
                 _buildPlaceholderEventsColumn(context, textTheme, colorScheme),
              ],
            ),
      ],
    );
  }

  // --- NEW Jobs Section Widget ---
  Widget _buildJobsSection(BuildContext context, TextTheme textTheme, ColorScheme colorScheme, bool isWide, Future<List<JobItem>> jobsFuture) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('JOBS & OPPORTUNITIES', style: textTheme.headlineSmall),
            IconButton(
              icon: const Icon(Icons.work_outline),
              onPressed: () => context.go('/jobs'),
              tooltip: 'View All Jobs',
            ),
          ],
        ),
        Container(
            height: 2, width: 100, color: colorScheme.secondary, margin: const EdgeInsets.only(top: 4, bottom: 20)),
        
        // Use FutureBuilder directly for jobs
        FutureBuilder<List<JobItem>>(
          future: jobsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()));
            } else if (snapshot.hasError) {
              print("Error loading jobs for home screen: ${snapshot.error}");
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text('Could not load job opportunities.', style: textTheme.bodyMedium),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        onPressed: () {
                          setState(() {
                            _jobsFuture = _apiService.fetchOpenJobs();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final jobsList = snapshot.data!;
              return isWide
                  ? _buildWideJobsGrid(context, textTheme, colorScheme, jobsList)
                  : _buildNarrowJobsList(context, textTheme, colorScheme, jobsList);
            } else {
              // No jobs found
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text('No current job opportunities.', style: textTheme.bodyMedium),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Post a Job'),
                        onPressed: () => context.go('/post-job'),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
        
        const SizedBox(height: 16),
        // View All Button (outside FutureBuilder, shown regardless of items)
        _buildViewAllButton(context, 'View All Jobs', '/jobs'),
      ],
    );
  }

  // Helper for wide screen jobs display
  Widget _buildWideJobsGrid(BuildContext context, TextTheme textTheme, ColorScheme colorScheme, List<JobItem> jobs) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 2.5, // Wider aspect ratio for job cards
      ),
      itemCount: jobs.length > 4 ? 4 : jobs.length, // Show only up to 4 jobs
      itemBuilder: (context, index) {
        return _buildJobPreviewCard(context, textTheme, colorScheme, jobs[index]);
      },
    );
  }

  // Helper for narrow screen jobs display
  Widget _buildNarrowJobsList(BuildContext context, TextTheme textTheme, ColorScheme colorScheme, List<JobItem> jobs) {
    return Column(
      children: jobs.take(3).map((job) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildJobPreviewCard(context, textTheme, colorScheme, job),
        );
      }).toList(),
    );
  }

  // Job card design for the home screen preview
  Widget _buildJobPreviewCard(BuildContext context, TextTheme textTheme, ColorScheme colorScheme, JobItem job) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/jobs/${job.id}'), // Navigate to job detail
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      job.title,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (job.paymentDetails != null && job.paymentDetails!.isNotEmpty)
                    Expanded(
                      flex: 1,
                      child: Text(
                        job.paymentDetails!,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                job.description,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, y').format(job.createdAt),
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward, size: 16, color: colorScheme.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper for News Column using FutureBuilder ---
  Widget _buildNewsColumnWithFuture(BuildContext context, TextTheme textTheme, ColorScheme colorScheme, Future<List<NewsItem>> future) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Latest News', style: textTheme.titleLarge),
        const SizedBox(height: 15),
        // *** INTEGRATED FutureBuilder HERE ***
        FutureBuilder<List<NewsItem>>(
          future: future, // <-- PASS THE FUTURE HERE
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()));
            } else if (snapshot.hasError) {
              print("Error loading news for home screen: ${snapshot.error}");
              return Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Text('Could not load news.', style: textTheme.bodyMedium)));
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final newsList = snapshot.data!;
              return Column( // Wrap list items in a Column
                children: newsList.take(2).map((newsItem) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildNewsEventCard(
                      context, textTheme, colorScheme,
                      newsItem.title,
                      newsItem.content ?? 'No preview available.',
                      DateFormat('MMM d, yyyy').format(newsItem.publishedAt),
                      newsId: newsItem.id // Pass the real ID
                  ),
                )).toList(),
              );
            } else {
              return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('No recent news.')));
            }
          },
        ),
        // ------------------------------------
        const SizedBox(height: 10),
        // View All Button (outside FutureBuilder, shown regardless of items)
        _buildViewAllButton(context, 'View All News', '/news-archive'),
      ],
    );
  }


  // --- Placeholder Helper for Events Column ---
  Widget _buildPlaceholderEventsColumn(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
     // Using placeholder data defined in user's provided code state
     final List<Map<String, String>> placeholderEvents = const [
       {'title': 'Farmers Market', 'snippet': 'Fresh local produce and crafts. Every Friday morning.', 'date': 'Next: Apr 5'},
       {'title': 'Village Council Meeting', 'snippet': 'Open session to discuss community matters.', 'date': 'Apr 10, 7 PM'},
     ];

     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
          Text('Upcoming Events', style: textTheme.titleLarge),
          const SizedBox(height: 15),
          // Use the placeholder data directly
          if (placeholderEvents.isEmpty)
            Padding(
               padding: const EdgeInsets.symmetric(vertical: 20.0),
               child: Text('No upcoming events listed.', style: textTheme.bodyMedium),
            )
          else
            ...placeholderEvents.take(2).map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildNewsEventCard(
                context, textTheme, colorScheme,
                item['title']!, item['snippet']!, item['date']!,
                // No newsId for placeholder events
              ),
            )).toList(),
          const SizedBox(height: 10),
          // Use the View All Button helper
          _buildViewAllButton(context, 'View All Events', '/community-hub'), // Link to hub for now
       ],
     );
   }

  // Helper for individual News/Event Card
  Widget _buildNewsEventCard(BuildContext context, TextTheme textTheme, ColorScheme colorScheme, String title, String snippet, String date, {String? newsId}) {
    // Keeping user's provided code state for this helper
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
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
          child: Column( // Using Column as in user's code
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(date, style: textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor)),
              const SizedBox(height: 8),
              Text(snippet, style: textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Align(
                 alignment: Alignment.centerRight,
                 // Conditionally show arrow
                 child: newsId != null
                    ? Icon(Icons.arrow_forward, size: 16, color: colorScheme.primary)
                    : const SizedBox(height: 16) // Placeholder to maintain height if no arrow
               ),
            ],
          ),
        ),
      ),
    );
  }

   // "View All" Button Helper
  Widget _buildViewAllButton(BuildContext context, String text, String route) {
     return Align(
       alignment: Alignment.centerRight,
       child: Padding(
         padding: const EdgeInsets.only(top: 10.0),
         child: TextButton(
           onPressed: () {
              context.go(route);
           },
           child: Text(text),
         ),
       ),
     );
   }

} // End of _HomeScreenState class