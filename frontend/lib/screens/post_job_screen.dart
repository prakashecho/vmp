import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>(); // Key for managing the form state
  final ApiService _apiService = ApiService();

  // Controllers for text fields
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _paymentController = TextEditingController();
  final _contactController = TextEditingController();

  bool _isLoading = false; // To show loading indicator on button

  @override
  void dispose() {
    // Dispose controllers when the widget is removed
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _paymentController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submitJob() async {
    // Validate the form first
    if (_formKey.currentState!.validate()) {
      // If valid, show loading and call API
      setState(() { _isLoading = true; });

      final jobData = {
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        "location": _locationController.text.trim(), // Send even if empty, backend handles null
        "payment_details": _paymentController.text.trim(), // Send even if empty
        "contact_info": _contactController.text.trim(),
      };

      try {
        // Call the API service to create the job
        final newJob = await _apiService.createJob(jobData);

        // Show success message
        if (mounted) { // Check if widget is still in the tree
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('Job "${newJob.title}" posted successfully!'), backgroundColor: Colors.green[700]),
            );
           // Navigate back to job board after successful post
           context.go('/jobs');
        }
      } catch (e) {
         // Show error message
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error posting job: $e'), backgroundColor: Colors.red[700]),
             );
          }
      } finally {
        // Hide loading indicator whether success or error
        if (mounted) {
           setState(() { _isLoading = false; });
        }
      }
    } else {
       // Form is invalid, show message
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Please fill in all required fields correctly.')),
        );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () {
            if(context.canPop()) context.pop(); else context.go('/jobs');
        }),
        title: const Text('Post a New Work Opportunity'),
      ),
      body: Center(
        child: Container(
           constraints: const BoxConstraints(maxWidth: 700), // Form page can be narrower
           child: SingleChildScrollView(
             padding: const EdgeInsets.all(24.0),
             child: Form(
               key: _formKey, // Assign the key
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.stretch,
                 children: <Widget>[
                   Text('Enter Job Details', style: Theme.of(context).textTheme.headlineSmall),
                   const SizedBox(height: 20),

                   // Title Field
                   TextFormField(
                     controller: _titleController,
                     decoration: const InputDecoration(
                       labelText: 'Job Title*',
                       hintText: 'e.g., Paddy Bag Filling Help',
                       border: OutlineInputBorder(),
                       prefixIcon: Icon(Icons.title),
                     ),
                     validator: (value) {
                       if (value == null || value.trim().isEmpty) {
                         return 'Please enter a job title';
                       }
                       if (value.trim().length < 5) {
                          return 'Title must be at least 5 characters';
                       }
                       return null;
                     },
                   ),
                   const SizedBox(height: 16),

                   // Description Field
                   TextFormField(
                     controller: _descriptionController,
                     decoration: const InputDecoration(
                       labelText: 'Description*',
                       hintText: 'Provide details about the work, skills needed, duration...',
                       border: OutlineInputBorder(),
                       alignLabelWithHint: true,
                     ),
                     maxLines: 4,
                     minLines: 3,
                     validator: (value) {
                       if (value == null || value.trim().isEmpty) {
                         return 'Please enter a description';
                       }
                        if (value.trim().length < 10) {
                          return 'Description must be at least 10 characters';
                       }
                       return null;
                     },
                   ),
                   const SizedBox(height: 16),

                   // Location Field (Optional)
                    TextFormField(
                     controller: _locationController,
                     decoration: const InputDecoration(
                       labelText: 'Location (Optional)',
                       hintText: 'e.g., Field near river bend, Village Square',
                       border: OutlineInputBorder(),
                       prefixIcon: Icon(Icons.location_on_outlined),
                     ),
                     // No validator needed for optional field
                   ),
                   const SizedBox(height: 16),

                   // Payment Details Field (Optional)
                    TextFormField(
                     controller: _paymentController,
                     decoration: const InputDecoration(
                       labelText: 'Payment Details (Optional)',
                       hintText: 'e.g., Rs. 500 per day, Per Bag Rate, Negotiable',
                       border: OutlineInputBorder(),
                       prefixIcon: Icon(Icons.currency_rupee_outlined),
                     ),
                      // No validator needed for optional field
                   ),
                   const SizedBox(height: 16),

                    // Contact Info Field
                   TextFormField(
                     controller: _contactController,
                     decoration: const InputDecoration(
                       labelText: 'Contact Information*',
                       hintText: 'How should interested people contact you? (Phone, Name)',
                       border: OutlineInputBorder(),
                       prefixIcon: Icon(Icons.contact_phone_outlined),
                     ),
                     validator: (value) {
                       if (value == null || value.trim().isEmpty) {
                         return 'Please enter contact information';
                       }
                        if (value.trim().length < 5) {
                          return 'Contact info seems too short';
                       }
                       return null;
                     },
                   ),
                   const SizedBox(height: 30),

                   // Submit Button
                   ElevatedButton.icon(
                     icon: _isLoading
                         ? Container( // Show progress indicator inside button
                             width: 20, height: 20,
                             child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                           )
                         : const Icon(Icons.post_add),
                     label: Text(_isLoading ? 'Posting...' : 'Post Job Listing'),
                     style: ElevatedButton.styleFrom(
                         padding: const EdgeInsets.symmetric(vertical: 16),
                         textStyle: const TextStyle(fontSize: 16),
                     ),
                     // Disable button while loading
                     onPressed: _isLoading ? null : _submitJob,
                   ),
                 ],
               ),
             ),
           ),
        ),
      ),
    );
  }
}