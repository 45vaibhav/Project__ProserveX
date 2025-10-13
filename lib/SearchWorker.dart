import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'WorkerModel.dart';
import 'WorkerDetialPage.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Searchworker extends StatefulWidget {
  const Searchworker({Key? key}) : super(key: key);

  @override
  State<Searchworker> createState() => _SearchworkerState();
}

class _SearchworkerState extends State<Searchworker> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final Color deepBlue = Color(0xFF2980B9);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF5FC7ED),
        elevation: 0,
        title: Text(
          "Search Workers",
          style: TextStyle(color: deepBlue, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: deepBlue),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search by name or address...",
                prefixIcon: Icon(Icons.search, color: deepBlue),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Search results
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection("workers").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No workers found"));
                }

                // Map Firestore documents to Worker objects safely
                final workers = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>? ?? {};

                  return Worker(
                    id: doc.id,
                    name: data['name']?.toString() ?? '',
                    service: data['service']?.toString() ?? '',
                    experience: (data['experience'] != null)
                        ? data['experience'].toString()
                        : '0',
                    address: data['address']?.toString() ?? 'No address provided',
                    phone: data['phone']?.toString() ?? '',
                    email: data['email']?.toString() ?? '',
                    rating: (data['rating'] is num)
                        ? (data['rating'] as num).toDouble()
                        : double.tryParse(data['rating']?.toString() ?? '0') ?? 0.0,
                    feedback: (data['feedback'] is List)
                        ? List<String>.from(data['feedback'].map((e) => e.toString()))
                        : [],
                    ratingCount: (data['ratingCount'] is int)
                        ? data['ratingCount'] as int
                        : int.tryParse(data['ratingCount']?.toString() ?? '0') ?? 0,
                  );
                }).where((worker) =>
                    worker.name.toLowerCase().contains(searchQuery) ||
                    worker.address.toLowerCase().contains(searchQuery)
                ).toList();

                if (workers.isEmpty) {
                  return Center(child: Text("No workers match your search"));
                }

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
                              backgroundColor: deepBlue.withOpacity(0.2),
                              child: Icon(Icons.person, color: deepBlue, size: 26),
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
          ),
        ],
      ),
    );
  }
}
