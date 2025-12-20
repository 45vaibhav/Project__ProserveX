import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WorkDonePage extends StatelessWidget {
  const WorkDonePage({super.key});

  // Replace with your Node.js server URL
  final String backendUrl = "http://impressionistically-circulatory-lance.ngrok-free.dev:3000/create-payout";

  Future<void> _payWorker(BuildContext context, Map<String, dynamic> data, String docId) async {
    try {
      final totalAmount = data['totalAmount'] ?? data['amount'] ?? 0;
      final adminCut = ((totalAmount * 10) / 100).round();
      final workerAmount = totalAmount - adminCut;

      final workerUPI = data['workerUPI'];
      if (workerUPI == null || workerUPI.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Worker UPI ID not provided")),
        );
        return;
      }

      // Call Node.js backend for payout
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': workerAmount,
          'workerAccount': workerUPI,
          'currency': 'INR',
        }),
      );

      final result = jsonDecode(response.body);

      if (result['success'] == true) {
        // Mark payment as settled in Firestore
        await FirebaseFirestore.instance
            .collection('payments')
            .doc(docId)
            .update({'settled': true});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Paid ₹$workerAmount to worker ✅")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${result['error']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Work Done / Payments"),
        backgroundColor: const Color(0xFF2980B9),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('payments')
            .where('status', isEqualTo: 'success')
            .where('settled', isEqualTo: false)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No completed works pending settlement",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final payments = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final data = payments[index].data() as Map<String, dynamic>;
              final docId = payments[index].id;

              final totalAmount = data['totalAmount'] ?? data['amount'] ?? 0;
              final adminCut = ((totalAmount * 10) / 100).round();
              final workerAmount = totalAmount - adminCut;
              final workerUPI = data['workerUPI'] ?? "Not Provided";

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(
                    data['workerName'] ?? 'Worker',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("User: ${data['userName']}"),
                      Text("Service: ${data['service']}"),
                      Text("Total: ₹$totalAmount"),
                      Text("Worker Amount: ₹$workerAmount"),
                      Text("Admin Cut: ₹$adminCut"),
                      Text("Worker UPI: $workerUPI"),
                      Text(
                        "Date: ${data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate().toLocal() : DateTime.now()}",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _payWorker(context, data, docId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      "Pay",
                      style: TextStyle(color: Colors.black),
                    ),
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
