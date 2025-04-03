import 'dart:convert'; // Required for jsonDecode

// Function to decode the JSON list
List<NewsItem> newsItemFromJson(String str) =>
    List<NewsItem>.from(json.decode(str).map((x) => NewsItem.fromJson(x)));

// Represents a single news item fetched from the API
class NewsItem {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String title;
  final String? content; // Nullable String
  final DateTime publishedAt;
  final String status;

  NewsItem({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    this.content, // Nullable
    required this.publishedAt,
    required this.status,
  });

  // Factory constructor to create a NewsItem from JSON data
  factory NewsItem.fromJson(Map<String, dynamic> json) => NewsItem(
        id: json["id"],
        // Parse ISO 8601 formatted date strings
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        title: json["title"],
        content: json["content"], // Directly assign nullable string
        publishedAt: DateTime.parse(json["published_at"]),
        status: json["status"],
      );

  // Optional: Method to convert NewsItem back to JSON (if needed later)
  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "title": title,
        "content": content,
        "published_at": publishedAt.toIso8601String(),
        "status": status,
      };
}