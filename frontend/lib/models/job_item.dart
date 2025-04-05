import 'dart:convert';

// Helper to decode a list of jobs
List<JobItem> jobItemFromJson(String str) =>
    List<JobItem>.from(json.decode(str).map((x) => JobItem.fromJson(x)));

// Represents a single Job posting from the API
class JobItem {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String title;
  final String description;
  final String? location; // Nullable
  final String? paymentDetails; // Nullable
  final String contactInfo;
  final String status;
  final String? postedByUserId; // Nullable
  final DateTime? expiresAt; // Nullable

  JobItem({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.description,
    this.location,
    this.paymentDetails,
    required this.contactInfo,
    required this.status,
    this.postedByUserId,
    this.expiresAt,
  });

  factory JobItem.fromJson(Map<String, dynamic> json) => JobItem(
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        title: json["title"],
        description: json["description"],
        location: json["location"], // Assign directly
        paymentDetails: json["payment_details"], // Assign directly
        contactInfo: json["contact_info"],
        status: json["status"],
        postedByUserId: json["posted_by_user_id"], // Assign directly
        // Parse expiresAt only if it's not null
        expiresAt: json["expires_at"] == null ? null : DateTime.parse(json["expires_at"]),
      );

  // Optional: toJson method if you need to send the full object back
  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "title": title,
        "description": description,
        "location": location,
        "payment_details": paymentDetails,
        "contact_info": contactInfo,
        "status": status,
        "posted_by_user_id": postedByUserId,
        "expires_at": expiresAt?.toIso8601String(), // Use null-aware call
      };
}