import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import go_router

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Oops! The page you requested could not be found.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/'), // Navigate home
              child: const Text('Go to Homepage'),
            ),
          ],
        ),
      ),
    );
  }
}