import 'package:flutter/material.dart';
import '../widgets/main_drawer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Vemulapally'),
      ),
      drawer: const MainDrawer(),
      body: Center( // Center content
        child: Container( // Constrain width
          constraints: const BoxConstraints(maxWidth: 1100),
          child: ListView( // Use ListView for scrolling
            padding: const EdgeInsets.all(24.0),
            children: <Widget>[
              // --- General Overview ---
              Text(
                'Our Village: Vemulapally',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              // Use SelectableText for web so users can copy text
              const SelectableText(
                'Welcome to Vemulapally! Nestled in [Region/District Name], our village boasts a rich history and a vibrant community spirit. Explore our scenic surroundings, learn about our heritage, and connect with local life. \n\nPopulation: [Approx Population] | Area: [Approx Area]',
                style: TextStyle(fontSize: 16, height: 1.5), // Increased line height
              ),
              const SizedBox(height: 25),

              // --- Map Placeholder ---
              Text('Location', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              Container(
                height: 300, // Adjust height
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Icon(Icons.map_outlined, size: 40, color: Colors.grey),
                       SizedBox(height: 10),
                       Text('Interactive Map Placeholder\n(Requires integration)', textAlign: TextAlign.center),
                    ],
                  )
                ),
              ),
              const Divider(height: 40, thickness: 1),

              // --- History Section ---
              // Use Card for better visual separation of ExpansionTile
              Card(
                clipBehavior: Clip.antiAlias, // Ensures ExpansionTile respects card shape
                child: ExpansionTile(
                  //backgroundColor: Colors.white, // Optional: background color
                  //collapsedBackgroundColor: Colors.white, // Optional
                  shape: const Border(), // Remove default border of ExpansionTile if inside Card
                  title: Text('Village History', style: Theme.of(context).textTheme.titleLarge),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                     SelectableText(
                      'Vemulapally\'s roots trace back to [Time Period/Event]. Over the centuries, it has witnessed [Significant Event 1], [Significant Event 2], and the development of [Key Industry/Feature]. Discover landmarks like [Landmark 1] and learn about the figures who shaped our community.',
                      style: TextStyle(fontSize: 15, height: 1.4),
                    ),
                    // Add more paragraphs or images here
                  ],
                ),
              ),
              const SizedBox(height: 20), // Space between cards

              // --- Council Info Section ---
               Card(
                 clipBehavior: Clip.antiAlias,
                 child: ExpansionTile(
                    shape: const Border(),
                    title: Text('Village Council', style: Theme.of(context).textTheme.titleLarge),
                    childrenPadding: const EdgeInsets.only(bottom: 10), // Only bottom padding needed if using ListTiles
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                       const Padding(
                         padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                         child: SelectableText(
                          'The Vemulapally Village Council is responsible for [brief description]. Meetings are typically held [frequency/time].',
                           style: TextStyle(fontSize: 15, height: 1.4),
                         ),
                       ),
                       const Divider(height: 1),
                       const Padding(
                         padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                         child: Text('Council Members:', style: TextStyle(fontWeight: FontWeight.bold)),
                       ),
                       ListTile(leading: const Icon(Icons.person_outline), title: const Text('Sarpanch Name'), subtitle: const Text('Sarpanch')),
                       ListTile(leading: const Icon(Icons.person_outline), title: const Text('Deputy Sarpanch Name'), subtitle: const Text('Deputy Sarpanch')),
                       ListTile(leading: const Icon(Icons.person_outline), title: const Text('Ward Member 1'), subtitle: const Text('Ward 1')),
                       // Add more members...
                       const Divider(height: 1),
                       const Padding(
                         padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                         child: Text('Meeting Minutes:', style: TextStyle(fontWeight: FontWeight.bold)),
                       ),
                       ListTile(
                          leading: const Icon(Icons.description_outlined),
                          title: const Text('Minutes - April 2025'),
                          trailing: const Icon(Icons.download_outlined, size: 20),
                          onTap: (){/* Handle download/view */}
                       ),
                       ListTile(
                          leading: const Icon(Icons.description_outlined),
                          title: const Text('Minutes - March 2025'),
                          trailing: const Icon(Icons.download_outlined, size: 20),
                          onTap: (){/* Handle download/view */}
                       ),
                       const Divider(height: 1),
                       const Padding(
                         padding: EdgeInsets.fromLTRB(16, 12, 16, 12), // Add bottom padding
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                              Text('Contact Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              SelectableText('Phone: [Council Phone Number]\nEmail: [Council Email Address]\nOffice: [Council Office Address]'),
                           ],
                         ),
                       ),
                    ],
                  ),
               ),
               const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}