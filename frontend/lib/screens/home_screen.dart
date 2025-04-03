import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
// ** REVERT TO STANDARD IMPORT **
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:carousel_slider/carousel_controller.dart' as carousel_slider;

// Import widgets and theme/colors
import '../widgets/main_drawer.dart';
import '../widgets/custom_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Carousel controller
  // ** REVERT TO STANDARD DECLARATION AND INSTANTIATION **
//   final CarouselController _carouselController = CarouselController();
  final carouselController = CarouselController();  // This will use the one from carousel_slider
  int _currentCarouselIndex = 0; // To track current slide for indicators

  // --- Data Placeholders ---
  // Banner Images
  final List<String> bannerImagePaths = [
    'assets/images/banner_illustration.png',
    'assets/images/quicklink_card1.png',
    'assets/images/cf092734-def4-4a5b-b1b9-2318dea4f3bc.png',
    'assets/images/quicklink_card4.png',
  ];

  // News Items Placeholder
  final List<Map<String, String>> newsItems = const [
    {'title': 'Library Expansion Approved', 'snippet': 'Funding secured for a major expansion project...', 'date': 'Apr 3, 2025'},
    {'title': 'Road Cleanup Day Success', 'snippet': 'Thanks to all volunteers who helped out last Saturday!', 'date': 'Apr 1, 2025'},
    {'title': 'New Park Bench Installed', 'snippet': 'Enjoy the new seating near the pond.', 'date': 'Mar 28, 2025'},
  ];

  // Event Items Placeholder
  final List<Map<String, String>> eventItems = const [
    {'title': 'Farmers Market', 'snippet': 'Fresh local produce and crafts. Every Friday morning.', 'date': 'Next: Apr 5'},
    {'title': 'Village Council Meeting', 'snippet': 'Open session to discuss community matters.', 'date': 'Apr 10, 7 PM'},
    {'title': 'Book Club Gathering', 'snippet': 'Discussing "The Midnight Library" at the community hall.', 'date': 'Apr 15, 6 PM'},
  ];
  // --- End Data Placeholders ---


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
      backgroundColor: Color(0xFFD4C4AF),
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
                _buildNewsAndEventsSection(context, textTheme, colorScheme, isWideScreen),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Banner Carousel Widget ---
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
          // Pass the controller
        //   carouselController: carouselController,
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

  // --- Highlights Section Widget ---
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

 // --- News & Events Section Widget ---
  Widget _buildNewsAndEventsSection(BuildContext context, TextTheme textTheme, ColorScheme colorScheme, bool isWide) {
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
                Expanded(child: _buildNewsEventColumn(context, textTheme, colorScheme, 'Latest News', newsItems, '/community-hub')),
                const SizedBox(width: 30),
                Expanded(child: _buildNewsEventColumn(context, textTheme, colorScheme, 'Upcoming Events', eventItems, '/community-hub')),
              ],
            )
          : Column(
              children: [
                 _buildNewsEventColumn(context, textTheme, colorScheme, 'Latest News', newsItems, '/community-hub'),
                 const SizedBox(height: 30),
                 _buildNewsEventColumn(context, textTheme, colorScheme, 'Upcoming Events', eventItems, '/community-hub'),
              ],
            ),
      ],
    );
  }

  // Helper Column builder
  Widget _buildNewsEventColumn(BuildContext context, TextTheme textTheme, ColorScheme colorScheme, String title, List<Map<String, String>> items, String viewAllRoute) {
    return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.titleLarge),
        const SizedBox(height: 15),
        if (items.isEmpty)
          Padding(
             padding: const EdgeInsets.symmetric(vertical: 20.0),
             child: Text('No items to display.', style: textTheme.bodyMedium),
          )
        else
          ...items.take(2).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildNewsEventCard(context, textTheme, colorScheme, item['title']!, item['snippet']!, item['date']!),
          )).toList(),
        const SizedBox(height: 10),
        if (items.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.go(viewAllRoute),
              child: const Text('View All'),
            ),
          )
      ],
    );
  }

  // Helper Card builder
  Widget _buildNewsEventCard(BuildContext context, TextTheme textTheme, ColorScheme colorScheme, String title, String snippet, String date) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () { /* Navigate to detail */ },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
                 child: Icon(Icons.arrow_forward, size: 16, color: colorScheme.primary),
               ),
            ],
          ),
        ),
      ),
    );
  }

} // End of _HomeScreenState class