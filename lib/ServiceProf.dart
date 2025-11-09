import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Serviceprof extends StatelessWidget {
  final String serviceName;

  const Serviceprof({super.key, required this.serviceName});

  @override
  Widget build(BuildContext context) {
    final Color deepBlue = const Color(0xFF2980B9);

    return Scaffold(
      appBar: AppBar(
        title: Text("$serviceName Workers"),
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('services')
            .doc(serviceName)
            .collection('workers')
            .where('approved', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No workers available for this service yet."),
            );
          }

          final workers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: workers.length,
            itemBuilder: (context, index) {
              final worker = workers[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(worker['name'] ?? 'Unnamed'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Phone: ${worker['phone'] ?? 'N/A'}"),
                      Text("Experience: ${worker['experience'] ?? '0'} years"),
                      Text("Address: ${worker['address'] ?? ''}"),
                      const SizedBox(height: 4),
                      Text(worker['description'] ?? ''),
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
