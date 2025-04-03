import 'package:flutter/material.dart';
import '../widgets/main_drawer.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  // Placeholder data - replace with dynamic data later
  final List<String> placeholderImageUrls = const [
    'https://via.placeholder.com/300/A5D6A7/000000?text=Village+View+1',
    'https://via.placeholder.com/300/81C784/000000?text=Festival+2024',
    'https://via.placeholder.com/300/4CAF50/000000?text=Local+Park',
    'https://via.placeholder.com/300/66BB6A/000000?text=Market+Day',
    'https://via.placeholder.com/300/388E3C/000000?text=Old+Temple',
    'https://via.placeholder.com/300/2E7D32/000000?text=Sunset',
    'https://via.placeholder.com/300/1B5E20/000000?text=Harvest+Time',
    'https://via.placeholder.com/300/C8E6C9/000000?text=Children+Playing',
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vemulapally Gallery'),
      ),
      drawer: const MainDrawer(),
      body: Center( // Center content
        child: Container( // Constrain width
          constraints: const BoxConstraints(maxWidth: 1200),
          // Use LayoutBuilder to determine grid columns based on width
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Determine number of columns based on available width
              int crossAxisCount = 2; // Default for narrow screens
              if (constraints.maxWidth > 1100) {
                crossAxisCount = 4;
              } else if (constraints.maxWidth > 700) {
                crossAxisCount = 3;
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16.0), // Padding around the grid
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount, // Number of columns
                  crossAxisSpacing: 12.0, // Horizontal space between items
                  mainAxisSpacing: 12.0, // Vertical space between items
                  childAspectRatio: 1.0, // Make items square (adjust as needed)
                ),
                itemCount: placeholderImageUrls.length, // Use placeholder data length
                itemBuilder: (BuildContext context, int index) {
                  // Build each grid item
                  return Card(
                    clipBehavior: Clip.antiAlias, // Clip the image to the card shape
                    elevation: 3,
                    child: InkWell(
                      onTap: () {
                        // Implement lightbox/detail view later
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tapped image ${index + 1}')),
                        );
                      },
                      child: GridTile(
                        // Optional Footer for image title/caption
                        // footer: GridTileBar(
                        //   backgroundColor: Colors.black45,
                        //   title: Text('Image ${index + 1}', style: TextStyle(fontSize: 12)),
                        // ),
                        child: Image.network( // Load placeholder image
                          placeholderImageUrls[index],
                          fit: BoxFit.cover, // Cover the grid tile area
                          // Add loading builder for better UX
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              ),
                            );
                          },
                           errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}