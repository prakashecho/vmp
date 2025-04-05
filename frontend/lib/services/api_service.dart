import 'dart:convert'; // For jsonDecode
import 'package:http/http.dart' as http; // Use http package
import '../models/news_item.dart'; // Import your NewsItem model
import '../models/job_item.dart'; // <-- IMPORT JOB MODEL

class ApiService {
  // Replace with your actual Go backend URL if deployed or different locally
  // IMPORTANT: For Android emulator, use 10.0.2.2 instead of localhost
  // Use http, not https, for local development unless you set up certificates
  final String baseUrl = "http://localhost:8081/api/v1";

  // Fetches the list of published news items
  Future<List<NewsItem>> fetchNews() async {
    final response = await http.get(Uri.parse('$baseUrl/news'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON.
      // The newsItemFromJson helper function decodes the list.
      print("API Response Body: ${response.body}"); // Log response for debugging
      return newsItemFromJson(response.body);
    } else {
      // If the server did not return a 200 OK response,
      // throw an exception.
      print("API Error: ${response.statusCode} ${response.reasonPhrase}"); // Log error
      throw Exception('Failed to load news (${response.statusCode})');
    }
  }
   Future<NewsItem> fetchNewsById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/news/$id'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the single JSON object.
      print("API Response Body (fetchNewsById): ${response.body}");
      return NewsItem.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
        print("API Error (fetchNewsById): 404 Not Found for ID $id");
        throw Exception('News item not found (404)'); // Specific error for not found
    }
    else {
      // For other errors
      print("API Error (fetchNewsById): ${response.statusCode} ${response.reasonPhrase}");
      throw Exception('Failed to load news item $id (${response.statusCode})');
    }
  }
  // Fetches the list of open job items
  Future<List<JobItem>> fetchOpenJobs() async {
    final response = await http.get(Uri.parse('$baseUrl/jobs')); // Call GET /jobs

    if (response.statusCode == 200) {
      print("API Response Body (fetchOpenJobs): ${response.body}");
      return jobItemFromJson(response.body); // Use the job helper
    } else {
      print("API Error (fetchOpenJobs): ${response.statusCode} ${response.reasonPhrase}");
      throw Exception('Failed to load jobs (${response.statusCode})');
    }
  }

  // Fetches a single job item by its ID
  Future<JobItem> fetchJobById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/jobs/$id')); // Call GET /jobs/:id

    if (response.statusCode == 200) {
      print("API Response Body (fetchJobById): ${response.body}");
      return JobItem.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
        print("API Error (fetchJobById): 404 Not Found for ID $id");
        throw Exception('Job not found (404)');
    }
    else {
      print("API Error (fetchJobById): ${response.statusCode} ${response.reasonPhrase}");
      throw Exception('Failed to load job $id (${response.statusCode})');
    }
  }

  // Creates a new job posting
  // Takes a Map representing the CreateJobRequest structure
  Future<JobItem> createJob(Map<String, dynamic> jobData) async {
     final response = await http.post(
      Uri.parse('$baseUrl/jobs'), // Call POST /jobs
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8', // Set content type
      },
      body: jsonEncode(jobData), // Encode the Map to JSON
    );

    if (response.statusCode == 201) { // Check for 201 Created status
      print("API Response Body (createJob): ${response.body}");
      // If the server returns a 201 CREATED response, parse the JSON.
      return JobItem.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 201 CREATED response, throw an exception.
       print("API Error (createJob): ${response.statusCode} ${response.reasonPhrase} Body: ${response.body}");
      // Try to decode error message from backend if available
      String errorMessage = 'Failed to post job (${response.statusCode})';
      try {
         final errorBody = jsonDecode(response.body);
         if (errorBody['error'] != null) {
           errorMessage += ': ${errorBody['error']}';
           if (errorBody['details'] != null) {
             errorMessage += ' (${errorBody['details']})';
           }
         }
      } catch (e) { /* Ignore decoding errors */ }
      throw Exception(errorMessage);
    }
  }

  // Add other API methods here later (fetchEvents, fetchJobs, etc.)
}