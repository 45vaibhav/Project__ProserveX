import 'package:agri/WorkerDetialPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'WorkerModel.dart';

class ServiceProf extends StatelessWidget {
  final String service;

  const ServiceProf({Key? key, required this.service}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F3F7),
      appBar: AppBar(
        title: Text(service),
        backgroundColor: Color(0xFF2980B9),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("workers")
            .where('service', isEqualTo: service)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No workers available",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            );
          }

          final workers = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Worker(
              id: doc.id,
              name: data['name']?.toString() ?? "Unknown",
              service: data['service']?.toString() ?? "Service",
              experience: data['experience']?.toString() ?? "N/A",
              address: data['address']?.toString() ?? "No address provided",
              phone: data['phone']?.toString() ?? "",
              email: data['email']?.toString() ?? "",
              rating: (data['rating'] is num)
                  ? (data['rating'] as num).toDouble()
                  : 0.0,
              ratingCount: data['ratingCount'] is int
                  ? data['ratingCount'] as int
                  : 0,
              feedback: data['feedback'] != null
                  ? List<String>.from(data['feedback'])
                  : [],
            );
          }).toList();

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            itemCount: workers.length,
            itemBuilder: (context, index) {
              final worker = workers[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => WorkerDetailPage(worker: worker)),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Color(0xFF2980B9).withOpacity(0.2),
                        child: Icon(Icons.person,
                            color: Color(0xFF2980B9), size: 26),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              worker.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "${worker.service} | ${worker.experience} yrs exp",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 4),
                            RatingBarIndicator(
                              rating: worker.rating,
                              itemBuilder: (context, _) =>
                                  Icon(Icons.star, color: Colors.amber),
                              itemCount: 5,
                              itemSize: 16,
                            ),
                            SizedBox(height: 2),
                            Text(
                              "(${worker.ratingCount})",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.location_on,
                                    color: Colors.redAccent, size: 16),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    worker.address,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800]),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Icon(Icons.arrow_forward_ios,
                                size: 16, color: Colors.grey[400]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
