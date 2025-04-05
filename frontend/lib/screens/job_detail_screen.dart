import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/job_item.dart';
import '../services/api_service.dart';

class JobDetailScreen extends StatefulWidget {
  final String jobId;

  const JobDetailScreen({required this.jobId, super.key});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<JobItem> _jobDetailFuture;

  @override
  void initState() {
    super.initState();
    _jobDetailFuture = _apiService.fetchJobById(widget.jobId);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () {
            if(context.canPop()) context.pop(); else context.go('/jobs');
        }),
        title: const Text('Job Details'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: FutureBuilder<JobItem>(
            future: _jobDetailFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading job details: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final job = snapshot.data!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.title, style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      // Row for Posted Date and Status
                      Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined, size: 14, color: Theme.of(context).hintColor),
                                const SizedBox(width: 6),
                                Text(
                                  'Posted: ${DateFormat('MMMM d, yyyy').format(job.createdAt)}',
                                  style: textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
                                ),
                              ],
                            ),
                            // Display Status Chip
                             Chip(
                               label: Text(job.status, style: textTheme.labelSmall?.copyWith(color: Colors.white)),
                               backgroundColor: job.status == 'Open' ? Colors.green[600] : Colors.grey[600],
                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                               visualDensity: VisualDensity.compact,
                             ),
                         ],
                      ),
                      const Divider(height: 30, thickness: 1),

                      // Description Section
                      Text('Description', style: textTheme.titleLarge),
                      const SizedBox(height: 8),
                      SelectableText(
                        job.description,
                        style: textTheme.bodyLarge?.copyWith(height: 1.6),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 25),

                      // Location Section (if available)
                      if(job.location != null && job.location!.isNotEmpty) ...[
                         Text('Location', style: textTheme.titleLarge),
                         const SizedBox(height: 8),
                          Row(
                             children: [
                               Icon(Icons.location_on_outlined, size: 16, color: Theme.of(context).hintColor),
                               const SizedBox(width: 6),
                               Expanded(child: SelectableText(job.location!, style: textTheme.bodyLarge)),
                             ],
                          ),
                         const SizedBox(height: 25),
                      ],

                       // Payment Section (if available)
                      if(job.paymentDetails != null && job.paymentDetails!.isNotEmpty) ...[
                         Text('Payment Details', style: textTheme.titleLarge),
                         const SizedBox(height: 8),
                         Row(
                             children: [
                               Icon(Icons.currency_rupee_outlined, size: 16, color: Theme.of(context).hintColor), // Adjust icon if needed
                               const SizedBox(width: 6),
                               Expanded(child: SelectableText(job.paymentDetails!, style: textTheme.bodyLarge)),
                             ],
                          ),
                         const SizedBox(height: 25),
                      ],

                       // Contact Info Section
                       Text('How to Apply / Contact', style: textTheme.titleLarge),
                       const SizedBox(height: 8),
                        Row(
                           children: [
                              Icon(Icons.contact_phone_outlined, size: 16, color: Theme.of(context).hintColor),
                              const SizedBox(width: 6),
                              Expanded(child: SelectableText(job.contactInfo, style: textTheme.bodyLarge)),
                           ],
                        ),
                       const SizedBox(height: 30),
                    ],
                  ),
                );
              } else {
                return const Center(child: Text('Could not load job details.'));
              }
            },
          ),
        ),
      ),
    );
  }
}