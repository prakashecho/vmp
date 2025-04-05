import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotFoundScreen extends StatelessWidget {
  final String? message; // <-- ADD optional message field

  // <-- UPDATE constructor to accept the message -->
  const NotFoundScreen({this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Padding( // Add padding for better spacing
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon( // Add an icon for visual feedback
                Icons.error_outline,
                color: Colors.red[400],
                size: 60,
              ),
              const SizedBox(height: 20),
              Text(
                // <-- DISPLAY the message if provided, otherwise show default -->
                message ?? 'Oops! The page you requested could not be found.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon( // Add icon to button
                icon: const Icon(Icons.home_outlined),
                label: const Text('Go to Homepage'),
                onPressed: () => context.go('/'), // Navigate home
              ),
            ],
          ),
        ),
      ),
    );
  }
}