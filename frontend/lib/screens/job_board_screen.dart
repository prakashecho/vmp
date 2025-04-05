import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/job_item.dart';
import '../services/api_service.dart';
import '../widgets/main_drawer.dart';
// Import localizations if set up
// import '.dart_tool/flutter_gen/gen_l10n/app_localizations.dart';


class JobBoardScreen extends StatefulWidget {
  const JobBoardScreen({super.key});

  @override
  State<JobBoardScreen> createState() => _JobBoardScreenState();
}

class _JobBoardScreenState extends State<JobBoardScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<JobItem>> _jobsFuture;

  @override
  void initState() {
    super.initState();
    _jobsFuture = _apiService.fetchOpenJobs(); // Fetch open jobs
  }

  // Helper to refresh data when pulling down
  Future<void> _refreshJobs() async {
    setState(() {
       _jobsFuture = _apiService.fetchOpenJobs();
    });
    // Optionally return the future itself if needed by RefreshIndicator
    // return _jobsFuture;
  }


  @override
  Widget build(BuildContext context) {
    // final localizations = AppLocalizations.of(context)!; // Uncomment if using i18n
    final textTheme = Theme.of(context).textTheme;
    // Use colorScheme for more theme-aware colors
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // Use theme background color
      backgroundColor: colorScheme.surfaceContainerLowest, // Or surfaceContainerLow
      appBar: AppBar(
        // Consider making AppBar match background or slightly different
        // backgroundColor: colorScheme.surface, // Example
        // elevation: 0,
        // title: Text(localizations.screenTitleJobBoard), // Use localized title
        title: const Text('Work Opportunities'), // Hardcoded for now
        actions: [
           // --- ADDED HOME ICON BUTTON ---
           IconButton(
             icon: const Icon(Icons.home_outlined),
             // tooltip: localizations.menuHome, // Use localized tooltip
             tooltip: 'Go Home',
             onPressed: () => context.go('/'), // Navigate home
           ),
           // ----------------------------
           IconButton( // Keep Post Job button
             icon: const Icon(Icons.add_circle_outline),
             // tooltip: localizations.screenTitlePostJob, // Use localized tooltip
             tooltip: 'Post a New Job',
             onPressed: () => context.go('/post-job'),
           ),
           const SizedBox(width: 8), // Spacing before edge
        ],
      ),
      drawer: const MainDrawer(),
      body: Center( // Center the content area
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200), // Adjust max width for grid
          child: RefreshIndicator(
            onRefresh: _refreshJobs,
            color: colorScheme.primary, // Use theme color for indicator
            child: FutureBuilder<List<JobItem>>(
              future: _jobsFuture,
              builder: (context, snapshot) {
                // --- Loading State ---
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // --- Error State ---
                else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: colorScheme.error, size: 40),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load jobs',
                            style: textTheme.titleMedium?.copyWith(color: colorScheme.error),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            // Limit error message length potentially
                            '${snapshot.error}'.length > 100 ? '${snapshot.error}'.substring(0, 100) + '...' : '${snapshot.error}',
                            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                           ElevatedButton.icon(
                             icon: const Icon(Icons.refresh),
                             label: const Text('Retry'),
                             onPressed: _refreshJobs,
                             style: ElevatedButton.styleFrom(
                               backgroundColor: colorScheme.errorContainer,
                               foregroundColor: colorScheme.onErrorContainer,
                             ),
                           )
                        ],
                      ),
                    ),
                  );
                }
                // --- Data State (Not Empty) ---
                else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final jobList = snapshot.data!;

                  return LayoutBuilder(builder: (context, constraints) {
                    int crossAxisCount = 1;
                    if (constraints.maxWidth > 1100) {
                      crossAxisCount = 3;
                    } else if (constraints.maxWidth > 700) {
                      crossAxisCount = 2;
                    }
                    // Calculate aspect ratio dynamically aiming for a certain height
                    double cardWidth = (constraints.maxWidth - (16 * (crossAxisCount + 1))) / crossAxisCount;
                    double cardHeight = 190; // Target card height
                    // Handle potential division by zero or negative width if constraints are unusual
                    double aspectRatio = (cardWidth > 0 && cardHeight > 0) ? cardWidth / cardHeight : 1.0;


                    return GridView.builder(
                      // Add physics to ensure scrolling works with RefreshIndicator
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: aspectRatio,
                      ),
                      itemCount: jobList.length,
                      itemBuilder: (context, index) {
                        final job = jobList[index];
                        return _buildJobGridCard(context, textTheme, colorScheme, job);
                      },
                    );
                  });
                }
                // --- Empty State ---
                else {
                  return LayoutBuilder(
                     // ** CORRECTED LayoutBuilder usage **
                     builder: (context, constraints) => SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                           height: constraints.maxHeight, // Use constraints for height
                           alignment: Alignment.center,
                           padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                           child: Column( // Content for empty state
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Icon(
                                 Icons.work_off_outlined,
                                 size: 60,
                                 color: colorScheme.secondary,
                               ),
                               const SizedBox(height: 20),
                               Text(
                                 'No Open Jobs Found',
                                 style: textTheme.headlineSmall?.copyWith(
                                   color: colorScheme.onSurface,
                                 ),
                                 textAlign: TextAlign.center,
                               ),
                               const SizedBox(height: 10),
                               Text(
                                 'It looks like there are no job opportunities posted right now. Check back later or be the first to post one!',
                                 style: textTheme.bodyMedium?.copyWith(
                                   color: colorScheme.onSurfaceVariant,
                                 ),
                                 textAlign: TextAlign.center,
                               ),
                               const SizedBox(height: 30),
                               ElevatedButton.icon(
                                 icon: const Icon(Icons.add_circle_outline),
                                 label: const Text('Post a New Job'),
                                 onPressed: () => context.go('/post-job'),
                                 style: ElevatedButton.styleFrom(
                                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                   textStyle: textTheme.labelLarge,
                                 ),
                               )
                             ],
                           ),
                         ),
                      )
                   );
                 // --- End of Empty State ---
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widget for Job Card in Grid ---
  Widget _buildJobGridCard(
      BuildContext context, TextTheme textTheme, ColorScheme colorScheme, JobItem job) {
    return Card(
      color: colorScheme.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/jobs/${job.id}'),
        splashColor: colorScheme.primary.withOpacity(0.1),
        highlightColor: colorScheme.onSurface.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Title and Payment
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      job.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (job.paymentDetails != null && job.paymentDetails!.isNotEmpty)
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          job.paymentDetails!,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Description Snippet
              Expanded(
                child: Text(
                  job.description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 3, // Adjust based on desired card height
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),

              // Footer Row (Date and Arrow)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 13,
                          color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          DateFormat('MMM d, yyyy').format(job.createdAt), // Full date format
                          style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios, size: 14, color: colorScheme.primary.withOpacity(0.8)), // Subtle arrow
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} // End of _JobBoardScreenState