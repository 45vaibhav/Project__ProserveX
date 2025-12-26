import 'package:ProserveX/Paymentpage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkerProfilePage extends StatefulWidget {
  final String workerId;

  const WorkerProfilePage({super.key, required this.workerId});

  @override
  State<WorkerProfilePage> createState() => _WorkerProfilePageState();
}

class _WorkerProfilePageState extends State<WorkerProfilePage> {
  double _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _submitting = false;

  final String adminPhone = "+917498146954";

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _submitAndPay() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a rating")),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final docRef =
          FirebaseFirestore.instance.collection('workers').doc(widget.workerId);

      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        throw Exception("Worker does not exist.");
      }

      final data = snapshot.data() ?? {};
      double oldRating = (data['rating'] ?? 0).toDouble();
      int ratingCount = (data['ratingCount'] ?? 0).toInt();
      double newAvg =
          ((oldRating * ratingCount) + _rating) / (ratingCount + 1);

      await docRef.update({
        'rating': newAvg,
        'ratingCount': ratingCount + 1,
        'feedback': _feedbackController.text.trim().isEmpty
            ? null
            : _feedbackController.text.trim(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      final user = FirebaseAuth.instance.currentUser;
      final userName = user?.displayName ?? user?.email ?? 'Unknown User';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BasicPaymentPage(
            workerId: widget.workerId,
            workerName: data['name'] ?? 'Worker',
            service: data['service'] ?? 'Service',
            userName: userName,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }

  Future<void> _callAdmin() async {
    final Uri uri = Uri(scheme: 'tel', path: adminPhone);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open dialer")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Worker Profile"),
        backgroundColor: const Color(0xFF2980B9),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('workers')
            .doc(widget.workerId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Worker not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          (data['name'] ?? 'W')[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow("Name", data['name']),
                    _buildInfoRow("Service", data['service']),
                    _buildInfoRow("Location", data['location']),
                    _buildInfoRow("Experience", "${data['experience']} years"),
                    _buildInfoRow(
                        "Approved",
                        data['approved'] == true ? "✅ Yes" : "⏳ Pending"),
                    _buildInfoRow(
                      "Average Rating",
                      data['rating'] != null
                          ? "${data['rating'].toStringAsFixed(1)} ⭐"
                          : "No ratings yet",
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const Text(
                      "Give Rating & Feedback",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _feedbackController,
                      decoration: InputDecoration(
                        labelText: "Enter your feedback (optional)",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _submitting ? null : _submitAndPay,
                      icon: const Icon(Icons.payment),
                      label: _submitting
                          ? const Text("Processing...")
                          : const Text(
                              "Submit & Pay",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 111, 153, 226),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _callAdmin,
                      icon: const Icon(Icons.call),
                      label: const Text(
                        "Contact Admin",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Expanded(child: Text(value ?? 'N/A')),
        ],
      ),
    );
  }
}
