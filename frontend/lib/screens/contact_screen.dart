import 'package:flutter/material.dart';
import '../widgets/main_drawer.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  // GlobalKey to identify the Form and manage its state.
  static final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Vemulapally'),
      ),
      drawer: const MainDrawer(),
      body: Center( // Center content
        child: Container( // Constrain width
          constraints: const BoxConstraints(maxWidth: 900), // Maybe narrower for contact forms
          child: SingleChildScrollView( // Allow scrolling if content overflows
             padding: const EdgeInsets.all(24.0),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: <Widget>[

                 // --- Direct Contact Info Section ---
                  Text(
                    'Get In Touch Directly',
                     style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Card( // Group contact info in a card
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0), // Reduce vertical padding for ListTiles
                      child: Column(
                         children: [
                           ListTile(
                              leading: Icon(Icons.phone_outlined, color: Theme.of(context).colorScheme.primary),
                              title: const Text('Phone'),
                              subtitle: const SelectableText('[Village Council/Office Phone Number]'),
                           ),
                           const Divider(indent: 16, endIndent: 16),
                            ListTile(
                              leading: Icon(Icons.email_outlined, color: Theme.of(context).colorScheme.primary),
                              title: const Text('Email'),
                              subtitle: const SelectableText('[Village Council/Office Email Address]'),
                           ),
                            const Divider(indent: 16, endIndent: 16),
                           ListTile(
                              leading: Icon(Icons.location_on_outlined, color: Theme.of(context).colorScheme.primary),
                              title: const Text('Office Address'),
                              subtitle: const SelectableText('[Village Council/Office Address Details]'),
                           ),
                         ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Divider(height: 20),
                  const SizedBox(height: 30),


                 // --- Contact Form Section ---
                  Text(
                    'Send Us a Message',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Card( // Group form fields in a card
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey, // Assign the key to the Form
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch, // Make button stretch
                          children: <Widget>[
                            // Name Field
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Your Name',
                                hintText: 'Enter your full name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                              // onSaved: (value) => _name = value, // Save value later
                            ),
                            const SizedBox(height: 16),

                            // Email Field
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Your Email',
                                hintText: 'Enter your email address',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your email';
                                }
                                // Basic email format check
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                   return 'Please enter a valid email address';
                                }
                                return null;
                              },
                              // onSaved: (value) => _email = value,
                            ),
                            const SizedBox(height: 16),

                             // Subject Field (Optional)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Subject',
                                hintText: 'Enter the message subject',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.subject_outlined),
                              ),
                               validator: (value) { // Make subject optional or required
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a subject';
                                }
                                return null;
                              },
                              // onSaved: (value) => _subject = value,
                            ),
                            const SizedBox(height: 16),

                            // Message Field
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Your Message',
                                hintText: 'Enter your message here...',
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true, // Good for multi-line fields
                                // prefixIcon: Icon(Icons.message_outlined), // Icon might look odd here
                              ),
                              maxLines: 5, // Allow multiple lines
                              minLines: 3,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your message';
                                }
                                if (value.trim().length < 10) {
                                  return 'Message should be at least 10 characters long';
                                }
                                return null;
                              },
                              // onSaved: (value) => _message = value,
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            ElevatedButton.icon(
                              icon: const Icon(Icons.send_outlined),
                              label: const Text('Send Message'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16), // Make button taller
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                              onPressed: () {
                                // Validate returns true if the form is valid, or false otherwise.
                                if (_formKey.currentState!.validate()) {
                                  // If the form is valid, display a snackbar. In a real app,
                                  // you'd often call _formKey.currentState!.save() and
                                  // then send the data to your backend API.
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Sending Message... (Placeholder)')),
                                  );
                                  // Add API call logic here later
                                } else {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please correct the errors above.')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
               ],
             ),
          ),
        ),
      ),
    );
  }
}