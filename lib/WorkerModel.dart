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
  final bool approved;     

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
    required this.approved,
  });

  factory Worker.fromMap(String id, Map<String, dynamic> data) {
    return Worker(
      id: id,
      name: data['name']?.toString() ?? '',
      service: data['service']?.toString() ?? '',
      experience: data['experience']?.toString() ?? '0',
      phone: data['phone']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      address: data['address']?.toString() ?? 'No address provided',
      rating: (data['rating'] is num)
          ? (data['rating'] as num).toDouble()
          : double.tryParse(data['rating']?.toString() ?? '0') ?? 0.0,
      ratingCount: (data['ratingCount'] is num)
          ? (data['ratingCount'] as num).toInt()
          : int.tryParse(data['ratingCount']?.toString() ?? '0') ?? 0,
      feedback: (data['feedback'] != null)
          ? List<String>.from((data['feedback'] as List).map((e) => e.toString()))
          : [],
      approved: data['approved'] is bool ? data['approved'] : false,
    );
  }

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
      'approved': approved,
    };
  }

  factory Worker.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Worker.fromMap(doc.id, data);
  }
}
