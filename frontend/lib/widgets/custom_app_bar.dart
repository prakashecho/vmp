import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  final List<Map<String, String>> navLinks = const [
    // {'title': 'NEWS', 'route': '/community-hub'},
    // {'title': 'About Us', 'route': '/about'},
    // {'title': 'BUSINESS', 'route': '/community-hub'},
    // {'title': 'ACTIVITIES', 'route': '/community-hub'},
  ];

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 800;

    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor ?? Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Center( // Center the constrained content
        child: Container( // Constrain width
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // --- Menu Icon (Always show or only on narrow screens) ---
              IconButton(
                icon: const Icon(Icons.menu),
                tooltip: 'Menu', // Accessibility
                onPressed: () {
                  // Open the drawer defined in the Scaffold
                  Scaffold.of(context).openDrawer();
                },
              ),

              // --- Logo ---
              Expanded( // Take available space
                child: Center( // Center the logo within the expanded space
                  child: Text(
                    'VEMULAPALLY', // Replace FOOULI STINCE
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      // fontFamily: 'PlayfairDisplay', // If needed explicitly
                    ),
                  ),
                ),
              ),

              // --- Navigation Links (Show on wide screens) ---
              if (isWideScreen)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: navLinks.map((link) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextButton(
                        onPressed: () => context.go(link['route']!),
                        child: Text(link['title']!),
                        style: Theme.of(context).textButtonTheme.style?.copyWith(
                          textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.titleSmall),
                        ),
                      ),
                    );
                  }).toList(),
                )
              else
                const SizedBox(width: 48), // Placeholder for menu icon width on small screens
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}