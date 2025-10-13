import 'package:cloud_firestore/cloud_firestore.dart';

class Worker {
  final String id;
  final String name;
  final String service;
  final String experience;
  final String phone;
  final String email;
  final String address;
  final double rating;
  final int ratingCount;
  final List<String> feedback;

  Worker({
    required this.id,
    required this.name,
    required this.service,
    required this.experience,
    required this.phone,
    required this.email,
    required this.address,
    required this.rating,
    required this.ratingCount,
    required this.feedback,
  });

  /// Factory constructor to safely parse data from Firestore
  factory Worker.fromMap(String id, Map<String, dynamic> data) {
    return Worker(
      id: id,
      name: data['name']?.toString() ?? '',
      service: data['service']?.toString() ?? '',
      experience: data['experience']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      address: data['address']?.toString() ?? 'No address provided',

      /// Handles both int and double ratings safely
      rating: (data['rating'] is num)
          ? (data['rating'] as num).toDouble()
          : double.tryParse(data['rating']?.toString() ?? '0') ?? 0.0,

      /// Converts both int or string rating counts safely
      ratingCount: (data['ratingCount'] is int)
          ? data['ratingCount'] as int
          : int.tryParse(data['ratingCount']?.toString() ?? '0') ?? 0,

      /// Converts all feedback items to strings (prevents crash if mixed types)
      feedback: (data['feedback'] != null)
          ? List<String>.from(
              (data['feedback'] as List).map((e) => e.toString()))
          : [],
    );
  }

  /// Convert this Worker to Map (for uploading to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'service': service,
      'experience': experience,
      'phone': phone,
      'email': email,
      'address': address,
      'rating': rating,
      'ratingCount': ratingCount,
      'feedback': feedback,
    };
  }

  /// Helper: Create Worker from Firestore DocumentSnapshot
  factory Worker.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Worker.fromMap(doc.id, data);
  }
}
