// lib/models/contact.dart

import 'package:flutter/foundation.dart';

@immutable
class Contact {
  final int id;
  final String? name;
  final String? email;
  final String? phone;
  final String? company;
  final String? activity; // This is the job title
  final String? address;
  final String? website;
  final String? imageUrl; // The public URL for the card image
  final double confidenceScore;
  final bool needsReview;
  final String status;
  final DateTime createdAt;

  const Contact({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.company,
    this.activity,
    this.address,
    this.website,
    this.imageUrl,
    required this.confidenceScore,
    required this.needsReview,
    required this.status,
    required this.createdAt,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      company: json['company'],
      activity: json['activity'],
      address: json['address'],
      website: json['website'],
      imageUrl: json['image_url'],

      // --- THE FIX IS HERE ---
      // Safely parse the confidence score.
      // double.tryParse will handle strings like "0.90".
      // If it's already a number, .toDouble() will work.
      // We provide a fallback of 0.0 if it's null or invalid.
      confidenceScore:
          double.tryParse(json['confidence_score'].toString()) ?? 0.0,

      // The API sends 0 or 1 for booleans, so we check for 1.
      // This is robust and handles both numbers and booleans.
      needsReview: json['needs_review'] == 1 || json['needs_review'] == true,

      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
