import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart'; // Make sure to import google_fonts

// --- Import Screens ---
// Import the screens used in the router configuration
import 'screens/home_screen.dart';
import 'screens/about_screen.dart';
import 'screens/community_hub_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/news_archive_screen.dart'; // <-- IMPORT NEW SCREEN
import 'screens/news_detail_screen.dart';  // <-- IMPORT NEW SCREEN

import 'screens/job_board_screen.dart'; // <-- IMPORT NEW SCREEN
import 'screens/job_detail_screen.dart'; // <-- IMPORT NEW SCREEN
import 'screens/post_job_screen.dart';   // <-- IMPORT NEW SCREEN



// --- Define Colors (constants maybe) ---
// These colors are used in the ThemeData below
const Color colorOffWhite = Color(0xFFFAF6F1); // Approximate background
const Color colorTerracotta = Color(0xFFD38C6D); // Approximate accent/button color
const Color colorDarkText = Color(0xFF333333); // Dark text color
const Color colorSubtleText = Color(0xFF757575); // Lighter text
const Color colorIllustrationGreen = Color(0xFF5A8A71); // Green from illustrations
const Color colorIllustrationBrown = Color(0xFF8D6E63); // Brown from illustrations


// --- Main Entry Point ---
void main() {
  // Potential Initialization (e.g., Supabase, other services)
  // WidgetsFlutterBinding.ensureInitialized();
  // await Supabase.initialize(...)

  runApp(const VillageApp()); // Run the main Flutter application
}

