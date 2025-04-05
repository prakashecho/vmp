import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Import localizations if you use them for tooltips/text
// import '.dart_tool/flutter_gen/gen_l10n/app_localizations.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  // Define the links - ADD YOUR ACTUAL LINKS AND ROUTES HERE
  final List<Map<String, String>> navLinks = const [
    // Examples - uncomment and adjust routes as needed
    // {'title': 'NEWS', 'route': '/community-hub'},
     {'title': 'ABOUT', 'route': '/about'},
     {'title': 'GALLERY', 'route': '/gallery'},
     {'title': 'CONTACT', 'route': '/contact'},
  ];

  @override
  Widget build(BuildContext context) {
    // Adjust breakpoint based on how many links you have + "Job Board" button
    final bool isWideScreen = MediaQuery.of(context).size.width > 1000;
    // final localizations = AppLocalizations.of(context); // Uncomment if using i18n

    // Use theme colors for consistency
    final appBarTheme = Theme.of(context).appBarTheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: appBarTheme.backgroundColor ?? Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Center( // Center the content row horizontally
        child: Container( // Constrain the width of the content row
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            // No need for MainAxisAlignment.spaceBetween if using Spacer
            children: <Widget>[
              // --- Logo / Title (Clickable to go home) ---
              InkWell(
                onTap: () => context.go('/'),
                child: Text(
                  'VEMULAPALLY',
                  style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: appBarTheme.foregroundColor, // Use AppBar's text color
                      ),
                ),
              ),

              // Spacer pushes subsequent items to the right
              const Spacer(),

              // --- Navigation Links (Only on wide screens) ---
              if (isWideScreen)
                Row(
                  mainAxisSize: MainAxisSize.min, // Don't take up extra space
                  children: [
                    // Generate link buttons using collection-for
                    for (final link in navLinks)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0), // Spacing between links
                        child: TextButton(
                          onPressed: () => context.go(link['route']!),
                          child: Text(link['title']!),
                          style: Theme.of(context).textButtonTheme.style?.copyWith(
                                foregroundColor: MaterialStateProperty.all(appBarTheme.foregroundColor), // Match AppBar text color
                                textStyle: MaterialStateProperty.all(textTheme.titleSmall), // Use defined text style
                              ),
                        ),
                      ),
                    // Add spacing after the links if they exist and before action buttons
                    if (navLinks.isNotEmpty) const SizedBox(width: 20),
                  ],
                ),

              // --- Action Buttons/Icons (Always visible or adjust logic) ---
              Row(
                mainAxisSize: MainAxisSize.min, // Don't take up extra space
                children: [
                   // --- Job Board Text Button ---
                   TextButton(
                     onPressed: () => context.go('/jobs'),
                     child: Text(
                       /* localizations?.menuJobBoard ?? */ 'WORK', // Use localization if available
                       style: textTheme.titleSmall?.copyWith( // Use appropriate style
                           color: appBarTheme.foregroundColor, // Match AppBar text color
                       )
                     ),
                     style: TextButton.styleFrom(
                       // Optional styling adjustments
                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                     ),
                   ),
                   // ----------------------------------

                   const SizedBox(width: 5), // Small spacing before menu icon

                  // --- Menu Icon ---
                  // Shown on all screen sizes, triggers the drawer
                  IconButton(
                    icon: Icon(Icons.menu, color: appBarTheme.foregroundColor), // Use AppBar icon color
                    tooltip: 'Menu',
                    onPressed: () {
                      // Find the Scaffold ancestor and open its drawer.
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Set the preferred height of the AppBar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10); // Standard AppBar height + padding
}