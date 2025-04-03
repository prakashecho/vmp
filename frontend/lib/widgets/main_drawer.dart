import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter for navigation

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  // Helper method to create consistently styled drawer list tiles
  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, String routePath) {
    // Get the current route location
    final currentLocation = GoRouterState.of(context).uri.toString();
    // Check if the current route matches the item's route path
    final bool isSelected = currentLocation == routePath;

    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).primaryColor : null), // Highlight icon if selected
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // Highlight text if selected
          color: isSelected ? Theme.of(context).primaryColor : null,
        ),
      ),
      selected: isSelected, // Sets background highlight if selected (theme dependent)
      selectedTileColor: Colors.green.withOpacity(0.1), // Optional: explicit highlight color
      onTap: () {
        // Close the drawer before navigating
        Navigator.of(context).pop();
        // Use GoRouter to navigate to the specified route path
        context.go(routePath);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Remove padding that might interfere with the DrawerHeader
        padding: EdgeInsets.zero,
        children: <Widget>[
          // --- Drawer Header ---
          // A visual header for the drawer, customize as desired
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor, // Use theme's primary color
            ),
            child: Text(
              'Vemulapally Menu', // Title displayed in the header
              style: TextStyle(
                color: Theme.of(context).appBarTheme.foregroundColor, // Use AppBar's text color
                fontSize: 24,
              ),
            ),
          ),

          // --- Navigation Items ---
          // Use the helper method to create each navigation link
          _buildDrawerItem(context, Icons.home_outlined, 'Home', '/'), // Use outlined icons for consistency
          _buildDrawerItem(context, Icons.dashboard_outlined, 'Community Hub', '/community-hub'),
          _buildDrawerItem(context, Icons.info_outline, 'About Vemulapally', '/about'),
          _buildDrawerItem(context, Icons.photo_library_outlined, 'Gallery', '/gallery'),
          _buildDrawerItem(context, Icons.contact_mail_outlined, 'Contact', '/contact'),

          // --- Optional Divider ---
          const Divider(height: 20, thickness: 1),

          // --- Placeholder for future Auth links ---
          // Example:
          // bool isLoggedIn = false; // Replace with actual auth state check later
          // if (isLoggedIn) {
          //   _buildDrawerItem(context, Icons.logout, 'Logout', '/logout');
          // } else {
          //   _buildDrawerItem(context, Icons.login, 'Login/Register', '/login');
          // }

          // --- Placeholder for Job Board link ---
          // _buildDrawerItem(context, Icons.work_outline, 'Job Board', '/jobs'),

        ],
      ),
    );
  }
}