// --- GoRouter Configuration ---
// Defines the routes and corresponding screen builders for the application
final GoRouter _router = GoRouter(
  // Default error screen for routes that are not found
  errorBuilder: (context, state) => const NotFoundScreen(),
  // List of top-level routes
  routes: <GoRoute>[
    GoRoute(
      path: '/', // Root path maps to HomeScreen
      builder: (BuildContext context, GoRouterState state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/about', // '/about' path maps to AboutScreen
      builder: (BuildContext context, GoRouterState state) => const AboutScreen(),
    ),
    GoRoute(
      path: '/community-hub', // '/community-hub' maps to CommunityHubScreen
      builder: (BuildContext context, GoRouterState state) => const CommunityHubScreen(),
    ),
    GoRoute(
      path: '/gallery', // '/gallery' maps to GalleryScreen
      builder: (BuildContext context, GoRouterState state) => const GalleryScreen(),
    ),
    GoRoute(
      path: '/contact', // '/contact' maps to ContactScreen
      builder: (BuildContext context, GoRouterState state) => const ContactScreen(),
    ),
    GoRoute(
      path: '/news-archive', // Route for the list of all news
      builder: (BuildContext context, GoRouterState state) => const NewsArchiveScreen(),
    ),
    GoRoute(
      path: '/news/:id', // Route for a single news item, ":id" is a path parameter
      builder: (BuildContext context, GoRouterState state) {
        // Extract the 'id' parameter from the route state
        final String newsId = state.pathParameters['id'] ?? 'error'; // Provide default or handle error
        if (newsId == 'error') {
            // Optional: Redirect to error page or show inline error
             return const NotFoundScreen(message: 'News ID missing in route.');
        }
        return NewsDetailScreen(newsId: newsId); // Pass the ID to the screen
      },
    ),
    GoRoute(
      path: '/jobs', // Main job board listing
      builder: (BuildContext context, GoRouterState state) => const JobBoardScreen(),
    ),
    GoRoute(
      path: '/jobs/:id', // Detail view for a single job
      builder: (BuildContext context, GoRouterState state) {
        final String jobId = state.pathParameters['id'] ?? 'error';
        if (jobId == 'error') {
             return const NotFoundScreen(message: 'Job ID missing in route.');
        }
        return JobDetailScreen(jobId: jobId); // Pass ID to screen
      },
    ),
     GoRoute(
      path: '/post-job', // Screen to create a new job posting
      builder: (BuildContext context, GoRouterState state) => const PostJobScreen(),
    ),
     // Add other routes (e.g., for Job Board, Auth) here later
  ],
);


// --- Main Application Widget ---
class VillageApp extends StatelessWidget {
  // Constructor for the VillageApp widget
  const VillageApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Using MaterialApp.router integrates GoRouter for navigation
    return MaterialApp.router(
      // Title displayed in browser tabs or task manager
      title: 'Vemulapally Village',
      // Hide the debug banner in the top-right corner
      debugShowCheckedModeBanner: false,

      // --- Application Theme ---
      // Defines the overall visual appearance of the application
      theme: ThemeData(
        scaffoldBackgroundColor: colorOffWhite, // Set the default background color for Scaffolds
        // Define the application's color scheme using Material 3 principles
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorIllustrationGreen, // Base color for generating the scheme
          primary: colorIllustrationGreen,   // Primary interactive color
          secondary: colorTerracotta,       // Secondary accent color
          background: colorOffWhite,        // Overall background color
          surface: Colors.white,            // Background color for components like Cards, Dialogs
          onPrimary: Colors.white,          // Text/icon color on primary background
          onSecondary: Colors.white,        // Text/icon color on secondary background
          onBackground: colorDarkText,      // Text/icon color on background color
          onSurface: colorDarkText,         // Text/icon color on surface color
          brightness: Brightness.light,     // Use the light theme mode
        ),
        // Define the application's text styling using Google Fonts
        textTheme: GoogleFonts.latoTextTheme( // Set Lato as the base font family
            Theme.of(context).textTheme, // Start with the default Flutter text theme
          ).apply( // Apply default colors to all text styles
            bodyColor: colorDarkText,      // Default color for body text
            displayColor: colorDarkText,   // Default color for display text (headlines)
          ).copyWith( // Customize specific text styles
            headlineSmall: GoogleFonts.playfairDisplay( // Use Playfair Display for small headlines
              fontWeight: FontWeight.bold,
              color: colorDarkText,
              // fontSize: 24, // Optional: Override default size
            ),
            titleLarge: GoogleFonts.playfairDisplay( // Use Playfair Display for large titles
               fontWeight: FontWeight.w600,
               color: colorDarkText,
               // fontSize: 20, // Optional: Override default size
            ),
            titleMedium: GoogleFonts.lato( // Use Lato Bold for medium titles (e.g., card titles)
              fontWeight: FontWeight.bold,
               color: colorDarkText,
            ),
            bodyMedium: GoogleFonts.lato( // Use Lato for standard body text
              color: colorSubtleText,     // Use the lighter text color
              fontSize: 15,
              height: 1.5,                // Set line height for better readability
            ),
             labelLarge: GoogleFonts.lato( // Use Lato Bold for button labels
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
             titleSmall: GoogleFonts.lato( // Use Lato Semibold for header links/small titles
              fontWeight: FontWeight.w600,
              color: colorDarkText,
              fontSize: 14,
            )
          ),
        // Define the appearance of the AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,          // White background for a clean look
          foregroundColor: colorDarkText,         // Color for icons and text within the AppBar
          elevation: 1.0,                       // Subtle shadow below the AppBar
          scrolledUnderElevation: 1.0,          // Elevation when content scrolls under
          surfaceTintColor: Colors.transparent, // Prevent color tinting when scrolling under
          iconTheme: IconThemeData(color: colorDarkText),     // Color for leading/trailing icons
          actionsIconTheme: IconThemeData(color: colorDarkText), // Color for action icons
          centerTitle: false,                   // Align title to the left (standard for web)
           titleTextStyle: TextStyle(             // Default style for AppBar title (if not overridden)
               color: colorDarkText, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        // Define the default appearance of Cards
        cardTheme: CardTheme(
          elevation: 0,                       // Flat cards as per the design image
          color: Colors.white,                // White background for cards
          margin: const EdgeInsets.symmetric(vertical: 8), // Default vertical margin
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Rounded corners
        ),
        // Define the default appearance of ElevatedButtons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorTerracotta,   // Button background color
            foregroundColor: Colors.white,      // Button text/icon color
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), // Button padding
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), // Slightly rounded corners
             textStyle: GoogleFonts.lato(fontWeight: FontWeight.bold), // Button text style
          ),
        ),
        // Define the default appearance of TextButtons
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: colorDarkText,   // Default color for text buttons
            textStyle: GoogleFonts.lato(fontWeight: FontWeight.w600, fontSize: 14), // Text button style
          )
        ),
        // Use Material 3 design components and styling
        useMaterial3: true,
        // You can add other theme customizations here (e.g., inputDecorationTheme, drawerTheme)
      ),

      // --- Router Configuration ---
      // Pass the configured GoRouter instance to the MaterialApp
      routerConfig: _router,
    );
  }
}