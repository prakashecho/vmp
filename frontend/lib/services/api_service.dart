import 'dart:convert'; // For jsonDecode
import 'package:http/http.dart' as http; // Use http package
import '../models/news_item.dart'; // Import your NewsItem model

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

  // Add other API methods here later (fetchEvents, fetchJobs, etc.)
}